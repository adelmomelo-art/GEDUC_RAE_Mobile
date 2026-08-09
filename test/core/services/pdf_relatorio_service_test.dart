import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/pdf_relatorio_service.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gera relatório RAE ampliado em PDF', () async {
    final acao = _acaoCompleta();
    final bytes = await PdfRelatorioService().gerarBytes(
      acao,
      catalogos: _catalogos,
    );

    expect(bytes.length, greaterThan(10000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');

    final destino = Platform.environment['RAE_PDF_SAMPLE_PATH'];
    if (destino != null && destino.isNotEmpty) {
      final arquivo = File(destino);
      await arquivo.parent.create(recursive: true);
      await arquivo.writeAsBytes(bytes);
    }
  });
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
    orgaoParticipanteId: 'amc',
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
  'orgao': {'amc': 'AMC'},
};
