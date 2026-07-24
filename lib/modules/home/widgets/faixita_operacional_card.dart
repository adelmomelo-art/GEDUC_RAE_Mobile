import 'package:flutter/material.dart';

class FaixitaOperacionalCard extends StatelessWidget {
  const FaixitaOperacionalCard({
    super.key,
    required this.possuiRascunho,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.onOrientacoes,
  });

  final bool possuiRascunho;
  final int totalAcoes;
  final int totalPessoas;
  final VoidCallback onOrientacoes;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);
  static const Color azulSuave = Color(0xFFEAF7F7);
  static const String imagemFaixita = 'assets/images/faixita_login.png';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: verdeInstitucional.withValues(alpha: 0.20),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 560;

            if (compacto) {
              return Column(
                children: [
                  _imagem(),
                  const SizedBox(height: 14),
                  _conteudo(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _imagem(),
                const SizedBox(width: 18),
                Expanded(child: _conteudo()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _imagem() {
    return SizedBox(
      width: 118,
      height: 150,
      child: Image.asset(
        imagemFaixita,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: azulSuave,
              child: Text(
                'F',
                style: TextStyle(
                  color: verdeInstitucional,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _conteudo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: laranjaInstitucional,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Análise operacional da Faixita',
                style: TextStyle(
                  color: verdeInstitucional,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _mensagemPrincipal(),
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        _insight(
          icon: possuiRascunho ? Icons.edit_note : Icons.check_circle_outline,
          texto: possuiRascunho
              ? 'Existe um rascunho aguardando continuidade.'
              : 'Nenhum rascunho pendente neste dispositivo.',
          cor: possuiRascunho ? laranjaInstitucional : verdeInstitucional,
        ),
        const SizedBox(height: 6),
        _insight(
          icon: Icons.analytics_outlined,
          texto: '$totalAcoes ações e $totalPessoas pessoas registradas.',
          cor: verdeInstitucional,
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onOrientacoes,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('VER ORIENTAÇÕES'),
          ),
        ),
      ],
    );
  }

  Widget _insight({
    required IconData icon,
    required String texto,
    required Color cor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: cor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  String _mensagemPrincipal() {
    if (possuiRascunho) {
      return 'Identifiquei uma atividade que ainda não foi concluída. Você pode continuar o preenchimento antes de iniciar uma nova ação.';
    }

    if (totalAcoes == 0) {
      return 'O portal está pronto para receber o primeiro registro. Inicie uma nova ação educativa para começar a alimentar os indicadores.';
    }

    return 'Os dados operacionais estão disponíveis. Consulte os indicadores e utilize os atalhos para continuar o trabalho da equipe.';
  }
}
