import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/firebase_acao_service.dart';

import '../../support/acao_fixture.dart';

void main() {
  test('mesma ação sempre resolve para o mesmo documento remoto', () {
    final acao = criarAcaoTeste(id: 'acao-estavel');

    final primeiraTentativa = AcaoPersistenceIdentity.documentId(acao);
    final segundaTentativa = AcaoPersistenceIdentity.documentId(acao);

    expect(primeiraTentativa, 'acao-estavel');
    expect(segundaTentativa, primeiraTentativa);
  });

  test('normaliza espaços externos sem trocar a identidade', () {
    final id = AcaoPersistenceIdentity.documentId(
      criarAcaoTeste(id: '  acao-estavel  '),
    );

    expect(id, 'acao-estavel');
  });

  test('rejeita ação sem ID local', () {
    expect(
      () => AcaoPersistenceIdentity.documentId(criarAcaoTeste(id: '   ')),
      throwsArgumentError,
    );
  });
}
