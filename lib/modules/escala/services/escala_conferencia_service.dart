import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';

class EscalaConferenciaAgente {
  EscalaConferenciaAgente({
    required this.chavePessoa,
    required this.membroEquipeId,
    required this.usuarioId,
    required this.nome,
    required this.cargaHorariaCodigo,
    required this.identidadeCanonica,
    required this.quantidadeAlocacoes,
    required Iterable<String> tiposIndisponibilidade,
    required this.emAtividadeEducativa,
    required this.emAdministrativoApoio,
  }) : tiposIndisponibilidade = List<String>.unmodifiable(
          tiposIndisponibilidade.toSet().toList()..sort(),
        );

  final String chavePessoa;
  final String membroEquipeId;
  final String usuarioId;
  final String nome;
  final String cargaHorariaCodigo;
  final bool identidadeCanonica;
  final int quantidadeAlocacoes;
  final List<String> tiposIndisponibilidade;
  final bool emAtividadeEducativa;
  final bool emAdministrativoApoio;

  bool get emAtividade => quantidadeAlocacoes > 0;
  bool get indisponivel => tiposIndisponibilidade.isNotEmpty;
  bool get situacaoDupla => emAtividade && indisponivel;
  bool get semSituacao => !emAtividade && !indisponivel;
  bool get multiplaAlocacao => quantidadeAlocacoes > 1;
}

class EscalaConferenciaResultado {
  EscalaConferenciaResultado({
    required Iterable<EscalaConferenciaAgente> agentes,
    required this.totalAlocacoesMapeadas,
    required this.totalJornadasComplementares,
    required Iterable<String> alocacoesNaoMapeadas,
    required Iterable<String> indisponibilidadesNaoMapeadas,
    required Iterable<String> identidadesCanonicasDuplicadas,
    required Iterable<String> identidadesInconsistentes,
  })  : agentes = List<EscalaConferenciaAgente>.unmodifiable(agentes),
        alocacoesNaoMapeadas = List<String>.unmodifiable(alocacoesNaoMapeadas),
        indisponibilidadesNaoMapeadas = List<String>.unmodifiable(
          indisponibilidadesNaoMapeadas,
        ),
        identidadesCanonicasDuplicadas = List<String>.unmodifiable(
          identidadesCanonicasDuplicadas,
        ),
        identidadesInconsistentes = List<String>.unmodifiable(
          identidadesInconsistentes,
        );

  final List<EscalaConferenciaAgente> agentes;
  final int totalAlocacoesMapeadas;
  final int totalJornadasComplementares;
  final List<String> alocacoesNaoMapeadas;
  final List<String> indisponibilidadesNaoMapeadas;
  final List<String> identidadesCanonicasDuplicadas;
  final List<String> identidadesInconsistentes;

  int get totalEfetivo => agentes.length;
  int get totalExplicados => agentes.where((item) => !item.semSituacao).length;
  int get totalSemSituacao => agentes.where((item) => item.semSituacao).length;
  int get totalEmAtividade => agentes.where((item) => item.emAtividade).length;
  int get totalIndisponiveis =>
      agentes.where((item) => item.indisponivel).length;
  int get totalAtividadeEducativa =>
      agentes.where((item) => item.emAtividadeEducativa).length;
  int get totalAdministrativoApoio =>
      agentes.where((item) => item.emAdministrativoApoio).length;
  int get totalSituacaoDupla =>
      agentes.where((item) => item.situacaoDupla).length;
  int get totalMultiplasAlocacoes =>
      agentes.where((item) => item.multiplaAlocacao).length;
  int get totalIdentidadeNaoCanonica =>
      agentes.where((item) => !item.identidadeCanonica).length;

  bool get coberturaCompleta => totalSemSituacao == 0;

  List<EscalaConferenciaAgente> get agentesSemSituacao =>
      List<EscalaConferenciaAgente>.unmodifiable(
        agentes.where((item) => item.semSituacao),
      );

  List<EscalaConferenciaAgente> get agentesComSituacaoDupla =>
      List<EscalaConferenciaAgente>.unmodifiable(
        agentes.where((item) => item.situacaoDupla),
      );

  List<EscalaConferenciaAgente> get agentesComMultiplasAlocacoes =>
      List<EscalaConferenciaAgente>.unmodifiable(
        agentes.where((item) => item.multiplaAlocacao),
      );

