import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/tipo_acao_model.dart';

void main() {
  group('TipoAcaoModel', () {
    test('prioriza o id documental e faz parsing tolerante', () {
      final modelo = TipoAcaoModel.fromMap(<String, dynamic>{
        'id': 'id-interno',
        'nomeAcao': '  Palestra   Educativa  ',
        'tipoAcao': 'Escola',
        'publicoEstimadoPadrao': 120.0,
        'publicoMinimoPadrao': '30',
        'materiaisSugeridos': <dynamic>['Cone', 'Faixa'],
      }, documentId: 'id-documento').normalizado();

      expect(modelo.id, 'id-documento');
      expect(modelo.nomeAcao, 'Palestra Educativa');
      expect(modelo.publicoEstimadoPadrao, 120);
      expect(modelo.publicoMinimoPadrao, 30);
      expect(modelo.ativo, isTrue);
    });

    test('normaliza materiais vazios e duplicados', () {
      final materiais = TipoAcaoModel.normalizarMateriais(<String>[
        ' Cone ',
        'cone',
        '',
        'Faixa educativa',
      ]);

      expect(materiais, <String>['Cone', 'Faixa educativa']);
    });

    test('gera chave de comparação sem acentos e espaços excedentes', () {
      const modelo = TipoAcaoModel(
        id: '',
        nomeAcao: ' Ação  Educativa ',
        tipoAcao: ' Trânsito ',
        publicoEstimadoPadrao: 0,
        publicoMinimoPadrao: 0,
        materiaisSugeridos: <String>[],
        ativo: true,
      );

      expect(modelo.chaveNormalizada, 'acao educativa|transito');
    });

    test('valida campos obrigatórios e públicos', () {
      const modelo = TipoAcaoModel(
        id: '',
        nomeAcao: ' ',
        tipoAcao: '',
        publicoEstimadoPadrao: 10,
        publicoMinimoPadrao: 20,
        materiaisSugeridos: <String>[],
        ativo: true,
      );

      expect(modelo.validar(), hasLength(3));
    });

    test('serializa sem metadados quando solicitado', () {
      final data = DateTime(2026, 8, 6);
      final modelo = TipoAcaoModel(
        id: 'tipo-1',
        nomeAcao: 'Blitz Educativa',
        tipoAcao: 'Via pública',
        publicoEstimadoPadrao: 50,
        publicoMinimoPadrao: 10,
        materiaisSugeridos: const <String>['Cone'],
        ativo: true,
        criadoEm: data,
        atualizadoEm: data,
      );

      final mapa = modelo.toMap(incluirMetadados: false);

      expect(mapa['id'], 'tipo-1');
      expect(mapa.containsKey('criadoEm'), isFalse);
      expect(mapa.containsKey('atualizadoEm'), isFalse);
    });
  });
}
