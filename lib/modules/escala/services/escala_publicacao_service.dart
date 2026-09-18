import '../models/escala_models.dart';

class EscalaPublicacaoAnalise {
  const EscalaPublicacaoAnalise({
    required this.bloqueios,
    required this.alertas,
    required this.totalAtividades,
    required this.totalAgentes,
    required this.totalEducativas,
    required this.totalAdministrativas,
  });

  final List<String> bloqueios;
  final List<String> alertas;
  final int totalAtividades;
  final int totalAgentes;
  final int totalEducativas;
  final int totalAdministrativas;

  bool get podePublicar => bloqueios.isEmpty;
}

abstract final class EscalaPublicacaoService {
  static EscalaPublicacaoAnalise analisar({
    required EscalaModel escala,
    required List<EscalaAtividadeModel> atividades,
    required List<EscalaAlocacaoModel> alocacoes,
    List<String> alertasOperacionais = const <String>[],
  }) {
    final bloqueios = <String>[];
    final alertas = <String>{...alertasOperacionais};
    final atividadeIds = <String>{};
    final alocacaoIds = <String>{};
    final identidades = <String>{};

    if (escala.status != EscalaCodigos.statusRascunho) {
      bloqueios.add('Somente uma escala em rascunho pode ser publicada.');
    }

    if (escala.versao > 1) {
      if (escala.motivoRevisao.trim().isEmpty) {
        bloqueios.add('A revisão precisa possuir motivo registrado.');
      }
      if (escala.revisaoDeEscalaId.trim().isEmpty) {
        bloqueios.add(
          'A revisão precisa referenciar a versão publicada anterior.',
        );
      }
      if (!escala.revisaoPreparada) {
        bloqueios.add('A preparação da revisão ainda não foi concluída.');
      }
    }

    if (atividades.isEmpty) {
      alertas.add('Nenhuma atividade cadastrada para esta data.');
    }

    var educativas = 0;
    var administrativas = 0;

    for (final atividade in atividades) {
      if (!atividadeIds.add(atividade.id)) {
        bloqueios.add('Atividade duplicada: ${atividade.id}.');
      }
      if (atividade.escalaId != escala.id) {
        bloqueios.add(
          'A atividade "${atividade.titulo}" referencia outra escala.',
        );
      }
      if (!_mesmoDia(atividade.data, escala.data)) {
        bloqueios.add(
          'A atividade "${atividade.titulo}" possui data incompatível.',
        );
      }
      if (atividade.secaoId.trim().isEmpty) {
        bloqueios.add('A atividade "${atividade.titulo}" está sem seção.');
      }
      if (atividade.tipoAtividadeId.trim().isEmpty) {
        bloqueios.add('Há atividade sem tipo definido.');
      }
      if (atividade.titulo.trim().isEmpty) {
        bloqueios.add('Há atividade sem título.');
      }
      if (atividade.turnoId.trim().isEmpty) {
        bloqueios.add('A atividade "${atividade.titulo}" está sem turno.');
      }

      if (atividade.naturezaAtividade == EscalaCodigos.naturezaEducativa) {
        educativas++;
        if (!atividade.geraRae) {
          bloqueios.add(
            'A atividade educativa "${atividade.titulo}" precisa gerar RAE.',
          );
        }
      } else if (atividade.naturezaAtividade ==
          EscalaCodigos.naturezaAdministrativa) {
        administrativas++;
        if (atividade.geraRae) {
          bloqueios.add(
            'A missão administrativa "${atividade.titulo}" não pode gerar RAE.',
          );
        }
      } else {
        bloqueios.add(
          'A atividade "${atividade.titulo}" possui natureza inválida.',
        );
      }
    }

    for (final alocacao in alocacoes) {
      if (!alocacaoIds.add(alocacao.id)) {
        bloqueios.add('Alocação duplicada: ${alocacao.id}.');
      }
      if (alocacao.escalaId != escala.id) {
        bloqueios.add(
          'A alocação de ${alocacao.nomeSnapshot} referencia outra escala.',
        );
      }
      if (!atividadeIds.contains(alocacao.atividadeId)) {
        bloqueios.add(
          'A alocação de ${alocacao.nomeSnapshot} referencia atividade inexistente.',
        );
      }
      if (!_mesmoDia(alocacao.data, escala.data)) {
        bloqueios.add(
          'A alocação de ${alocacao.nomeSnapshot} possui data incompatível.',
        );
      }
      if (alocacao.membroEquipeId.trim().isEmpty) {
        bloqueios.add('Há alocação sem integrante da Equipe Operacional.');
      }
      if (alocacao.nomeSnapshot.trim().isEmpty) {
        bloqueios.add('Há alocação sem identificação nominal.');
      }
      if (!_jornadaValida(alocacao.tipoJornada)) {
        bloqueios.add(
          'A jornada de ${alocacao.nomeSnapshot} possui classificação inválida.',
        );
      }
      if (alocacao.minutosPrevistos < 0 || alocacao.minutosPrevistos > 1440) {
        bloqueios.add(
          'A jornada de ${alocacao.nomeSnapshot} possui duração inválida.',
        );
      }
      if (alocacao.jornadaComplementar) {
        if (alocacao.motivoJornadaComplementar.trim().isEmpty ||
            alocacao.classificadoPor.trim().isEmpty ||
            alocacao.classificadoEm == null) {
          bloqueios.add(
            'A jornada complementar de ${alocacao.nomeSnapshot} '
            'está sem classificação completa.',
          );
        }
      }

      final uid = alocacao.usuarioId.trim();
      final membro = alocacao.membroEquipeId.trim();
      if (uid.isNotEmpty) {
        identidades.add('uid:$uid');
      } else if (membro.isNotEmpty) {
        identidades.add('membro:$membro');
      }
    }

    return EscalaPublicacaoAnalise(
      bloqueios: List<String>.unmodifiable(
        bloqueios.toSet().toList(growable: false),
      ),
      alertas: List<String>.unmodifiable(alertas.toList(growable: false)),
      totalAtividades: atividades.length,
      totalAgentes: identidades.length,
      totalEducativas: educativas,
      totalAdministrativas: administrativas,
    );
  }

  static bool _jornadaValida(String codigo) =>
      codigo == EscalaCodigos.jornadaNormal ||
      codigo == EscalaCodigos.jornadaHoraExtra ||
      codigo == EscalaCodigos.jornadaBancoHoras;

  static bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