  List<EscalaConferenciaAgente> get agentesSemIdentidadeCanonica =>
      List<EscalaConferenciaAgente>.unmodifiable(
        agentes.where((item) => !item.identidadeCanonica),
      );

  Map<String, int> get indisponiveisPorTipo {
    final porTipo = <String, Set<String>>{};

    for (final agente in agentes) {
      for (final tipo in agente.tiposIndisponibilidade) {
        porTipo.putIfAbsent(tipo, () => <String>{}).add(agente.chavePessoa);
      }
    }

    return Map<String, int>.unmodifiable(
      porTipo.map((tipo, pessoas) => MapEntry(tipo, pessoas.length)),
    );
  }
}

abstract final class EscalaConferenciaService {
  static EscalaConferenciaResultado conferir({
    required DateTime data,
    required Iterable<MembroEquipeModel> membrosEquipe,
    required Iterable<EscalaPerfilOperacionalModel> perfisOperacionais,
    required Iterable<EscalaAlocacaoModel> alocacoes,
    required Iterable<EscalaIndisponibilidadeModel> indisponibilidades,
    Iterable<EscalaAtividadeModel> atividades = const <EscalaAtividadeModel>[],
  }) {
    final dia = _somenteData(data);

    final perfisAtivosPorMembro =
        <String, List<EscalaPerfilOperacionalModel>>{};
    for (final perfil in perfisOperacionais) {
      if (!perfil.ativo) continue;
      if (perfil.setorCodigo.trim().toUpperCase() != 'GEDUC') continue;
      final membroId = perfil.membroEquipeId.trim();
      if (membroId.isEmpty) continue;
      perfisAtivosPorMembro
          .putIfAbsent(membroId, () => <EscalaPerfilOperacionalModel>[])
          .add(perfil);
    }

    final agentesPorChave = <String, _AgenteBuilder>{};
    final chavePorMembro = <String, String>{};
    final chavePorUid = <String, String>{};
    final duplicidadesUid = <String>{};

    for (final membro in membrosEquipe) {
      if (!membro.ativo) continue;
      final membroId = membro.id.trim();
      if (membroId.isEmpty) continue;

      final perfis = perfisAtivosPorMembro[membroId];
      if (perfis == null || perfis.isEmpty) continue;

      final perfil = perfis.first;
      final uidMembro = membro.usuarioId.trim();
      final uidPerfil = perfil.usuarioId.trim();
      final uid = uidMembro.isNotEmpty ? uidMembro : uidPerfil;
      final chave = uid.isNotEmpty ? 'uid:$uid' : 'membro:$membroId';

      if (uid.isNotEmpty && agentesPorChave.containsKey(chave)) {
        duplicidadesUid.add(uid);
        chavePorMembro[membroId] = chave;
        continue;
      }

      agentesPorChave[chave] = _AgenteBuilder(
        chavePessoa: chave,
        membroEquipeId: membroId,
        usuarioId: uid,
        nome: membro.nome.trim(),
        cargaHorariaCodigo: perfil.cargaHorariaCodigo.trim(),
        identidadeCanonica: uid.isNotEmpty,
      );

      chavePorMembro[membroId] = chave;
      if (uid.isNotEmpty) chavePorUid[uid] = chave;
    }

    final atividadesPorId = <String, EscalaAtividadeModel>{
      for (final atividade in atividades) atividade.id: atividade,
    };

    final alocacoesNaoMapeadas = <String>[];
    final indisponibilidadesNaoMapeadas = <String>[];
    final identidadesInconsistentes = <String>[];
    var alocacoesMapeadas = 0;
    var jornadasComplementares = 0;

    for (final alocacao in alocacoes) {
      if (_somenteData(alocacao.data) != dia) continue;

      final resolucao = _resolverPessoa(
        usuarioId: alocacao.usuarioId,
        membroEquipeId: alocacao.membroEquipeId,
        chavePorUid: chavePorUid,
        chavePorMembro: chavePorMembro,
      );

      if (resolucao.inconsistente) {
        identidadesInconsistentes.add('alocacao:${alocacao.id}');
      }

      final chave = resolucao.chave;
      final agente = chave == null ? null : agentesPorChave[chave];
      if (agente == null) {
        alocacoesNaoMapeadas.add(alocacao.id);
        continue;
      }

      alocacoesMapeadas++;
      agente.quantidadeAlocacoes++;

      if (alocacao.tipoJornada == EscalaCodigos.jornadaHoraExtra ||
          alocacao.tipoJornada == EscalaCodigos.jornadaBancoHoras) {
        jornadasComplementares++;
      }

      final atividade = atividadesPorId[alocacao.atividadeId];
      if (atividade?.naturezaAtividade ==
          EscalaCodigos.naturezaAdministrativa) {
        agente.emAdministrativoApoio = true;
      }
      if (atividade?.naturezaAtividade == EscalaCodigos.naturezaEducativa) {
        agente.emAtividadeEducativa = true;
      }
    }

    for (final indisponibilidade in indisponibilidades) {
      if (!_abrangeDia(indisponibilidade, dia)) continue;

      final resolucao = _resolverPessoa(
        usuarioId: indisponibilidade.usuarioId,
        membroEquipeId: indisponibilidade.membroEquipeId,
        chavePorUid: chavePorUid,
        chavePorMembro: chavePorMembro,
      );

      if (resolucao.inconsistente) {
        identidadesInconsistentes.add(
          'indisponibilidade:${indisponibilidade.id}',
        );
      }

      final chave = resolucao.chave;
      final agente = chave == null ? null : agentesPorChave[chave];
      if (agente == null) {
        indisponibilidadesNaoMapeadas.add(indisponibilidade.id);
        continue;
      }

      final tipo = indisponibilidade.tipoId.trim();
      if (tipo.isNotEmpty) agente.tiposIndisponibilidade.add(tipo);
    }

    final agentes = agentesPorChave.values.map((item) => item.build()).toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

    return EscalaConferenciaResultado(
      agentes: agentes,
      totalAlocacoesMapeadas: alocacoesMapeadas,
      totalJornadasComplementares: jornadasComplementares,
      alocacoesNaoMapeadas: alocacoesNaoMapeadas,
      indisponibilidadesNaoMapeadas: indisponibilidadesNaoMapeadas,
      identidadesCanonicasDuplicadas: duplicidadesUid.toList()..sort(),
      identidadesInconsistentes: identidadesInconsistentes,
    );
  }

