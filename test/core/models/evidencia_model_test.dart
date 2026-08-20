import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/models/evidencia_model.dart';

void main() {
  group('AUD-L2-R5.2-A - EvidenciaModel', () {
    test('serializa e restaura metadados completos', () {
      final criadoEm = DateTime.parse('2026-08-20T09:00:00-03:00');
      final sincronizadoEm = DateTime.parse('2026-08-20T09:10:00-03:00');

      final original = EvidenciaModel(
        id: 'ev-001',
        acaoId: 'rae-001',
        caminhoArquivo: '/local/ev-001.jpg',
        tipo: 'imagem',
        criadoEm: criadoEm,
        status: EvidenciaStatus.sincronizada,
        sha256: 'abc123',
        tamanhoBytes: 321,
        mimeType: 'image/jpeg',
        objectKey: 'evidencias/rae-001/ev-001.jpg',
        sincronizadoEm: sincronizadoEm,
        autorUserId: 'user-001',
      );

      final restaurada = EvidenciaModel.fromMap(original.toMap());

      expect(restaurada.id, original.id);
      expect(restaurada.acaoId, original.acaoId);
      expect(restaurada.sha256, 'abc123');
      expect(restaurada.tamanhoBytes, 321);
      expect(restaurada.mimeType, 'image/jpeg');
      expect(restaurada.objectKey, 'evidencias/rae-001/ev-001.jpg');
      expect(restaurada.sincronizadoEm, sincronizadoEm);
      expect(restaurada.autorUserId, 'user-001');
      expect(restaurada.status, EvidenciaStatus.sincronizada);
    });

    test('registro legado sem metadados continua legivel', () {
      final evidencia = EvidenciaModel.fromMap({
        'id': 'legacy-001',
        'acaoId': 'rae-legacy',
        'caminhoArquivo': '/legacy/foto.jpg',
        'tipo': 'imagem',
        'criadoEm': '2026-08-01T10:00:00.000',
        'status': 'pendente',
      });

      expect(evidencia.sha256, isEmpty);
      expect(evidencia.tamanhoBytes, 0);
      expect(evidencia.mimeType, isEmpty);
      expect(evidencia.objectKey, isEmpty);
      expect(evidencia.sincronizadoEm, isNull);
      expect(evidencia.autorUserId, isEmpty);
      expect(evidencia.status, EvidenciaStatus.pendente);
    });

    test('copyWith permite limpar sincronizadoEm explicitamente', () {
      final evidencia = EvidenciaModel(
        id: 'ev-003',
        acaoId: 'rae-001',
        caminhoArquivo: '/local/ev-003.jpg',
        tipo: 'imagem',
        criadoEm: DateTime.parse('2026-08-20T09:00:00-03:00'),
        sincronizadoEm: DateTime.parse('2026-08-20T09:10:00-03:00'),
      );

      final limpa = evidencia.copyWith(limparSincronizadoEm: true);

      expect(limpa.sincronizadoEm, isNull);
    });
    test('status desconhecido falha fechado para pendente', () {
      final evidencia = EvidenciaModel.fromMap({
        'id': 'legacy-002',
        'acaoId': 'rae-legacy',
        'caminhoArquivo': '/legacy/foto.jpg',
        'tipo': 'imagem',
        'criadoEm': '2026-08-01T10:00:00.000',
        'status': 'status-inexistente',
      });

      expect(evidencia.status, EvidenciaStatus.pendente);
    });
  });
}
