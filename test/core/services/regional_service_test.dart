import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/localizacao/regional_service.dart';
import 'package:geduc_rae_mobile/data/models/regional_model.dart';

void main() {
  const regional3 = RegionalModel(
    id: 'r3',
    nome: 'Regional Administrativa 3',
    bairros: ['São Gerardo', 'Parquelândia'],
  );

  test('identifica uma única Regional por bairro normalizado', () {
    final resultado = RegionalService.resolverPorBairro(
      '  SAO   GERARDO ',
      const [regional3],
    );

    expect(resultado.encontrada, isTrue);
    expect(resultado.id, 'r3');
    expect(resultado.ambigua, isFalse);
  });

  test('não escolhe arbitrariamente quando há duplicidade', () {
    final resultado = RegionalService.resolverPorBairro(
      'Parquelândia',
      const [
        regional3,
        RegionalModel(
          id: 'r4',
          nome: 'Regional Administrativa 4',
          bairros: ['Parquelândia'],
        ),
      ],
    );

    expect(resultado.encontrada, isFalse);
    expect(resultado.ambigua, isTrue);
    expect(resultado.correspondencias, hasLength(2));
  });

  test('documento antigo sem tipo permanece administrativo', () {
    final regional = RegionalModel.fromMap('legado', {
      'nomeRegional': 'Regional 1',
      'bairrosVinculados': ['Centro'],
      'ativo': true,
    });

    expect(regional.tipo, TipoRegional.administrativa);
    expect(regional.nome, 'Regional 1');
  });
}
