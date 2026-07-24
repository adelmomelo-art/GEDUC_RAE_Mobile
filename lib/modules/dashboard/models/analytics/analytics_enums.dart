enum RankingCategoria {
  regional,
  coordenador,
  projeto,
  tipoAcao,
  escola,
  empresa,
  parceiro,
  outro,
}

enum TendenciaIndicador {
  crescimento,
  estabilidade,
  queda,
  indisponivel,
}

enum StatusIndicador {
  excelente,
  adequado,
  atencao,
  critico,
  indisponivel,
}

enum NivelAlerta {
  informativo,
  baixo,
  medio,
  alto,
  critico,
}

enum NivelCriticidade {
  baixa,
  moderada,
  alta,
  critica,
}

enum PrioridadeAnalise {
  baixa,
  normal,
  alta,
  urgente,
}

enum InsightCategoria {
  produtividade,
  eficiencia,
  alcance,
  cobertura,
  meta,
  tendencia,
  desempenho,
  qualidade,
  outro,
}

enum TipoAlertaOperacional {
  desempenho,
  meta,
  produtividade,
  cobertura,
  quedaAtividade,
  inconsistencias,
  sincronizacao,
  outro,
}

enum OrigemAnalise {
  dashboard,
  cio,
  faxita,
  relatorio,
  bi,
  sistema,
}
