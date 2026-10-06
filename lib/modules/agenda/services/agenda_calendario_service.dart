import '../models/agenda_compromisso.dart';

enum AgendaSinal { agendada, proxima, cancelada }

abstract final class AgendaCalendarioService {
  static AgendaSinal sinal(AgendaCompromisso item, {required DateTime hoje}) {
    if (item.cancelada) return AgendaSinal.cancelada;
    // Dias civis: evita arredondamentos por horário ou transição de fuso.
    final dia = DateTime.utc(item.data.year, item.data.month, item.data.day);
    final atual = DateTime.utc(hoje.year, hoje.month, hoje.day);
    final distancia = dia.difference(atual).inDays;
    return distancia >= 0 && distancia <= 3
        ? AgendaSinal.proxima
        : AgendaSinal.agendada;
  }

  static String rotulo(AgendaSinal sinal) => switch (sinal) {
        AgendaSinal.agendada => 'Agendada',
        AgendaSinal.proxima => 'Hoje / próximos 3 dias',
        AgendaSinal.cancelada => 'Cancelada',
      };
}
