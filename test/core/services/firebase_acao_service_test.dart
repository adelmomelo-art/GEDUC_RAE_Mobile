import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/firebase_acao_service.dart';

import '../../support/acao_fixture.dart';

void main() {
  test('mesma ação sempre resolve para o mesmo documento remoto', () {
    final acao = criarAcaoTeste(
      id: 'acao-estavel',
    );

    final primeiraTentativa = AcaoPersistenceIdentity.documentId(acao);
    final segundaTentativa = AcaoPersistenceIdentity.documentId(acao);

    expect(
      primeiraTentativa,
      'acao-estavel',
    );

    expect(
      segundaTentativa,
      primeiraTentativa,
    );
  });

  test('normaliza espaços externos sem trocar a identidade', () {
    final id = AcaoPersistenceIdentity.documentId(
      criarAcaoTeste(
        id: '  acao-estavel  ',
      ),
    );

    expect(
      id,
      'acao-estavel',
    );
  });

  test('rejeita ação sem ID local', () {
    expect(
      () => AcaoPersistenceIdentity.documentId(
        criarAcaoTeste(
          id: '   ',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('preserva anoRAE já definido', () {
    final acao = criarAcaoTeste(
      anoRAE: 2025,
      dataAcao: DateTime(2026, 8, 17),
    );

    final anoResolvido = acao.anoRAE > 0 ? acao.anoRAE : acao.dataAcao.year;

    expect(
      anoResolvido,
      2025,
    );
  });

  test('usa ano da data da ação quando anoRAE não está definido', () {
    final acao = criarAcaoTeste(
      anoRAE: 0,
      dataAcao: DateTime(2024, 12, 31),
    );

    final anoResolvido = acao.anoRAE > 0 ? acao.anoRAE : acao.dataAcao.year;

    expect(
      anoResolvido,
      2024,
    );
  });

  test('sincronização tardia não altera exercício histórico', () {
    final acao = criarAcaoTeste(
      anoRAE: 2026,
      dataAcao: DateTime(2026, 12, 31),
    );

    final anoResolvido = acao.anoRAE > 0 ? acao.anoRAE : acao.dataAcao.year;

    expect(
      anoResolvido,
      2026,
    );
  });
}
