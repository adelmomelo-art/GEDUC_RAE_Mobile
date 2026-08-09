import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/acao_model.dart';
import '../domains/domain_groups.dart';
import '../domains/domain_provider.dart';
import 'faxita_insights_service.dart';
import 'faxita_review_service.dart';

typedef RaeCatalogos = Map<String, Map<String, String>>;

class PdfRelatorioService {
  static const _azul = PdfColor.fromInt(0xFF154C68);
  static const _verde = PdfColor.fromInt(0xFF008F83);
  static const _verdeClaro = PdfColor.fromInt(0xFFE8F5F2);
  static const _cinza = PdfColor.fromInt(0xFF4B5563);
  static const _cinzaClaro = PdfColor.fromInt(0xFFF1F4F5);
  static const _amarelo = PdfColor.fromInt(0xFFFFF4CF);

  final FaxitaReviewService _reviewService;
  final FaxitaInsightsService _insightsService;

  PdfRelatorioService({
    FaxitaReviewService? reviewService,
    FaxitaInsightsService? insightsService,
  })  : _reviewService = reviewService ?? FaxitaReviewService(),
        _insightsService = insightsService ?? FaxitaInsightsService();

  static RaeCatalogos catalogosDe(DomainProvider provider) {
    return {
      for (final grupo in DomainGroups.todos)
        grupo: provider.opcoesDoGrupo(grupo),
    };
  }

