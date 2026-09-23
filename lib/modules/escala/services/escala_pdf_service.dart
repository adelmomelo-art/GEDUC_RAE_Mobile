import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/escala_repository.dart';
import '../models/escala_models.dart';
import 'escala_horas_service.dart';

class EscalaPdfService {
  static const _azul = PdfColor.fromInt(0xFF154C68);
  static const _verde = PdfColor.fromInt(0xFF008F83);
  static const _cinza = PdfColor.fromInt(0xFF4B5563);
  static const _cinzaClaro = PdfColor.fromInt(0xFFF1F4F5);
  static const _linha = PdfColor.fromInt(0xFFD5DEE2);
  static const _fontRegularAsset =
      'assets/fonts/noto_sans/NotoSans-Regular.ttf';
  static const _fontBoldAsset = 'assets/fonts/noto_sans/NotoSans-Bold.ttf';
  static const _fontItalicAsset = 'assets/fonts/noto_sans/NotoSans-Italic.ttf';
  static const _fontBoldItalicAsset =
      'assets/fonts/noto_sans/NotoSans-BoldItalic.ttf';

  Future<void> visualizar(EscalaDiaConsulta dia) async {
    final bytes = await gerarBytes(dia);
    await Printing.layoutPdf(
      name: nomeArquivo(dia),
      onLayout: (_) async => bytes,
    );
  }

