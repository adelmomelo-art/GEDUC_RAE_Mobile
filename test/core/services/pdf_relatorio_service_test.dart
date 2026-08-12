import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/pdf_relatorio_service.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preserva o tipo de público no rascunho serializado', () {
    final acao = _acaoCompleta().copyWith(tipoPublicoId: 'interno');

    final restaurada = AcaoModel.fromMap(acao.toMap());

    expect(restaurada.tipoPublicoId, 'interno');
  });

  test('gera relatório RAE sem fotos e preserva espaços de evidências',
      () async {
    final acao = _acaoCompleta().copyWith(fotosUrls: const []);
    final bytes = await PdfRelatorioService().gerarBytes(
      acao,
      catalogos: _catalogos,
    );

    _validarPdf(bytes);
    await _salvarAmostra('RAE_CENARIO_SEM_FOTOS.pdf', bytes);
  });

  test('gera relatório RAE com três evidências fotográficas', () async {
    final temporario = await Directory.systemTemp.createTemp('rae-fotos-');
    addTearDown(() => temporario.delete(recursive: true));
    final fotos = await _criarFotosTemporarias(temporario);
    final acao = _acaoCompleta().copyWith(fotosUrls: fotos);

    final bytes = await PdfRelatorioService().gerarBytes(
      acao,
      catalogos: _catalogos,
    );

    _validarPdf(bytes);
    await _salvarAmostra('RAE_CENARIO_TRES_FOTOS.pdf', bytes);
  });

  test('gera relatório RAE com textos extensos sem falhar', () async {
    final acao = _acaoCompleta().copyWith(
      nomeAcao:
          'Oficina educativa integrada de mobilidade segura para comunidades escolares e usuários vulneráveis das vias urbanas',
      nomeLocal:
          'Área ampliada de convivência, educação cidadã e demonstrações práticas de segurança no trânsito',
      equipamentoReferencia:
          'Centro comunitário municipal de formação e atendimento integrado à população',
      pontoReferencia:
          'Ao lado do terminal de transporte coletivo, próximo à entrada principal da praça e do posto de atendimento',
      instituicaoParceira:
          'Escola Municipal Modelo, associação comunitária local e rede de proteção social do território',
      pontosPositivos:
          'A participação foi contínua, houve integração entre agentes, educadores e comunidade, e o público demonstrou compreensão das orientações apresentadas.',
      dificuldadesEncontradas:
          'O fluxo intenso de veículos, a interferência sonora e a mudança repentina das condições climáticas exigiram reorganização operacional durante a atividade.',
      recomendacoes:
          'Reservar área protegida, ampliar a sinalização, antecipar a montagem dos equipamentos e manter equipe de apoio para orientar a circulação no entorno.',
      descricaoEvidencias:
          'Registros detalhados da preparação, da equipe, do público participante, das demonstrações práticas e da organização territorial da atividade educativa.',
    );

    final bytes = await PdfRelatorioService().gerarBytes(
      acao,
      catalogos: _catalogos,
    );

    _validarPdf(bytes);
    await _salvarAmostra('RAE_CENARIO_TEXTOS_EXTENSOS.pdf', bytes);
  });
}

void _validarPdf(Uint8List bytes) {
  expect(bytes.length, greaterThan(10000));
  expect(String.fromCharCodes(bytes.take(4)), '%PDF');
}

Future<void> _salvarAmostra(String nome, Uint8List bytes) async {
  final diretorio = Platform.environment['RAE_PDF_SAMPLE_DIR'];

  if (diretorio != null && diretorio.isNotEmpty) {
    final arquivo = File('$diretorio${Platform.pathSeparator}$nome');
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsBytes(bytes);
    return;
  }

  final destinoLegado = Platform.environment['RAE_PDF_SAMPLE_PATH'];
  if (destinoLegado != null && destinoLegado.isNotEmpty) {
    final arquivo = File(destinoLegado);
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsBytes(bytes);
  }
}

