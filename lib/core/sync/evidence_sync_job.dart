enum EvidenceSyncJobStatus {
  pending,
  retryScheduled,
  synced,
  blocked,
}

class EvidenceSyncJob {
  const EvidenceSyncJob({
    required this.acaoId,
    required this.evidenciaId,
    required this.localFilePath,
    required this.contentType,
    required this.tamanhoBytes,
    required this.sha256,
    required this.autorUserId,
    required this.createdAt,
    this.status = EvidenceSyncJobStatus.pending,
    this.attemptCount = 0,
    this.lastAttemptAt,
    this.nextAttemptAt,
    this.objectKey,
    this.syncedAt,
  });

  final String acaoId;
  final String evidenciaId;
  final String localFilePath;
  final String contentType;
  final int tamanhoBytes;
  final String sha256;
  final String autorUserId;
  final DateTime createdAt;

  final EvidenceSyncJobStatus status;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? nextAttemptAt;

  final String? objectKey;
  final DateTime? syncedAt;

  bool get possuiSnapshotValido =>
      acaoId.trim().isNotEmpty &&
      evidenciaId.trim().isNotEmpty &&
      localFilePath.trim().isNotEmpty &&
      contentType.trim().isNotEmpty &&
      tamanhoBytes > 0 &&
      RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(sha256.trim()) &&
      autorUserId.trim().isNotEmpty;

  bool get estadoCoerente {
    switch (status) {
      case EvidenceSyncJobStatus.pending:
        return objectKey == null &&
            syncedAt == null &&
            nextAttemptAt == null;
      case EvidenceSyncJobStatus.retryScheduled:
        return objectKey == null &&
            syncedAt == null &&
            nextAttemptAt != null;
      case EvidenceSyncJobStatus.synced:
        return objectKey?.trim().isNotEmpty == true &&
            syncedAt != null &&
            nextAttemptAt == null;
      case EvidenceSyncJobStatus.blocked:
        return objectKey == null &&
            syncedAt == null &&
            nextAttemptAt == null;
    }
  }

  bool get valido =>
      possuiSnapshotValido &&
      attemptCount >= 0 &&
      estadoCoerente;

  EvidenceSyncJob copyWith({
    EvidenceSyncJobStatus? status,
    int? attemptCount,
    DateTime? lastAttemptAt,
    bool limparLastAttemptAt = false,
    DateTime? nextAttemptAt,
    bool limparNextAttemptAt = false,
    String? objectKey,
    bool limparObjectKey = false,
    DateTime? syncedAt,
    bool limparSyncedAt = false,
  }) {
    return EvidenceSyncJob(
      acaoId: acaoId,
      evidenciaId: evidenciaId,
      localFilePath: localFilePath,
      contentType: contentType,
      tamanhoBytes: tamanhoBytes,
      sha256: sha256,
      autorUserId: autorUserId,
      createdAt: createdAt,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: limparLastAttemptAt
          ? null
          : lastAttemptAt ?? this.lastAttemptAt,
      nextAttemptAt: limparNextAttemptAt
          ? null
          : nextAttemptAt ?? this.nextAttemptAt,
      objectKey: limparObjectKey ? null : objectKey ?? this.objectKey,
      syncedAt: limparSyncedAt ? null : syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'acaoId': acaoId,
      'evidenciaId': evidenciaId,
      'localFilePath': localFilePath,
      'contentType': contentType,
      'tamanhoBytes': tamanhoBytes,
      'sha256': sha256,
      'autorUserId': autorUserId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'status': status.name,
      'attemptCount': attemptCount,
      'lastAttemptAt': lastAttemptAt?.toUtc().toIso8601String(),
      'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
      'objectKey': objectKey,
      'syncedAt': syncedAt?.toUtc().toIso8601String(),
    };
  }

  factory EvidenceSyncJob.fromMap(Map<String, dynamic> map) {
    final statusName = map['status']?.toString() ?? '';

    final status = EvidenceSyncJobStatus.values.cast<EvidenceSyncJobStatus?>().firstWhere(
          (value) => value?.name == statusName,
          orElse: () => null,
        );

    if (status == null) {
      throw StateError('Status de sincronizacao de evidencia invalido.');
    }

    final createdAt = DateTime.tryParse(map['createdAt']?.toString() ?? '');
    if (createdAt == null) {
      throw StateError('createdAt invalido na fila de evidencias.');
    }

    DateTime? parseOptional(String key) {
      final raw = map[key];
      if (raw == null) {
        return null;
      }

      final parsed = DateTime.tryParse(raw.toString());
      if (parsed == null) {
        throw StateError('$key invalido na fila de evidencias.');
      }

      return parsed;
    }

    final item = EvidenceSyncJob(
      acaoId: map['acaoId']?.toString() ?? '',
      evidenciaId: map['evidenciaId']?.toString() ?? '',
      localFilePath: map['localFilePath']?.toString() ?? '',
      contentType: map['contentType']?.toString() ?? '',
      tamanhoBytes: map['tamanhoBytes'] is int
          ? map['tamanhoBytes'] as int
          : int.tryParse(map['tamanhoBytes']?.toString() ?? '') ?? 0,
      sha256: map['sha256']?.toString() ?? '',
      autorUserId: map['autorUserId']?.toString() ?? '',
      createdAt: createdAt.toUtc(),
      status: status,
      attemptCount: map['attemptCount'] is int
          ? map['attemptCount'] as int
          : int.tryParse(map['attemptCount']?.toString() ?? '') ?? -1,
      lastAttemptAt: parseOptional('lastAttemptAt')?.toUtc(),
      nextAttemptAt: parseOptional('nextAttemptAt')?.toUtc(),
      objectKey: map['objectKey']?.toString(),
      syncedAt: parseOptional('syncedAt')?.toUtc(),
    );

    if (!item.valido) {
      throw StateError('Job de sincronizacao de evidencia inconsistente.');
    }

    return item;
  }
}