  Future<Uint8List> gerarBytes(EscalaDiaConsulta dia) async {
    _validar(dia);
    final tema = await _carregarTemaUnicode();
    final cabecalho = pw.MemoryImage(
      (await rootBundle.load('assets/images/header_timbrado.png'))
          .buffer
          .asUint8List(),
    );
    final rodape = pw.MemoryImage(
      (await rootBundle.load('assets/images/footer_timbrado.png'))
          .buffer
          .asUint8List(),
    );
    final escala = dia.escala!;
    final documento = pw.Document(
      theme: tema,
      title: 'Escala GEDUC ${_data(dia.data)} - versão ${escala.versao}',
      author: 'Plataforma Fênix - GEDUC',
      subject: 'Escala operacional oficial publicada',
    );

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(28, 66, 28, 54),
        header: (_) => _cabecalho(cabecalho, dia),
        footer: (context) => _rodape(rodape, context, escala),
        build: (_) => _conteudo(dia),
      ),
    );
    return documento.save();
  }

  String nomeArquivo(EscalaDiaConsulta dia) {
    final data = DateFormat('yyyy-MM-dd').format(dia.data);
    final versao = dia.escala?.versao ?? 0;
    return 'Escala_GEDUC_${data}_v$versao.pdf';
  }

  void _validar(EscalaDiaConsulta dia) {
    if (!dia.publicada || dia.escala == null) {
      throw StateError('O PDF oficial exige uma escala publicada.');
    }
  }

  Future<pw.ThemeData> _carregarTemaUnicode() async {
    Future<pw.Font> carregar(String asset) async {
      final dados = await rootBundle.load(asset);
      if (dados.lengthInBytes == 0) {
        throw StateError('Fonte PDF vazia no bundle: $asset');
      }
      return pw.Font.ttf(dados);
    }

    return pw.ThemeData.withFont(
      base: await carregar(_fontRegularAsset),
      bold: await carregar(_fontBoldAsset),
      italic: await carregar(_fontItalicAsset),
      boldItalic: await carregar(_fontBoldItalicAsset),
    );
  }

  pw.Widget _cabecalho(pw.MemoryImage imagem, EscalaDiaConsulta dia) {
    final escala = dia.escala!;
    return pw.Column(
      children: [
        pw.Image(imagem, height: 30, fit: pw.BoxFit.contain),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'ESCALA OPERACIONAL GEDUC',
              style: pw.TextStyle(
                color: _azul,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '${_diaSemana(dia.data)} • ${_data(dia.data)} • VERSÃO ${escala.versao}',
              style: pw.TextStyle(
                color: _verde,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Divider(color: _verde, height: 1),
      ],
    );
  }

  pw.Widget _rodape(
    pw.MemoryImage imagem,
    pw.Context context,
    EscalaModel escala,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: _linha, height: 1),
        pw.SizedBox(height: 3),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'Documento oficial da versão publicada. Alterações exigem nova revisão e publicação.',
                style: const pw.TextStyle(fontSize: 6.5, color: _cinza),
              ),
            ),
            pw.Text(
              'Publicada em ${_dataHora(escala.publicadoEm)} • Página ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 6.5, color: _cinza),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Image(imagem, height: 18, fit: pw.BoxFit.fill),
      ],
    );
  }

  List<pw.Widget> _conteudo(EscalaDiaConsulta dia) {
    final escala = dia.escala!;
    final resumo = EscalaHorasService.resumir(dia.alocacoes);
    final atividades = [...dia.atividades]..sort(_compararAtividades);
    final secoes = <String, List<EscalaAtividadeModel>>{};
    for (final atividade in atividades) {
      final chave = atividade.secaoId.trim().isEmpty
          ? 'outras'
          : atividade.secaoId.trim();
      secoes.putIfAbsent(chave, () => []).add(atividade);
    }

    return [
      _metadados(escala, dia, resumo),
      if (escala.observacaoGeral.trim().isNotEmpty) ...[
        pw.SizedBox(height: 7),
        _aviso('Observação geral', escala.observacaoGeral),
      ],
      pw.SizedBox(height: 10),
      for (final secao in secoes.entries) ...[
        _tituloSecao(_rotuloSecao(secao.key)),
        pw.SizedBox(height: 4),
        for (final atividade in secao.value) ...[
          ..._blocosAtividade(
            atividade,
            _alocacoesDaAtividade(dia, atividade.id),
          ),
          pw.SizedBox(height: 7),
        ],
      ],
      if (dia.indisponibilidades.isNotEmpty) ...[
        _tituloSecao('COMPENSAÇÕES, FÉRIAS E FOLGAS'),
        pw.SizedBox(height: 4),
        _indisponibilidades(dia.indisponibilidades),
      ],
    ];
  }

  pw.Widget _metadados(
    EscalaModel escala,
    EscalaDiaConsulta dia,
    EscalaHorasResumo resumo,
  ) {
    final itens = <(String, String)>[
      ('Status', 'PUBLICADA'),
      ('Versão', '${escala.versao}'),
      ('Atividades', '${dia.atividades.length}'),
      ('Equipe', '${resumo.totalAgentesUnicos} agente(s)'),
      (
        'Horas programadas',
        EscalaHorasService.formatarMinutos(resumo.totalMinutosProgramados),
      ),
      (
        'Jornada normal',
        EscalaHorasService.formatarMinutos(resumo.minutosNormal),
      ),
      (
        'Hora extra',
        EscalaHorasService.formatarMinutos(resumo.minutosHoraExtra),
      ),
      (
        'Banco de horas',
        EscalaHorasService.formatarMinutos(resumo.minutosBancoHoras),
      ),
    ];
    return pw.Row(
      children: [
        for (final item in itens)
          pw.Expanded(
            child: pw.Container(
              height: 34,
              margin: const pw.EdgeInsets.only(right: 2),
              padding: const pw.EdgeInsets.all(5),
              color: _cinzaClaro,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.$1.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 5.2,
                      color: _verde,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    item.$2,
                    style: pw.TextStyle(
                      fontSize: 7.4,
                      color: _azul,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _atividade(
    EscalaAtividadeModel atividade,
    List<EscalaAlocacaoModel> alocacoes, {
    required bool continuacao,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _linha, width: .7),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: const pw.EdgeInsets.all(7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  '${_valor(atividade.titulo, 'Atividade sem título')}'
                  '${continuacao ? ' (continuação)' : ''}',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: _azul,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                atividade.naturezaAtividade.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 6,
                  color: _verde,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!continuacao) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _campo('QTR', _qtr(atividade), flex: 2),
                _campo('QTH', _qth(atividade), flex: 3),
                _campo(
                  'Coordenação',
                  _valor(atividade.coordenadorNomeSnapshot, 'Não informada'),
                  flex: 3,
                ),
                _campo(
                  'Tipo',
                  _rotuloCodigo(atividade.tipoAtividadeId),
                  flex: 2,
                ),
              ],
            ),
            if (atividade.orientacaoOperacional.trim().isNotEmpty) ...[
              pw.SizedBox(height: 5),
              _aviso(
                'Orientação operacional',
                atividade.orientacaoOperacional,
              ),
            ],
          ],
          pw.SizedBox(height: 6),
          if (alocacoes.isEmpty)
            pw.Text(
              'Equipe não informada.',
              style: pw.TextStyle(
                fontSize: 7,
                color: _cinza,
                fontStyle: pw.FontStyle.italic,
              ),
            )
          else
            _tabelaEquipe(alocacoes),
        ],
      ),
    );
  }

  List<pw.Widget> _blocosAtividade(
    EscalaAtividadeModel atividade,
    List<EscalaAlocacaoModel> alocacoes,
  ) {
    if (alocacoes.isEmpty) {
      return [
        _atividade(atividade, const [], continuacao: false),
      ];
    }

    final ordenadas = [...alocacoes]
      ..sort((a, b) => a.nomeSnapshot.compareTo(b.nomeSnapshot));
    const tamanhoBloco = 14;
    final blocos = <pw.Widget>[];
    for (var inicio = 0; inicio < ordenadas.length; inicio += tamanhoBloco) {
      final proximo = inicio + tamanhoBloco;
      final fim = proximo < ordenadas.length ? proximo : ordenadas.length;
      blocos.add(
        _atividade(
          atividade,
          ordenadas.sublist(inicio, fim),
          continuacao: inicio > 0,
        ),
      );
      if (fim < ordenadas.length) blocos.add(pw.SizedBox(height: 5));
    }
    return blocos;
  }

  pw.Widget _tabelaEquipe(List<EscalaAlocacaoModel> alocacoes) {
    final ordenadas = [...alocacoes]
      ..sort((a, b) => a.nomeSnapshot.compareTo(b.nomeSnapshot));
    return pw.Table(
      border: pw.TableBorder.all(color: _linha, width: .5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3.2),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.8),
        4: pw.FlexColumnWidth(1.2),
      },
      children: [
        _linhaTabela(
          const ['Integrante', 'Função', 'Horário', 'Jornada', 'Previsto'],
          cabecalho: true,
        ),
        for (final item in ordenadas)
          _linhaTabela([
            _valor(item.nomeSnapshot, 'Não informado'),
            _rotuloCodigo(item.funcaoNaAtividade),
            _intervalo(item.horaInicio, item.horaFim),
            _rotuloJornada(item.tipoJornada),
            EscalaHorasService.formatarMinutos(item.minutosPrevistos),
          ]),
      ],
    );
  }

  pw.TableRow _linhaTabela(List<String> valores, {bool cabecalho = false}) {
    return pw.TableRow(
      decoration: cabecalho ? const pw.BoxDecoration(color: _cinzaClaro) : null,
      children: [
        for (final valor in valores)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: pw.Text(
              valor,
              style: pw.TextStyle(
                fontSize: cabecalho ? 6.2 : 6.5,
                color: cabecalho ? _azul : _cinza,
                fontWeight:
                    cabecalho ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _indisponibilidades(
    List<EscalaIndisponibilidadeModel> itens,
  ) {
    final ordenados = [...itens]
      ..sort((a, b) => a.nomeSnapshot.compareTo(b.nomeSnapshot));
    return pw.Table(
      border: pw.TableBorder.all(color: _linha, width: .5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(1.7),
        3: pw.FlexColumnWidth(4),
      },
      children: [
        _linhaTabela(
          const ['Integrante', 'Tipo', 'Horário', 'Observação'],
          cabecalho: true,
        ),
        for (final item in ordenados)
          _linhaTabela([
            _valor(item.nomeSnapshot, 'Não informado'),
            _rotuloCodigo(item.tipoId),
            _intervalo(item.horaInicio, item.horaFim),
            _valor(item.observacao, '—'),
          ]),
      ],
    );
  }

  pw.Widget _tituloSecao(String titulo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      color: _azul,
      child: pw.Text(
        titulo,
        style: pw.TextStyle(
          fontSize: 8,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _campo(String rotulo, String valor, {required int flex}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(right: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              rotulo.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 5.3,
                color: _verde,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Text(valor,
                style: const pw.TextStyle(fontSize: 7, color: _cinza)),
          ],
        ),
      ),
    );
  }

  pw.Widget _aviso(String rotulo, String valor) {
    return pw.Container(
      width: double.infinity,
      color: _cinzaClaro,
      padding: const pw.EdgeInsets.all(5),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 6.7, color: _cinza),
          children: [
            pw.TextSpan(
              text: '${rotulo.toUpperCase()}: ',
              style: pw.TextStyle(
                color: _verde,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(text: valor.trim()),
          ],
        ),
      ),
    );
  }

  List<EscalaAlocacaoModel> _alocacoesDaAtividade(
    EscalaDiaConsulta dia,
    String atividadeId,
  ) {
    return dia.alocacoes
        .where((item) => item.atividadeId == atividadeId)
        .toList(growable: false);
  }

  int _compararAtividades(EscalaAtividadeModel a, EscalaAtividadeModel b) {
    final porSecao = _ordemSecao(a.secaoId).compareTo(_ordemSecao(b.secaoId));
    if (porSecao != 0) return porSecao;
    final porHorario = a.horaInicio.compareTo(b.horaInicio);
    if (porHorario != 0) return porHorario;
    return a.titulo.compareTo(b.titulo);
  }

  int _ordemSecao(String secao) {
    const ordem = {
      'comandos': 0,
      'programas': 1,
      'apoio': 2,
      'administrativo': 3,
    };
    return ordem[secao.trim()] ?? 99;
  }

  String _rotuloSecao(String secao) {
    const rotulos = {
      'comandos': 'COMANDOS E AÇÕES TEMÁTICAS',
      'programas': 'PROGRAMAS E PROJETOS',
      'apoio': 'APOIO OPERACIONAL',
      'administrativo': 'ATIVIDADES ADMINISTRATIVAS',
      'outras': 'OUTRAS ATIVIDADES',
    };
    return rotulos[secao] ?? _rotuloCodigo(secao).toUpperCase();
  }

  String _rotuloJornada(String codigo) {
    switch (codigo.trim()) {
      case EscalaCodigos.jornadaHoraExtra:
        return 'Hora extra';
      case EscalaCodigos.jornadaBancoHoras:
        return 'Banco de horas';
      default:
        return 'Normal';
    }
  }

  String _qtr(EscalaAtividadeModel atividade) {
    final intervalo = _intervalo(atividade.horaInicio, atividade.horaFim);
    if (intervalo != 'Não informado') return intervalo;
    return _valor(atividade.qtrHorario, 'Não informado');
  }

  String _qth(EscalaAtividadeModel atividade) {
    final partes = [
      atividade.qthLocal,
      atividade.qthEndereco,
      atividade.qthPontoReferencia,
    ].map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    return partes.isEmpty ? 'Não informado' : partes.join(' • ');
  }

  String _intervalo(String inicio, String fim) {
    final de = inicio.trim();
    final ate = fim.trim();
    if (de.isEmpty && ate.isEmpty) return 'Não informado';
    if (de.isEmpty) return 'Até $ate';
    if (ate.isEmpty) return 'A partir de $de';
    return '$de–$ate';
  }

  String _rotuloCodigo(String valor) {
    final texto = valor.trim().replaceAll('_', ' ').replaceAll('-', ' ');
    if (texto.isEmpty) return 'Não informado';
    return texto
        .split(RegExp(r'\s+'))
        .map((parte) =>
            '${parte.substring(0, 1).toUpperCase()}${parte.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _valor(String valor, String fallback) {
    final texto = valor.trim();
    return texto.isEmpty ? fallback : texto;
  }

  String _data(DateTime data) => DateFormat('dd/MM/yyyy').format(data);

  String _dataHora(DateTime? data) {
    if (data == null) return 'não informada';
    return DateFormat('dd/MM/yyyy HH:mm').format(data.toLocal());
  }

  String _diaSemana(DateTime data) {
    const dias = [
      'SEGUNDA-FEIRA',
      'TERÇA-FEIRA',
      'QUARTA-FEIRA',
      'QUINTA-FEIRA',
      'SEXTA-FEIRA',
      'SÁBADO',
      'DOMINGO',
    ];
    return dias[data.weekday - 1];
  }
}
