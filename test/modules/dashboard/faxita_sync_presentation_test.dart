import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/faxita/faxita_summary_card.dart';

void main() {
  test('remove alerta legado quando a fila local está vazia', () {
    final alertas = FaxitaSyncPresentation.alertas(
      const [
        'Alerta de negócio.',
        '3 registro(s) aguardam sincronização.',
      ],
      0,
    );

    expect(alertas, ['Alerta de negócio.']);
  });

  test('resumo usa a fila local como fonte da sincronização', () {
    const resumo = 'Resumo operacional. '
        'Existem 3 registro(s) pendente(s) de sincronização.';

    expect(
      FaxitaSyncPresentation.resumo(resumo, 0),
      'Resumo operacional. Todos os registros do período estão sincronizados.',
    );
    expect(
      FaxitaSyncPresentation.resumo(resumo, 2),
      'Resumo operacional. '
      'Existem 2 registro(s) pendente(s) de sincronização.',
    );
  });
}
