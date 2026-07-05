class KpiService {
  static double calcularPercentual({
    required int realizado,
    required int referencia,
  }) {
    if (referencia <= 0) {
      return 0;
    }

    return realizado / referencia;
  }

  static double calcularPessoasPorEquipe({
    required int pessoasAlcancadas,
    required int agentesTransito,
    required int equipeTerceirizada,
  }) {
    final totalEquipe = agentesTransito + equipeTerceirizada;

    if (totalEquipe <= 0) {
      return 0;
    }

    return pessoasAlcancadas / totalEquipe;
  }

  static double calcularPessoasPorVeiculo({
    required int pessoasAlcancadas,
    required int veiculosAbordados,
  }) {
    if (veiculosAbordados <= 0) {
      return 0;
    }

    return pessoasAlcancadas / veiculosAbordados;
  }

  static int calcularIndiceOperacional({
    required bool metaAtingida,
    required bool possuiEvidencias,
    required bool acaoPlanejada,
    required bool houveParticipacaoOutroOrgao,
    required bool coberturaMidia,
  }) {
    var pontos = 0;

    if (metaAtingida) pontos += 30;
    if (possuiEvidencias) pontos += 20;
    if (acaoPlanejada) pontos += 20;
    if (houveParticipacaoOutroOrgao) pontos += 15;
    if (coberturaMidia) pontos += 15;

    return pontos;
  }

  static String classificarMeta(double percentual) {
    final valor = percentual * 100;

    if (valor < 60) {
      return 'Crítico';
    }

    if (valor < 90) {
      return 'Regular';
    }

    if (valor < 100) {
      return 'Bom';
    }

    return 'Excelente';
  }

  static String classificarPlanejamento(double percentual) {
    final valor = percentual * 100;

    if (valor < 40) {
      return 'Muito abaixo do planejado';
    }

    if (valor < 70) {
      return 'Abaixo do esperado';
    }

    if (valor <= 100) {
      return 'Bom aproveitamento';
    }

    return 'Acima do planejado';
  }

  static String classificarIndiceOperacional(int indice) {
    if (indice < 40) {
      return 'Baixa consistência operacional';
    }

    if (indice < 70) {
      return 'Consistência operacional moderada';
    }

    if (indice < 90) {
      return 'Boa consistência operacional';
    }

    return 'Excelente consistência operacional';
  }

  static String formatarPercentual(double percentual) {
    return '${(percentual * 100).toStringAsFixed(1)}%';
  }

  static String formatarDecimal(double valor) {
    return valor.toStringAsFixed(1);
  }

  static String gerarAnaliseFaxita({
    required bool metaAtingida,
    required double percentualMeta,
    required double percentualPlanejamento,
    required double pessoasPorEquipe,
    required int indiceOperacional,
  }) {
    if (!metaAtingida && percentualMeta >= 0.9) {
      return 'Faxita observou que a ação ficou próxima da meta mínima. Vale registrar o principal fator que impediu o alcance total.';
    }

    if (metaAtingida && percentualPlanejamento < 0.5) {
      return 'Faxita observou que a meta mínima foi atingida, mas o alcance ficou baixo em relação ao público estimado. O planejamento pode ser revisado.';
    }

    if (pessoasPorEquipe > 40) {
      return 'Faxita observou boa eficiência da equipe em relação ao público alcançado.';
    }

    if (indiceOperacional >= 90) {
      return 'Faxita identificou alta consistência operacional: planejamento, evidências e integração estão bem registrados.';
    }

    if (indiceOperacional < 40) {
      return 'Faxita recomenda revisar planejamento, evidências e integração institucional para fortalecer a qualidade do registro.';
    }

    return 'Faxita registrou os indicadores da ação e recomenda observar se os resultados estão coerentes com o planejamento inicial.';
  }
}
