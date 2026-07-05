class FaxitaInsight {
  final String titulo;
  final String mensagem;
  final String rotaCorrecao;
  final String severidade;

  const FaxitaInsight({
    required this.titulo,
    required this.mensagem,
    required this.rotaCorrecao,
    required this.severidade,
  });
}

class FaxitaInsightsService {
  String classificarNivelRae(int indiceQualidade) {
    if (indiceQualidade >= 95) {
      return 'Diamante';
    }

    if (indiceQualidade >= 85) {
      return 'Ouro';
    }

    if (indiceQualidade >= 70) {
      return 'Prata';
    }

    return 'Bronze';
  }

  String emojiNivelRae(int indiceQualidade) {
    if (indiceQualidade >= 95) {
      return '💎';
    }

    if (indiceQualidade >= 85) {
      return '🥇';
    }

    if (indiceQualidade >= 70) {
      return '🥈';
    }

    return '🥉';
  }

  String parecerExecutivo({
    required int indiceQualidade,
    required String classificacao,
  }) {
    if (indiceQualidade >= 95) {
      return 'Faxita considera este RAE de nível Diamante. O relatório está muito bem documentado e apresenta alta consistência operacional.';
    }

    if (indiceQualidade >= 85) {
      return 'Faxita considera este RAE de nível Ouro. O relatório está consistente e pronto para envio, com poucos pontos de melhoria.';
    }

    if (indiceQualidade >= 70) {
      return 'Faxita considera este RAE de nível Prata. O relatório está apto para envio, mas pode ser aprimorado nos próximos registros.';
    }

    return 'Faxita considera este RAE de nível Bronze. Recomenda-se revisar os principais alertas antes do envio definitivo.';
  }

  List<FaxitaInsight> priorizarAlertas(List<String> alertas) {
    return alertas.map((alerta) {
      final texto = alerta.toLowerCase();

      if (texto.contains('localização') ||
          texto.contains('evidência') ||
          texto.contains('nenhuma') ||
          texto.contains('planejamento incompleto')) {
        return FaxitaInsight(
          titulo: 'Alerta crítico',
          mensagem: alerta,
          rotaCorrecao: _rotaParaAlerta(texto),
          severidade: 'critico',
        );
      }

      if (texto.contains('meta') ||
          texto.contains('caracterização') ||
          texto.contains('recursos') ||
          texto.contains('indicadores')) {
        return FaxitaInsight(
          titulo: 'Alerta importante',
          mensagem: alerta,
          rotaCorrecao: _rotaParaAlerta(texto),
          severidade: 'importante',
        );
      }

      return FaxitaInsight(
        titulo: 'Sugestão',
        mensagem: alerta,
        rotaCorrecao: _rotaParaAlerta(texto),
        severidade: 'sugestao',
      );
    }).toList();
  }

  String _rotaParaAlerta(String alerta) {
    if (alerta.contains('planejamento')) {
      return '/nova-acao';
    }

    if (alerta.contains('localização')) {
      return '/localizacao';
    }

    if (alerta.contains('caracterização')) {
      return '/caracterizacao';
    }

    if (alerta.contains('recursos')) {
      return '/recursos-operacionais';
    }

    if (alerta.contains('meta') ||
        alerta.contains('indicadores') ||
        alerta.contains('pessoas')) {
      return '/resultados';
    }

    if (alerta.contains('evidência') ||
        alerta.contains('foto') ||
        alerta.contains('fotográfica')) {
      return '/evidencias';
    }

    return '/revisao';
  }
}
