import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/acao_model.dart';

class PdfRelatorioService {
  Future<void> gerarRelatorioAcao(AcaoModel acao) async {
    final pdf = await _criarDocumentoPdf(acao);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> compartilharRelatorio(AcaoModel acao) async {
    final pdf = await _criarDocumentoPdf(acao);

    final diretorio = await getTemporaryDirectory();

    final numeroSeguro = acao.numeroRAE
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(' ', '_');

    final arquivo = File(
      '${diretorio.path}/RAE_$numeroSeguro.pdf',
    );

    await arquivo.writeAsBytes(
      await pdf.save(),
    );

    await SharePlus.instance.share(
      ShareParams(
        text: 'Relatório RAE ${acao.numeroRAE}',
        files: [
          XFile(arquivo.path),
        ],
      ),
    );
  }

  Future<pw.Document> _criarDocumentoPdf(AcaoModel acao) async {
    final pdf = pw.Document();

    final header = pw.MemoryImage(
      (await rootBundle.load('assets/images/header_timbrado.png'))
          .buffer
          .asUint8List(),
    );

    final footer = pw.MemoryImage(
      (await rootBundle.load('assets/images/footer_timbrado.png'))
          .buffer
          .asUint8List(),
    );

    final fotos = await _carregarFotos(acao.fotosUrls);
    final qrData = _gerarConteudoQr(acao);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                top: 35,
                left: 0,
                right: 0,
                child: pw.Center(
                  child: pw.Image(header, width: 300),
                ),
              ),
              pw.Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: pw.Container(
                  height: 78,
                  child: pw.Image(
                    footer,
                    fit: pw.BoxFit.fitWidth,
                  ),
                ),
              ),
              pw.Positioned(
                top: 155,
                left: 45,
                right: 45,
                bottom: 110,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        'RELATÓRIO DE AÇÃO EDUCATIVA',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Text(
                        'RAE Nº ${acao.numeroRAE}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _titulo('DADOS DA AÇÃO'),
                              _linha('Nome da ação', acao.nomeAcao),
                              _linha('Tipo da ação', acao.tipoAcao),
                              _linha('Turno', acao.turno),
                              _linha('Coordenador', acao.coordenadorNome),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 86,
                              height: 86,
                              padding: const pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.grey600,
                                  width: 0.6,
                                ),
                              ),
                              child: pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: qrData,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Validação RAE',
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    _titulo('LOCALIZAÇÃO'),
                    _linha('Endereço', acao.endereco),
                    _linha('Bairro', acao.bairro),
                    _linha('Regional', acao.regional),
                    _linha('Latitude', acao.latitude.toString()),
                    _linha('Longitude', acao.longitude.toString()),
                    pw.SizedBox(height: 8),
                    _titulo('RESULTADOS'),
                    _linha(
                      'Pessoas alcançadas',
                      acao.pessoasAlcancadas.toString(),
                    ),
                    _linha(
                      'Veículos abordados',
                      acao.veiculosAbordados.toString(),
                    ),
                    _linha(
                      'Credenciais emitidas',
                      acao.credenciaisEmitidas.toString(),
                    ),
                    _linha(
                      'Meta atingida',
                      acao.metaAtingida ? 'SIM' : 'NÃO',
                    ),
                    if (!acao.metaAtingida &&
                        (acao.motivoMetaNaoAtingida ?? '').isNotEmpty)
                      _linha(
                        'Motivo',
                        acao.motivoMetaNaoAtingida ?? '',
                      ),
                    pw.SizedBox(height: 8),
                    _titulo('EVIDÊNCIAS'),
                    pw.Text(
                      acao.descricaoEvidencias.isEmpty
                          ? 'Sem descrição informada.'
                          : acao.descricaoEvidencias,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Fotos registradas: ${acao.fotosUrls.length}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    if (fotos.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      _gradeFotos(fotos),
                    ],
                    pw.Spacer(),
                    _assinaturas(acao.coordenadorNome),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  String _gerarConteudoQr(AcaoModel acao) {
    return 'GEDUC-RAE|ID:${acao.id}|RAE:${acao.numeroRAE}|ACAO:${acao.nomeAcao}';
  }

  pw.Widget _assinaturas(String coordenador) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _blocoAssinatura(
              coordenador.isEmpty ? 'Coordenador da Ação' : coordenador,
              'Coordenador da Ação',
            ),
            _blocoAssinatura(
              'GEDUC',
              'Gerência de Educação para o Trânsito',
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _blocoAssinatura(String nome, String cargo) {
    return pw.Container(
      width: 210,
      child: pw.Column(
        children: [
          pw.Container(
            height: 1,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            nome,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            cargo,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  Future<List<pw.MemoryImage>> _carregarFotos(List<String> caminhos) async {
    final imagens = <pw.MemoryImage>[];

    for (final caminho in caminhos.take(4)) {
      final bytes = await _lerBytesImagem(caminho);

      if (bytes != null && bytes.isNotEmpty) {
        imagens.add(pw.MemoryImage(bytes));
      }
    }

    return imagens;
  }

  Future<Uint8List?> _lerBytesImagem(String caminho) async {
    if (caminho.trim().isEmpty) {
      return null;
    }

    try {
      final uri = Uri.tryParse(caminho);

      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        final data = await NetworkAssetBundle(uri).load(caminho);
        return data.buffer.asUint8List();
      }

      final arquivo = File(caminho);

      if (await arquivo.exists()) {
        return arquivo.readAsBytes();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  pw.Widget _gradeFotos(List<pw.MemoryImage> fotos) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fotos.map((foto) {
        return pw.Container(
          width: 115,
          height: 75,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.grey600,
              width: 0.5,
            ),
          ),
          child: pw.Image(
            foto,
            fit: pw.BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _titulo(String texto) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          texto,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Container(
          height: 0.8,
          color: PdfColors.grey700,
          margin: const pw.EdgeInsets.only(
            top: 3,
            bottom: 5,
          ),
        ),
      ],
    );
  }

  pw.Widget _linha(String campo, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.5),
      child: pw.Text(
        '$campo: $valor',
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }
}