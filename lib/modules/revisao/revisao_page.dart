import 'package:flutter/material.dart';

import '../../core/widgets/rae_qrcode_widget.dart';

class RevisaoPage extends StatelessWidget {
  const RevisaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const acaoIdTeste = 'acao_teste_001';
    const numeroRaeTeste = '0001/2026';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisão da Ação'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Dados da Ação'),
              subtitle: Text('Turno, tipo e coordenador'),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Localização'),
              subtitle: Text('Endereço e regional'),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.groups),
              title: Text('Resultados'),
              subtitle: Text('Pessoas e veículos abordados'),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Evidências'),
              subtitle: Text('Fotos da ação'),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.star),
              title: Text('Avaliação'),
              subtitle: Text('Nota e observações'),
            ),
          ),

          const SizedBox(height: 20),

          const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: RaeQrCodeWidget(
                acaoId: acaoIdTeste,
                numeroRAE: numeroRaeTeste,
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('SALVAR AÇÃO'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ação salva com sucesso.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}