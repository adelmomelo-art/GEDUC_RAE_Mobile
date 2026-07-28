abstract final class DomainGroups {
  static const String formacao = 'formacao';
  static const String publico = 'publico';
  static const String perfilUsuario = 'perfil_usuario';
  static const String tipoParticipacao = 'tipo_participacao';
  static const String focoTematico = 'foco_tematico';
  static const String fatorRisco = 'fator_risco';
  static const String material = 'material';
  static const String orgao = 'orgao';
  static const String sexoPredominante = 'sexo_predominante';
  static const String mudancaComportamento = 'mudanca_comportamento';

  static const List<String> caracterizacaoAcao = [
    formacao,
    publico,
    perfilUsuario,
    tipoParticipacao,
    focoTematico,
    fatorRisco,
    sexoPredominante,
    mudancaComportamento,
  ];

  static const List<String> todos = [
    formacao,
    publico,
    perfilUsuario,
    tipoParticipacao,
    focoTematico,
    fatorRisco,
    material,
    orgao,
    sexoPredominante,
    mudancaComportamento,
  ];

  static const Map<String, String> nomes = {
    formacao: 'Formação',
    publico: 'Público',
    perfilUsuario: 'Perfil do usuário',
    tipoParticipacao: 'Tipo de participação',
    focoTematico: 'Foco temático',
    fatorRisco: 'Fatores de risco',
    material: 'Materiais',
    orgao: 'Órgãos parceiros',
    sexoPredominante: 'Sexo predominante',
    mudancaComportamento: 'Mudança de comportamento',
  };

  static String nomeDoGrupo(String grupo) {
    return nomes[grupo] ?? grupo;
  }

  static bool existe(String grupo) {
    return todos.contains(grupo);
  }
}