  static _ResolucaoPessoa _resolverPessoa({
    required String usuarioId,
    required String membroEquipeId,
    required Map<String, String> chavePorUid,
    required Map<String, String> chavePorMembro,
  }) {
    final uid = usuarioId.trim();
    final membroId = membroEquipeId.trim();

    final porUid = uid.isEmpty ? null : chavePorUid[uid];
    final porMembro = membroId.isEmpty ? null : chavePorMembro[membroId];

    if (porUid != null && porMembro != null && porUid != porMembro) {
      return _ResolucaoPessoa(chave: porUid, inconsistente: true);
    }

    return _ResolucaoPessoa(chave: porUid ?? porMembro, inconsistente: false);
  }

  static bool _abrangeDia(EscalaIndisponibilidadeModel item, DateTime dia) {
    final inicio = _somenteData(item.dataInicio);
    final fim = _somenteData(item.dataFim);
    if (fim.isBefore(inicio)) return false;
    return !dia.isBefore(inicio) && !dia.isAfter(fim);
  }

  static DateTime _somenteData(DateTime valor) =>
      DateTime(valor.year, valor.month, valor.day);
}

class _ResolucaoPessoa {
  const _ResolucaoPessoa({required this.chave, required this.inconsistente});

  final String? chave;
  final bool inconsistente;
}

class _AgenteBuilder {
  _AgenteBuilder({
    required this.chavePessoa,
    required this.membroEquipeId,
    required this.usuarioId,
    required this.nome,
    required this.cargaHorariaCodigo,
    required this.identidadeCanonica,
  });

  final String chavePessoa;
  final String membroEquipeId;
  final String usuarioId;
  final String nome;
  final String cargaHorariaCodigo;
  final bool identidadeCanonica;

  int quantidadeAlocacoes = 0;
  final Set<String> tiposIndisponibilidade = <String>{};
  bool emAtividadeEducativa = false;
  bool emAdministrativoApoio = false;

  EscalaConferenciaAgente build() {
    return EscalaConferenciaAgente(
      chavePessoa: chavePessoa,
      membroEquipeId: membroEquipeId,
      usuarioId: usuarioId,
      nome: nome,
      cargaHorariaCodigo: cargaHorariaCodigo,
      identidadeCanonica: identidadeCanonica,
      quantidadeAlocacoes: quantidadeAlocacoes,
      tiposIndisponibilidade: tiposIndisponibilidade,
      emAtividadeEducativa: emAtividadeEducativa,
      emAdministrativoApoio: emAdministrativoApoio,
    );
  }
}
