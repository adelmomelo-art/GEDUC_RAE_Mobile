import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaCompromisso {
  const AgendaCompromisso({
    required this.id,
    required this.data,
    required this.titulo,
    required this.turno,
    this.instituicao = '',
    this.projetoId = '',
    this.natureza = 'educativa',
    this.secaoId = 'comandos_tematicos',
    this.horaInicio = '',
    this.horaFim = '',
    this.local = '',
    this.endereco = '',
    this.bairro = '',
    this.regionalId = '',
    this.referencia = '',
    this.contatoNome = '',
    this.contatoTelefone = '',
    this.descricao = '',
    this.publico = '',
    this.quantidadePublico,
    this.integrantesNecessarios,
    this.materiais = '',
    this.observacoesInternas = '',
    this.orientacaoEquipe = '',
    this.origem = 'contato_direto',
    this.processo = '',
    this.situacao = 'planejamento',
    this.motivo = '',
    this.revisao = 0,
    this.escalaId = '',
    this.atividadeId = '',
    this.dataVinculada,
    this.criadoPor = '',
    this.criadoEm,
    this.atualizadoPor = '',
    this.atualizadoEm,
  });

  final String id, titulo, turno, instituicao, projetoId, natureza, secaoId;
  final String horaInicio,
      horaFim,
      local,
      endereco,
      bairro,
      regionalId,
      referencia;
  final String contatoNome, contatoTelefone, descricao, publico, materiais;
  final String observacoesInternas, orientacaoEquipe, origem, processo;
  final String situacao,
      motivo,
      escalaId,
      atividadeId,
      criadoPor,
      atualizadoPor;
  final DateTime data;
  final DateTime? dataVinculada, criadoEm, atualizadoEm;
  final int revisao;
  final int? quantidadePublico, integrantesNecessarios;

  bool get vinculada => atividadeId.isNotEmpty;
  bool get cancelada => situacao == 'cancelada';
  bool get pronta => situacao == 'pronta';
  bool get horarioACombinar => horaInicio.isEmpty && horaFim.isEmpty;

  Map<String, dynamic> toMap() => {
        'data': Timestamp.fromDate(DateTime(data.year, data.month, data.day)),
        'titulo': titulo.trim(),
        'turno': turno,
        'instituicao': instituicao.trim(),
        'projetoId': projetoId,
        'natureza': natureza,
        'secaoId': secaoId,
        'horaInicio': horaInicio.trim(),
        'horaFim': horaFim.trim(),
        'local': local.trim(),
        'endereco': endereco.trim(),
        'bairro': bairro.trim(),
        'regionalId': regionalId,
        'referencia': referencia.trim(),
        'contatoNome': contatoNome.trim(),
        'contatoTelefone': contatoTelefone.trim(),
        'descricao': descricao.trim(),
        'publico': publico.trim(),
        'quantidadePublico': quantidadePublico,
        'integrantesNecessarios': integrantesNecessarios,
        'materiais': materiais.trim(),
        'observacoesInternas': observacoesInternas.trim(),
        'orientacaoEquipe': orientacaoEquipe.trim(),
        'origem': origem,
        'processo': processo.trim(),
        'situacao': situacao,
        'motivo': motivo.trim(),
        'revisao': revisao,
        'escalaId': escalaId,
        'atividadeId': atividadeId,
        'dataVinculada':
            dataVinculada == null ? null : Timestamp.fromDate(dataVinculada!),
        'criadoPor': criadoPor,
        'criadoEm': criadoEm == null ? null : Timestamp.fromDate(criadoEm!),
        'atualizadoPor': atualizadoPor,
        'atualizadoEm':
            atualizadoEm == null ? null : Timestamp.fromDate(atualizadoEm!),
      };

  factory AgendaCompromisso.fromMap(String id, Map<String, dynamic> m) {
    String s(String key, [String fallback = '']) =>
        m[key]?.toString() ?? fallback;
    DateTime? d(String key) => switch (m[key]) {
          Timestamp value => value.toDate(),
          DateTime value => value,
          _ => null,
        };
    int? n(String key) => m[key] is int ? m[key] as int : null;
    return AgendaCompromisso(
      id: id,
      data: d('data') ?? DateTime(1970),
      titulo: s('titulo'),
      turno: s('turno'),
      instituicao: s('instituicao'),
      projetoId: s('projetoId'),
      natureza: s('natureza', 'educativa'),
      secaoId: s('secaoId', 'comandos_tematicos'),
      horaInicio: s('horaInicio'),
      horaFim: s('horaFim'),
      local: s('local'),
      endereco: s('endereco'),
      bairro: s('bairro'),
      regionalId: s('regionalId'),
      referencia: s('referencia'),
      contatoNome: s('contatoNome'),
      contatoTelefone: s('contatoTelefone'),
      descricao: s('descricao'),
      publico: s('publico'),
      quantidadePublico: n('quantidadePublico'),
      integrantesNecessarios: n('integrantesNecessarios'),
      materiais: s('materiais'),
      observacoesInternas: s('observacoesInternas'),
      orientacaoEquipe: s('orientacaoEquipe'),
      origem: s('origem', 'contato_direto'),
      processo: s('processo'),
      situacao: s('situacao', 'planejamento'),
      motivo: s('motivo'),
      revisao: n('revisao') ?? 0,
      escalaId: s('escalaId'),
      atividadeId: s('atividadeId'),
      dataVinculada: d('dataVinculada'),
      criadoPor: s('criadoPor'),
      criadoEm: d('criadoEm'),
      atualizadoPor: s('atualizadoPor'),
      atualizadoEm: d('atualizadoEm'),
    );
  }

  AgendaCompromisso alterar(Map<String, dynamic> campos) =>
      AgendaCompromisso.fromMap(id, {...toMap(), ...campos});
}

class AgendaHistorico {
  const AgendaHistorico({
    required this.acao,
    required this.usuarioId,
    required this.motivo,
    required this.revisao,
    required this.em,
    this.dataAnterior,
    this.dataNova,
  });
  final String acao, usuarioId, motivo;
  final int revisao;
  final DateTime em;
  final DateTime? dataAnterior, dataNova;
}