  Future<void> gerarRelatorioAcao(
    AcaoModel acao, {
    RaeCatalogos catalogos = const {},
  }) async {
    final bytes = await gerarBytes(acao, catalogos: catalogos);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> compartilharRelatorio(
    AcaoModel acao, {
    RaeCatalogos catalogos = const {},
  }) async {
    final bytes = await gerarBytes(acao, catalogos: catalogos);
    final diretorio = await getTemporaryDirectory();
    final numeroSeguro = acao.numeroRAE
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(' ', '_');
    final arquivo = File('${diretorio.path}/RAE_$numeroSeguro.pdf');
    await arquivo.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        text: 'Relatório RAE ${acao.numeroRAE}',
        files: [XFile(arquivo.path)],
      ),
    );
  }

  Future<Uint8List> gerarBytes(
    AcaoModel acao, {
    RaeCatalogos catalogos = const {},
  }) async {
    final pdf = await _criarDocumentoPdf(acao, catalogos);
    return pdf.save();
  }

  Future<pw.Document> _criarDocumentoPdf(
    AcaoModel acao,
    RaeCatalogos catalogos,
  ) async {
    final pdf = pw.Document(
      title: 'Relatório de Ação Educativa - RAE ${acao.numeroRAE}',
      author: 'Plataforma Fênix - GEDUC',
      subject: 'Relatório timbrado da Gerência de Educação',
    );
    final assinaturaConjunta = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/assinatura_conjunta_amc_pmf.png',
      ))
          .buffer
          .asUint8List(),
    );
    final rodape = pw.MemoryImage(
      (await rootBundle.load('assets/images/footer_timbrado.png'))
          .buffer
          .asUint8List(),
    );
    final faixita = pw.MemoryImage(
      (await rootBundle.load('assets/images/faixita_home_operacional.png'))
          .buffer
          .asUint8List(),
    );
    final fotos = await _carregarFotos(acao.fotosUrls);
    final review = _reviewService.revisar(acao);
    final nivel = _insightsService.classificarNivelRae(review.indiceQualidade);
    final parecer = _insightsService.parecerExecutivo(
      indiceQualidade: review.indiceQualidade,
      classificacao: review.classificacao,
    );

    pdf.addPage(
      _paginaTimbrada(
        pagina: 1,
        assinaturaConjunta: assinaturaConjunta,
        rodape: rodape,
        acao: acao,
        conteudo: _conteudoPagina1(acao, catalogos),
      ),
    );
    pdf.addPage(
      _paginaTimbrada(
        pagina: 2,
        assinaturaConjunta: assinaturaConjunta,
        rodape: rodape,
        acao: acao,
        conteudo: _conteudoPagina2(
          acao,
          review,
          nivel,
          parecer,
          faixita,
          fotos,
        ),
      ),
    );
    return pdf;
  }

  pw.Page _paginaTimbrada({
    required int pagina,
    required pw.MemoryImage assinaturaConjunta,
    required pw.MemoryImage rodape,
    required AcaoModel acao,
    required pw.Widget conteudo,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Stack(children: [
        pw.Positioned(
          top: 56.7,
          left: 0,
          right: 0,
          child: pw.Center(
            child: pw.Image(
              assinaturaConjunta,
              width: 245,
              height: 48,
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
        pw.Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: pw.Image(
            rodape,
            height: 80,
            fit: pw.BoxFit.fill,
          ),
        ),
        pw.Positioned(
          right: 42,
          bottom: 86,
          child: pw.Text(
            'RAE ${acao.numeroRAE}  |  Página $pagina',
            style: const pw.TextStyle(fontSize: 6.5, color: _cinza),
          ),
        ),
        pw.Positioned(
          top: 118,
          left: 38,
          right: 38,
          bottom: 100,
          child: conteudo,
        ),
      ]),
    );
  }

  pw.Widget _titulo(AcaoModel acao) {
    return pw.Column(children: [
      pw.Text(
        'RELATÓRIO DE AÇÃO EDUCATIVA - RAE Nº ${acao.numeroRAE}',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 13.5,
          color: _azul,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        'Relatório timbrado da Gerência de Educação para o Trânsito',
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 7.3, color: _cinza),
      ),
      pw.SizedBox(height: 8),
    ]);
  }

  pw.Widget _conteudoPagina1(AcaoModel acao, RaeCatalogos catalogos) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _titulo(acao),
          _cabecalhoSecao('01', 'Identificação e planejamento'),
          _grade3([
            _campo('Número RAE', acao.numeroRAE),
            _campo('Data da ação', _data(acao.dataAcao)),
            _campo('Nome da ação', acao.nomeAcao),
            _campo('Tipo da ação', acao.tipoAcao),
            _campo('Turno', acao.turno),
            _campo('Ação planejada', _simNao(acao.acaoPlanejada)),
            _campo('Público estimado', '${acao.publicoEstimado} pessoas'),
            _campo('Público mínimo', '${acao.publicoMinimo} pessoas'),
            _campo('Coordenador(a)', acao.coordenadorNome),
            _campo('Início', acao.horaInicio),
            _campo('Término', acao.horaFinal ?? ''),
            _campo('Status', acao.status),
          ]),
          _cabecalhoSecao('02', 'Localização'),
          _grade3([
            _campo('Local', acao.nomeLocal),
            _campo('Endereço', acao.endereco),
            _campo('Bairro', acao.bairro),
            _campo('Regional', acao.regional),
            _campo('Equipamento', acao.equipamentoReferencia),
            _campo('Ponto de referência', acao.pontoReferencia),
            _campo('Latitude', _coordenada(acao.latitude)),
            _campo('Longitude', _coordenada(acao.longitude)),
            _campo('Origem', acao.origemLocalizacao?.name ?? ''),
            _campo(
              'Precisão',
              acao.precisaoGps == null
                  ? ''
                  : '${acao.precisaoGps!.toStringAsFixed(1)} metros',
            ),
            _campo('Local validado', _simNao(acao.localizacaoValidada)),
            _campo(
              'Edição manual',
              _simNao(acao.localizacaoEditadaManualmente),
            ),
          ]),
          _cabecalhoSecao('03', 'Caracterização da ação'),
          _grade3([
            _campo('Formação', _nome(catalogos, 'formacao', acao.formacaoId)),
            _campo('Público-alvo', _nome(catalogos, 'publico', acao.publicoId)),
            _campo(
              'Participação',
              _nomes(
                catalogos,
                'tipo_participacao',
                acao.tipoParticipacaoIds,
              ),
            ),
            _campo(
              'Perfis atendidos',
              _nomes(catalogos, 'perfil_usuario', acao.perfilUsuarioIds),
            ),
            _campo(
              'Sexo predominante',
              _nome(
                catalogos,
                'sexo_predominante',
                acao.sexoPredominanteId,
              ),
            ),
            _campo(
              'Focos temáticos',
              _nomes(catalogos, 'foco_tematico', acao.focoTematicoIds),
            ),
            _campo(
              'Fatores de risco',
              _nomes(catalogos, 'fator_risco', acao.fatorRiscoIds),
            ),
            _campo(
              'Mudança observada',
              _nome(
                catalogos,
                'mudanca_comportamento',
                acao.mudancaComportamentoId,
              ),
            ),
            _campo('Instituição parceira', acao.instituicaoParceira),
          ]),
          _cabecalhoSecao('04', 'Recursos e integração institucional'),
          _grade3([
            _campo('Agentes de trânsito', '${acao.agentesTransito}'),
            _campo('Equipe terceirizada', '${acao.equipeTerceirizada}'),
            _campo(
              'Materiais',
              _nomes(catalogos, 'material', acao.materialUtilizadoIds),
            ),
            _campo('Cobertura de mídia', _simNao(acao.coberturaMidia)),
            _campo(
              'Outro órgão',
              _simNao(acao.houveParticipacaoOutroOrgao),
            ),
            _campo(
              'Órgão participante',
              acao.houveParticipacaoOutroOrgao
                  ? _nome(catalogos, 'orgao', acao.orgaoParticipanteId)
                  : 'Não se aplica',
            ),
          ]),
        ]);
  }

  pw.Widget _conteudoPagina2(
    AcaoModel acao,
    FaxitaReviewResult review,
    String nivel,
    String parecer,
    pw.MemoryImage faixita,
    List<pw.MemoryImage> fotos,
  ) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cabecalhoSecao('05', 'Resultados alcançados'),
          _metricas(acao),
          _cabecalhoSecao('06', 'Avaliação e aprendizagem operacional'),
          _avaliacao(acao),
          _cabecalhoSecao('07', 'Revisão inteligente da Faixita'),
          _revisaoFaixita(review, nivel, parecer, faixita),
          _cabecalhoSecao('08', 'Evidências e validação'),
          _evidencias(acao, fotos),
          pw.Spacer(),
          _validacaoEAssinaturas(acao),
        ]);
  }

  pw.Widget _cabecalhoSecao(String numero, String titulo) {
    return pw.Container(
      height: 21,
      margin: const pw.EdgeInsets.only(top: 3),
      color: _cinzaClaro,
      child: pw.Row(children: [
        pw.Container(
          width: 29,
          height: 21,
          color: _verde,
          alignment: pw.Alignment.center,
          child: pw.Text(
            numero,
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 9.5,
            color: _azul,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ]),
    );
  }

  pw.Widget _grade3(List<_CampoPdf> campos) {
    final linhas = <pw.TableRow>[];
    for (var i = 0; i < campos.length; i += 3) {
      final linha = campos.skip(i).take(3).toList();
      while (linha.length < 3) {
        linha.add(const _CampoPdf('', ''));
      }
      linhas.add(
        pw.TableRow(
          children: linha.map(_celulaCampo).toList(),
        ),
      );
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.white, width: 1.4),
      columnWidths: const {
        0: pw.FlexColumnWidth(),
        1: pw.FlexColumnWidth(),
        2: pw.FlexColumnWidth(),
      },
      children: linhas,
    );
  }

  pw.Widget _celulaCampo(_CampoPdf campo) {
    return pw.Container(
      height: 27,
      padding: const pw.EdgeInsets.fromLTRB(5, 4, 4, 3),
      color: _cinzaClaro,
      child:
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(
          campo.rotulo.toUpperCase(),
          maxLines: 1,
          style: pw.TextStyle(
            fontSize: 5.2,
            color: _verde,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          _textoCompacto(campo.valor, 82),
          maxLines: 2,
          style: pw.TextStyle(
            fontSize: _tamanhoFonteCompacta(campo.valor, normal: 7.1),
            color: _cinza,
          ),
        ),
      ]),
    );
  }

  pw.Widget _metricas(AcaoModel acao) {
    final itens = [
      ('Público estimado', acao.publicoEstimado),
      ('Público mínimo', acao.publicoMinimo),
      ('Pessoas alcançadas', acao.pessoasAlcancadas),
      ('Veículos abordados', acao.veiculosAbordados),
      ('Credenciais emitidas', acao.credenciaisEmitidas),
    ];
    return pw.Column(children: [
      pw.Row(
        children: itens
            .map(
              (item) => pw.Expanded(
                child: pw.Container(
                  height: 32,
                  margin: const pw.EdgeInsets.only(right: 1),
                  padding: const pw.EdgeInsets.fromLTRB(5, 4, 3, 3),
                  color: _cinzaClaro,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${item.$2}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _azul,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        item.$1,
                        style: pw.TextStyle(
                          fontSize: 5.2,
                          color: _verde,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
      pw.Container(
        width: double.infinity,
        height: 20,
        padding: const pw.EdgeInsets.fromLTRB(7, 5, 0, 0),
        color: acao.metaAtingida ? _verdeClaro : _amarelo,
        child: pw.Text(
          'Meta atingida: ${_simNao(acao.metaAtingida)}',
          style: pw.TextStyle(
            fontSize: 7.5,
            color: _azul,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ]);
  }

  pw.Widget _avaliacao(AcaoModel acao) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.white, width: 1.4),
      columnWidths: const {
        0: pw.FlexColumnWidth(),
        1: pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(children: [
          _celulaAvaliacao(
            'Avaliação da ação',
            acao.notaAvaliacao > 0 ? '${acao.notaAvaliacao}/5' : 'Não avaliada',
            _verdeClaro,
          ),
          _celulaAvaliacao(
              'Pontos positivos', acao.pontosPositivos, _cinzaClaro),
        ]),
        pw.TableRow(children: [
          _celulaAvaliacao(
            'Dificuldades encontradas',
            acao.dificuldadesEncontradas,
            _cinzaClaro,
          ),
          _celulaAvaliacao(
            'Recomendação da equipe',
            acao.recomendacoes,
            _amarelo,
          ),
        ]),
      ],
    );
  }

  pw.Widget _celulaAvaliacao(String rotulo, String valor, PdfColor cor) {
    return pw.Container(
      height: 34,
      padding: const pw.EdgeInsets.fromLTRB(6, 4, 5, 3),
      color: cor,
      child:
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(
          rotulo.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 5.4,
            color: _verde,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          _textoCompacto(valor, 150),
          maxLines: 2,
          style: pw.TextStyle(
            fontSize: _tamanhoFonteCompacta(
              valor,
              normal: 7,
              medio: 6.2,
              reduzido: 5.5,
            ),
            color: _cinza,
          ),
        ),
      ]),
    );
  }

  String _textoCompacto(String? valor, int limite) {
    final texto = _valor(valor).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (texto.length <= limite) return texto;

    final trecho = texto.substring(0, limite - 1).trimRight();
    final ultimoEspaco = trecho.lastIndexOf(' ');
    final corte = ultimoEspaco >= (limite * .7) ? ultimoEspaco : trecho.length;
    return '${trecho.substring(0, corte).trimRight()}...';
  }

  double _tamanhoFonteCompacta(
    String? valor, {
    required double normal,
    double medio = 6.2,
    double reduzido = 5.5,
  }) {
    final tamanho = _valor(valor).length;
    if (tamanho > 64) return reduzido;
    if (tamanho > 38) return medio;
    return normal;
  }

  pw.Widget _revisaoFaixita(
    FaxitaReviewResult review,
    String nivel,
    String parecer,
    pw.MemoryImage faixita,
  ) {
    return pw.Column(children: [
      pw.Container(
        height: 100,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: pw.Row(children: [
          pw.Image(faixita, width: 77, height: 90, fit: pw.BoxFit.contain),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${review.indiceQualidade}/100 - Nível $nivel | Consistência: ${review.classificacao}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: _azul,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  parecer,
                  maxLines: 3,
                  style: const pw.TextStyle(fontSize: 7.2, color: _cinza),
                ),
              ],
            ),
          ),
        ]),
      ),
      _linhaAnalise(
        'Pontos fortes',
        review.pontosFortes.join(', '),
        _verdeClaro,
      ),
      _linhaAnalise(
        'Alerta prioritário',
        review.alertas.isEmpty
            ? 'Nenhum alerta prioritário identificado.'
            : review.alertas.join(', '),
        _cinzaClaro,
      ),
      _linhaAnalise(
        'Recomendação',
        review.recomendacoes.isEmpty
            ? 'Nenhuma recomendação adicional.'
            : review.recomendacoes.join(', '),
        _amarelo,
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 3, bottom: 2),
        child: pw.Text(
          'As recomendações da Faixita apoiam a revisão e a aprendizagem operacional. A validação final permanece sob responsabilidade da equipe GEDUC.',
          style: pw.TextStyle(
            fontSize: 5.7,
            color: _cinza,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
    ]);
  }

  pw.Widget _linhaAnalise(String rotulo, String texto, PdfColor cor) {
    return pw.Container(
      height: 25,
      margin: const pw.EdgeInsets.only(bottom: 1),
      color: cor,
      child: pw.Row(children: [
        pw.Container(
          width: 105,
          padding: const pw.EdgeInsets.fromLTRB(6, 6, 3, 0),
          child: pw.Text(
            rotulo,
            style: pw.TextStyle(
              fontSize: 6.5,
              color: _azul,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(4, 5, 5, 0),
            child: pw.Text(
              texto,
              maxLines: 2,
              style: const pw.TextStyle(fontSize: 6.3, color: _cinza),
            ),
          ),
        ),
      ]),
    );
  }

  pw.Widget _evidencias(AcaoModel acao, List<pw.MemoryImage> fotos) {
    return pw.Container(
      height: 67,
      color: _cinzaClaro,
      padding: const pw.EdgeInsets.all(5),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: 185,
          padding: const pw.EdgeInsets.only(right: 7),
          child: pw.RichText(
            maxLines: 6,
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: 'Descrição das evidências\n',
                style: pw.TextStyle(
                  fontSize: 6.5,
                  color: _azul,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.TextSpan(
                text: '${_valor(acao.descricaoEvidencias)}\n'
                    'Fotos anexadas: ${acao.fotosUrls.length}.',
                style: const pw.TextStyle(fontSize: 6.2, color: _cinza),
              ),
            ]),
          ),
        ),
        ...List.generate(3, (indice) {
          final possuiFoto = indice < fotos.length;
          return pw.Container(
            width: 91,
            height: 57,
            margin: const pw.EdgeInsets.only(right: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.grey400, width: .5),
            ),
            child: possuiFoto
                ? pw.Image(fotos[indice], fit: pw.BoxFit.cover)
                : pw.Center(
                    child: pw.Text(
                      'Foto ${indice + 1}\nNão anexada',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 5.8, color: _cinza),
                    ),
                  ),
          );
        }),
      ]),
    );
  }

  Future<List<pw.MemoryImage>> _carregarFotos(List<String> caminhos) async {
    final imagens = <pw.MemoryImage>[];
    for (final caminho in caminhos.take(3)) {
      final bytes = await _lerBytesImagem(caminho);
      if (bytes != null && bytes.isNotEmpty) {
        imagens.add(pw.MemoryImage(bytes));
      }
    }
    return imagens;
  }

  Future<Uint8List?> _lerBytesImagem(String caminho) async {
    if (caminho.trim().isEmpty) return null;
    try {
      final uri = Uri.tryParse(caminho);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        final data = await NetworkAssetBundle(uri).load(caminho);
        return data.buffer.asUint8List();
      }
      final arquivo = File(caminho);
      return await arquivo.exists() ? arquivo.readAsBytes() : null;
    } catch (_) {
      return null;
    }
  }

  pw.Widget _validacaoEAssinaturas(AcaoModel acao) {
    return pw.Container(
      height: 76,
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.Container(
          width: 98,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'VALIDAÇÃO DO RAE',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  color: _azul,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.BarcodeWidget(
                width: 49,
                height: 49,
                barcode: pw.Barcode.qrCode(),
                data: _gerarConteudoQr(acao),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _assinatura(
            acao.coordenadorNome.isEmpty
                ? 'Coordenador(a) da ação'
                : acao.coordenadorNome,
            'Coordenador(a) da ação',
          ),
        ),
        pw.SizedBox(width: 18),
        pw.Expanded(
          child: _assinatura(
            'Gerente da GEDUC',
            'Gerência de Educação para o Trânsito',
          ),
        ),
      ]),
    );
  }

  pw.Widget _assinatura(String nome, String cargo) {
    return pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.Container(height: .6, color: _cinza),
      pw.SizedBox(height: 4),
      pw.Text(
        nome,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 6.8,
          color: _azul,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.Text(
        cargo,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 5.8, color: _cinza),
      ),
    ]);
  }

  String _gerarConteudoQr(AcaoModel acao) {
    return 'GEDUC-RAE|ID:${acao.id}|RAE:${acao.numeroRAE}|ACAO:${acao.nomeAcao}';
  }

  _CampoPdf _campo(String rotulo, String valor) => _CampoPdf(rotulo, valor);

  String _valor(String? valor) {
    return valor == null || valor.trim().isEmpty
        ? 'Não informado'
        : valor.trim();
  }

  String _simNao(bool valor) => valor ? 'Sim' : 'Não';

  String _data(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String _coordenada(double valor) {
    return valor == 0 ? 'Não informada' : valor.toStringAsFixed(6);
  }

  String _nome(RaeCatalogos catalogos, String grupo, String id) {
    if (id.trim().isEmpty) return 'Não informado';
    return catalogos[grupo]?[id] ?? id;
  }

  String _nomes(RaeCatalogos catalogos, String grupo, List<String> ids) {
    if (ids.isEmpty) return 'Não informado';
    return ids.map((id) => _nome(catalogos, grupo, id)).join(', ');
  }
}

class _CampoPdf {
  final String rotulo;
  final String valor;

  const _CampoPdf(this.rotulo, this.valor);
}
