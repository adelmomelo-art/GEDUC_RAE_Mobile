import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/agenda/models/agenda_compromisso.dart';
import 'package:geduc_rae_mobile/modules/agenda/services/agenda_calendario_service.dart';

void main() {
  final hoje = DateTime(2026, 10, 6, 23, 59);
  AgendaCompromisso item(DateTime dia, {bool cancelada = false}) =>
      AgendaCompromisso(
        id: 'a',
        titulo: 'Ação',
        turno: 'manha',
        data: dia,
        situacao: cancelada ? 'cancelada' : 'planejamento',
      );
  test('amarelo cobre hoje e três dias civis; não cobre passado nem +4', () {
    for (final dias in [0, 1, 2, 3]) {
      expect(
        AgendaCalendarioService.sinal(
          item(DateTime(2026, 10, 6 + dias)),
          hoje: hoje,
        ),
        AgendaSinal.proxima,
      );
    }
    for (final dias in [-1, 4, 20]) {
      expect(
        AgendaCalendarioService.sinal(
          item(DateTime(2026, 10, 6 + dias)),
          hoje: hoje,
        ),
        AgendaSinal.agendada,
      );
    }
  });
  test('cancelamento prevalece nas três faixas de data', () {
    for (final dias in [-1, 0, 3, 4]) {
      expect(
        AgendaCalendarioService.sinal(
          item(DateTime(2026, 10, 6 + dias), cancelada: true),
          hoje: hoje,
        ),
        AgendaSinal.cancelada,
      );
    }
  });
  test('janela atravessa mês/ano e desconsidera hora da ação', () {
    final fimAno = DateTime(2026, 12, 30, 23, 59);
    expect(
      AgendaCalendarioService.sinal(
        item(DateTime(2027, 1, 2, 23, 59)),
        hoje: fimAno,
      ),
      AgendaSinal.proxima,
    );
    expect(
      AgendaCalendarioService.sinal(item(DateTime(2027, 1, 3)), hoje: fimAno),
      AgendaSinal.agendada,
    );
  });
}
