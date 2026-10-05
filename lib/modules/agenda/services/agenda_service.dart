import '../../escala/models/escala_models.dart';
import '../../escala/services/escala_horas_service.dart';
import '../models/agenda_compromisso.dart';

abstract final class AgendaService {
  /// Cada escala mantém seu snapshot, inclusive após uma remarcação.
  static String novaAtividadeId(String compromissoId, String escalaId) =>
      'agenda-$escalaId-$compromissoId';

  static String dataId(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static List<String> validar(
    AgendaCompromisso item, {
    bool paraEscala = false,
  }) {
    final erros = <String>[];
    if (item.titulo.trim().isEmpty) erros.add('Informe o título da ação.');
    if (!['manha', 'tarde', 'noite'].contains(item.turno)) {
      erros.add('Informe o turno.');
    }
    if (!['educativa', 'administrativa'].contains(item.natureza)) {
      erros.add('Natureza inválida.');
    }
    if (item.horaInicio.isEmpty != item.horaFim.isEmpty ||
        (!item.horarioACombinar &&
            EscalaHorasService.calcularDuracaoMinutos(
                  inicio: item.horaInicio,
                  fim: item.horaFim,
                ) ==
                null)) {
      erros.add(
        'Informe início e fim no formato HH:mm ou deixe ambos a combinar.',
      );
    }
    if ((item.quantidadePublico ?? 0) < 0 ||
        (item.integrantesNecessarios ?? 0) < 0) {
      erros.add('As quantidades não podem ser negativas.');
    }
    if (paraEscala) {
      if (item.cancelada) {
        erros.add('Compromisso cancelado não pode ser escalado.');
      }
      if (!item.pronta) {
        erros.add('Marque o planejamento como pronto para escala.');
      }
      if (item.horarioACombinar) {
        erros.add('Defina os horários antes de montar a escala.');
      }
      if (item.local.trim().isEmpty || item.endereco.trim().isEmpty) {
        erros.add('Informe local e endereço antes de montar a escala.');
      }
      if (item.natureza == 'educativa' && item.projetoId.isEmpty) {
        erros.add('Selecione um projeto do Catálogo Institucional.');
      }
    }
    return erros;
  }

  /// Apenas dados deliberadamente destinados à equipe são projetados.
  static Map<String, dynamic> camposPublicos(AgendaCompromisso item) => {
        'titulo': item.titulo.trim(),
        'descricao': item.descricao.trim(),
        'turnoId': item.turno,
        'secaoId': item.secaoId,
        'tipoAtividadeId':
            item.projetoId.isEmpty ? 'missao_administrativa' : item.projetoId,
        'naturezaAtividade': item.natureza,
        'qtrHorario': item.horaInicio,
        'horaInicio': item.horaInicio,
        'horaFim': item.horaFim,
        'qthLocal': item.local.trim(),
        'qthEndereco': item.endereco.trim(),
        'qthRegionalId': item.regionalId,
        'qthPontoReferencia': item.referencia.trim(),
        'orientacaoOperacional': item.orientacaoEquipe.trim(),
        'geraRae': item.natureza == 'educativa',
        'contabilizaProdutividade': true,
        'agendaCompromissoId': item.id,
        'agendaRevisao': item.revisao,
        'projetoId': item.projetoId,
      };

  static String situacaoExibida(AgendaCompromisso item, EscalaModel? escala) {
    if (item.cancelada) return 'Cancelada';
    if (item.vinculada && escala?.status == EscalaCodigos.statusPublicada) {
      return 'Escala publicada';
    }
    if (item.vinculada) return 'Escala em elaboração';
    return item.pronta ? 'Pronta para escala' : 'Em planejamento';
  }
}
