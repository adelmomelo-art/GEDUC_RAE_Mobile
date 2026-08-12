import '../../data/models/acao_model.dart';

class FaxitaReviewResult {
  final int indiceQualidade;
  final String classificacao;
  final String parecer;
  final List<String> pontosFortes;
  final List<String> alertas;
  final List<String> recomendacoes;

  const FaxitaReviewResult({
    required this.indiceQualidade,
    required this.classificacao,
    required this.parecer,
    required this.pontosFortes,
    required this.alertas,
    required this.recomendacoes,
  });
}

class FaxitaReviewService {
  FaxitaReviewResult revisar(AcaoModel acao) {
    final pontosFortes = <String>[];
    final alertas = <String>[];
    final recomendacoes = <String>[];

    var pontos = 0;

    if (_planejamentoCompleto(acao)) {
      pontos += 10;
      pontosFortes.add('Planejamento básico preenchido.');
    } else {
      alertas.add('Planejamento incompleto.');
      recomendacoes.add('Revise tipo da ação, turno, coordenador e público.');
    }

    if (_localizacaoValida(acao)) {
      pontos += 10;
      pontosFortes.add('Localização registrada com equipamento de referência.');
    } else {
      alertas.add('Localização incompleta.');
      recomendacoes.add('Confirme endereço, bairro, regional e equipamento.');
    }

    if (_caracterizacaoCompleta(acao)) {
      pontos += 15;
      pontosFortes.add('Caracterização da ação preenchida.');
    } else {
      alertas.add('Caracterização incompleta.');
      recomendacoes.add(
          'Revise formação, público, perfil, foco temático e fatores de risco.');
    }

    if (_recursosPreenchidos(acao)) {
      pontos += 10;
      pontosFortes.add('Recursos operacionais informados.');
    } else {
      alertas.add('Recursos operacionais incompletos.');
      recomendacoes.add('Informe equipe e materiais utilizados.');
    }

    if (acao.houveParticipacaoOutroOrgao &&
        acao.orgaosParticipantesEfetivos.isNotEmpty) {
      pontos += 10;
      pontosFortes.add('Integração institucional registrada.');
    } else if (!acao.houveParticipacaoOutroOrgao) {
      pontos += 5;
      alertas.add('Não houve participação de outro órgão.');
      recomendacoes.add('Quando possível, registre parcerias institucionais.');
    } else {
      alertas.add(
          'Foi marcada participação de outro órgão, mas o órgão não foi informado.');
      recomendacoes.add('Informe qual órgão participou da ação.');
    }

    if (acao.metaAtingida) {
      pontos += 15;
      pontosFortes.add('Meta mínima atingida.');
    } else {
      alertas.add('Meta mínima não atingida.');
      recomendacoes.add('Registre e analise o motivo da meta não atingida.');

      if ((acao.motivoMetaNaoAtingida ?? '').trim().isNotEmpty) {
        pontos += 7;
      }
    }

    if (acao.fotosUrls.length >= 3) {
      pontos += 15;
      pontosFortes.add('Conjunto fotográfico recomendado anexado.');
    } else if (acao.fotosUrls.isNotEmpty) {
      pontos += 8;
      alertas.add('Foram anexadas poucas fotos.');
      recomendacoes.add(
          'Sempre que possível, anexe fotos da equipe, do público e do contexto.');
    } else {
      alertas.add('Nenhuma evidência fotográfica anexada.');
      recomendacoes.add('Inclua evidências fotográficas da ação.');
    }

    if (acao.descricaoEvidencias.trim().length >= 10) {
      pontos += 5;
      pontosFortes.add('Descrição das evidências preenchida.');
    } else {
      alertas.add('Descrição das evidências ausente ou muito curta.');
      recomendacoes.add('Descreva o conteúdo das evidências anexadas.');
    }

    if (_kpisConsistentes(acao)) {
      pontos += 10;
      pontosFortes.add('Indicadores básicos consistentes.');
    } else {
      alertas.add('Indicadores operacionais exigem atenção.');
      recomendacoes
          .add('Revise público estimado, público mínimo e pessoas alcançadas.');
    }

    if (pontos > 100) {
      pontos = 100;
    }

    return FaxitaReviewResult(
      indiceQualidade: pontos,
      classificacao: _classificar(pontos),
      parecer: _gerarParecer(pontos),
      pontosFortes: pontosFortes,
      alertas: alertas,
      recomendacoes: recomendacoes,
    );
  }

  bool _planejamentoCompleto(AcaoModel acao) {
    return acao.turno.isNotEmpty &&
        acao.nomeAcao.isNotEmpty &&
        acao.tipoAcao.isNotEmpty &&
        acao.coordenadorNome.isNotEmpty &&
        acao.publicoEstimado > 0 &&
        acao.publicoMinimo > 0;
  }

  bool _localizacaoValida(AcaoModel acao) {
    return acao.endereco.isNotEmpty &&
        acao.bairro.isNotEmpty &&
        acao.regional.isNotEmpty &&
        acao.equipamentoReferencia.isNotEmpty &&
        acao.latitude != 0 &&
        acao.longitude != 0;
  }

  bool _caracterizacaoCompleta(AcaoModel acao) {
    return acao.formacaoId.isNotEmpty &&
        acao.publicoId.isNotEmpty &&
        acao.tipoParticipacaoIds.isNotEmpty &&
        acao.focoTematicoIds.isNotEmpty &&
        acao.perfilUsuarioIds.isNotEmpty &&
        acao.sexoPredominanteId.isNotEmpty &&
        acao.mudancaComportamentoId.isNotEmpty &&
        acao.fatorRiscoIds.isNotEmpty;
  }

  bool _recursosPreenchidos(AcaoModel acao) {
    return (acao.agentesTransito + acao.equipeTerceirizada) > 0 &&
        acao.materialUtilizadoIds.isNotEmpty;
  }

  bool _kpisConsistentes(AcaoModel acao) {
    return acao.pessoasAlcancadas > 0 &&
        acao.publicoMinimo > 0 &&
        acao.publicoEstimado > 0;
  }

  String _classificar(int pontos) {
    if (pontos < 40) {
      return 'Crítico';
    }

    if (pontos < 70) {
      return 'Regular';
    }

    if (pontos < 90) {
      return 'Bom';
    }

    return 'Excelente';
  }

  String _gerarParecer(int pontos) {
    if (pontos >= 90) {
      return 'Faxita considera que o relatório apresenta excelente consistência operacional e está bem documentado para envio.';
    }

    if (pontos >= 70) {
      return 'Faxita considera que o relatório está apto para envio, mas recomenda observar os alertas para melhorar os próximos registros.';
    }

    if (pontos >= 40) {
      return 'Faxita identificou pontos de atenção. Recomenda-se revisar o relatório antes do envio definitivo.';
    }

    return 'Faxita identificou baixa consistência no relatório. Recomenda-se revisar os dados essenciais antes do envio.';
  }
}