Future<List<String>> _criarFotosTemporarias(Directory diretorio) async {
  const assets = [
    'assets/images/faixita_home_operacional.png',
    'assets/images/faixita_login.png',
    'assets/images/header_timbrado.png',
  ];
  final caminhos = <String>[];

  for (var indice = 0; indice < assets.length; indice++) {
    final data = await rootBundle.load(assets[indice]);
    final arquivo = File(
      '${diretorio.path}${Platform.pathSeparator}foto_${indice + 1}.png',
    );
    await arquivo.writeAsBytes(data.buffer.asUint8List());
    caminhos.add(arquivo.path);
  }

  return caminhos;
}

AcaoModel _acaoCompleta() {
  return AcaoModel(
    id: 'acao-amostra-001',
    numeroRAE: '2026/0088',
    anoRAE: 2026,
    dataAcao: DateTime(2026, 8, 8),
    turno: 'Manhã',
    nomeAcao: 'Oficina educativa de mobilidade segura',
    tipoAcao: 'Ação educativa',
    publicoEstimado: 120,
    publicoMinimo: 80,
    acaoPlanejada: true,
    horaInicio: '08:00',
    horaFinal: '11:30',
    pessoasAlcancadas: 138,
    veiculosAbordados: 42,
    credenciaisEmitidas: 18,
    metaAtingida: true,
    endereco: 'Avenida Beira-Mar, 2600',
    bairro: 'Meireles',
    regional: 'Regional 2',
    equipamentoReferencia: 'Praça dos Estressados',
    nomeLocal: 'Área de convivência da Beira-Mar',
    pontoReferencia: 'Próximo ao anfiteatro',
    latitude: -3.725421,
    longitude: -38.489112,
    origemLocalizacao: OrigemLocalizacao.gps,
    precisaoGps: 4.8,
    dataHoraCaptura: DateTime(2026, 8, 8, 8, 2),
    localizacaoValidada: true,
    fatorRiscoIds: const ['velocidade', 'celular'],
    mudancaComportamentoId: 'sim',
    formacaoId: 'oficina',
    tipoPublicoId: 'externo',
    publicoId: 'externo',
    tipoParticipacaoIds: const ['presencial'],
    focoTematicoIds: const ['mobilidade', 'seguranca'],
    perfilUsuarioIds: const ['pedestre', 'ciclista'],
    sexoPredominanteId: 'misto',
    instituicaoParceira: 'Escola Municipal Modelo',
    coordenadorId: 'coord-001',
    coordenadorNome: 'Maria da Silva',
    agentesTransito: 4,
    equipeTerceirizada: 2,
    materialUtilizadoIds: const ['cones', 'folhetos'],
    coberturaMidia: true,
    houveParticipacaoOutroOrgao: true,
    orgaoParticipanteId: 'orgao_amc',
    orgaoParticipanteIds: const [
      'orgao_amc',
      'orgao_samu',
      'orgao_prf',
      'orgao_pre',
    ],
    notaAvaliacao: 5,
    pontosPositivos:
        'Boa participação do público e integração entre as equipes.',
    dificuldadesEncontradas:
        'Ruído externo durante parte da oficina e fluxo intenso no entorno.',
    recomendacoes:
        'Reservar área com menor interferência sonora e ampliar a sinalização.',
    descricaoEvidencias:
        'Registros da equipe, do público participante e das atividades práticas.',
    status: 'concluido',
    sincronizado: true,
  );
}

const RaeCatalogos _catalogos = {
  'formacao': {'oficina': 'Oficina'},
  'publico': {'externo': 'Público externo'},
  'tipo_participacao': {'presencial': 'Presencial'},
  'perfil_usuario': {
    'pedestre': 'Pedestre',
    'ciclista': 'Ciclista',
  },
  'sexo_predominante': {'misto': 'Misto'},
  'foco_tematico': {
    'mobilidade': 'Mobilidade segura',
    'seguranca': 'Segurança viária',
  },
  'fator_risco': {
    'velocidade': 'Excesso de velocidade',
    'celular': 'Uso de celular',
  },
  'mudanca_comportamento': {'sim': 'Sim, observada'},
  'material': {
    'cones': 'Cones',
    'folhetos': 'Folhetos educativos',
  },
  'orgao': {
    'amc': 'AMC',
    'samu': 'SAMU',
    'prf': 'PRF',
    'pre': 'PRE',
  },
};
