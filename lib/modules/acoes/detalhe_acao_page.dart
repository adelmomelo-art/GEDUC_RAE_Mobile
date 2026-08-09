import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domains/domain_provider.dart';
import '../../core/services/pdf_relatorio_service.dart';
import '../../core/widgets/rae_qrcode_widget.dart';
import '../../data/models/acao_model.dart';

class DetalheAcaoPage extends StatelessWidget {
  final AcaoModel acao;

  const DetalheAcaoPage({
    super.key,
    required this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfRelatorioService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do RAE'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardTitulo(),
          const SizedBox(height: 12),
          _cardDadosAcao(),
          const SizedBox(height: 12),
          _cardLocalizacao(),
          const SizedBox(height: 12),
          _cardResultados(),
          const SizedBox(height: 12),
          _cardQrCode(),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'GERAR PDF DO RAE',
              ),
              onPressed: () async {
                await pdfService.gerarRelatorioAcao(
                  acao,
                  catalogos: PdfRelatorioService.catalogosDe(
                    context.read<DomainProvider>(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text(
                'COMPARTILHAR RAE',
              ),
              onPressed: () async {
                await pdfService.compartilharRelatorio(
                  acao,
                  catalogos: PdfRelatorioService.catalogosDe(
                    context.read<DomainProvider>(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTitulo() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment),
        title: Text(
          acao.nomeAcao,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'RAE Nº ${acao.numeroRAE}',
        ),
      ),
    );
  }

  Widget _cardDadosAcao() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('Dados da Ação'),
            _linha(
              'Tipo',
              acao.tipoAcao,
            ),
            _linha(
              'Turno',
              acao.turno,
            ),
            _linha(
              'Hora inicial',
              acao.horaInicio,
            ),
            _linha(
              'Hora final',
              acao.horaFinal ?? 'Não informada',
            ),
            _linha(
              'Coordenador',
              acao.coordenadorNome,
            ),
            _linha(
              'Status',
              acao.status,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardLocalizacao() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('Localização'),
            _linha(
              'Endereço',
              acao.endereco,
            ),
            _linha(
              'Bairro',
              acao.bairro,
            ),
            _linha(
              'Regional',
              acao.regional,
            ),
            _linha(
              'Latitude',
              acao.latitude.toString(),
            ),
            _linha(
              'Longitude',
              acao.longitude.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardResultados() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('Resultados'),
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
            if (!acao.metaAtingida)
              _linha(
                'Motivo',
                acao.motivoMetaNaoAtingida ?? 'Não informado',
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardQrCode() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: RaeQrCodeWidget(
            acaoId: acao.id,
            numeroRAE: acao.numeroRAE,
          ),
        ),
      ),
    );
  }

  Widget _titulo(
    String texto,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _linha(
    String campo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Text(
        '$campo: $valor',
      ),
    );
  }
}
