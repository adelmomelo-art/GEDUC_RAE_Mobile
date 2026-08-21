import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'evidence_sync_job.dart';
import 'evidence_sync_store.dart';

class SharedPreferencesEvidenceSyncStore implements EvidenceSyncStore {
  SharedPreferencesEvidenceSyncStore({
    SharedPreferences? preferences,
  }) : _preferences = preferences;

  static const String storageKey = 'evidence_sync_queue_v1';

  SharedPreferences? _preferences;
  Future<void> _serial = Future<void>.value();

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    _serial = _serial.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  @override
  Future<List<EvidenceSyncJob>> listar() {
    return _exclusive(() async {
      final jobs = await _lerMapa();
      return jobs.values.toList(growable: false);
    });
  }

  @override
  Future<EvidenceSyncJob?> obter({
    required String acaoId,
    required String evidenciaId,
  }) {
    return _exclusive(() async {
      final jobs = await _lerMapa();
      return jobs[_jobKey(acaoId, evidenciaId)];
    });
  }

  @override
  Future<void> salvar(EvidenceSyncJob job) async {
    if (!job.valido) {
      throw ArgumentError('Job de sincronizacao de evidencia invalido.');
    }

    await _exclusive(() async {
      final jobs = await _lerMapa();
      jobs[_jobKey(job.acaoId, job.evidenciaId)] = job;
      await _gravarMapa(jobs);
    });
  }

  @override
  Future<void> remover({
    required String acaoId,
    required String evidenciaId,
  }) {
    return _exclusive(() async {
      final jobs = await _lerMapa();
      jobs.remove(_jobKey(acaoId, evidenciaId));
      await _gravarMapa(jobs);
    });
  }

  String _jobKey(String acaoId, String evidenciaId) {
    if (acaoId.trim().isEmpty || evidenciaId.trim().isEmpty) {
      throw ArgumentError('Identidade de evidencia invalida.');
    }

    return jsonEncode(<String>[acaoId, evidenciaId]);
  }

  Future<Map<String, EvidenceSyncJob>> _lerMapa() async {
    final prefs = await _prefs();
    final raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return <String, EvidenceSyncJob>{};
    }

    late final Object? decoded;

    try {
      decoded = jsonDecode(raw);
    } catch (error) {
      throw StateError(
        'Fila persistente de evidencias corrompida: JSON invalido.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw StateError(
        'Fila persistente de evidencias corrompida: raiz invalida.',
      );
    }

    final jobs = <String, EvidenceSyncJob>{};

    for (final entry in decoded.entries) {
      final value = entry.value;

      if (value is! Map<String, dynamic>) {
        throw StateError(
          'Fila persistente de evidencias corrompida: item invalido.',
        );
      }

      final job = EvidenceSyncJob.fromMap(value);
      final canonicalKey = _jobKey(job.acaoId, job.evidenciaId);

      if (canonicalKey != entry.key) {
        throw StateError(
          'Fila persistente de evidencias corrompida: chave divergente.',
        );
      }

      jobs[entry.key] = job;
    }

    return jobs;
  }

  Future<void> _gravarMapa(Map<String, EvidenceSyncJob> jobs) async {
    final prefs = await _prefs();

    final encoded = jsonEncode(
      <String, dynamic>{
        for (final entry in jobs.entries)
          entry.key: entry.value.toMap(),
      },
    );

    final ok = await prefs.setString(storageKey, encoded);

    if (!ok) {
      throw StateError(
        'Falha ao persistir fila de sincronizacao de evidencias.',
      );
    }
  }
}