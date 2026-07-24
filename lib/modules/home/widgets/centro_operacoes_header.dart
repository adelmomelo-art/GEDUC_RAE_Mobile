import 'package:flutter/material.dart';

import '../../../data/models/usuario_model.dart';

class CentroOperacoesHeader extends StatelessWidget {
  const CentroOperacoesHeader({
    super.key,
    required this.usuario,
    required this.onAtualizar,
    required this.onSair,
  });

  final UsuarioModel? usuario;
  final VoidCallback onAtualizar;
  final VoidCallback onSair;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    final nome = _nomeUsuario();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 720;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compacto ? 18 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF006B69),
                Color(0xFF00928F),
              ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.14),
              ),
            ],
          ),
          child: compacto
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _identidade(),
                    const SizedBox(height: 20),
                    _saudacao(nome),
                    const SizedBox(height: 18),
                    _acoes(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _identidade(),
                          const SizedBox(height: 22),
                          _saudacao(nome),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    _acoes(),
                  ],
                ),
        );
      },
    );
  }

  Widget _identidade() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.hub_outlined,
            size: 30,
            color: verdeInstitucional,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Centro de Operações Educativas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Plataforma Fênix • GEDUC',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saudacao(String nome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo, $nome.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Acompanhe os indicadores, continue suas atividades e acesse os principais recursos operacionais.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _acoes() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _acaoBotao(
          tooltip: 'Atualizar informações',
          icon: Icons.refresh,
          onPressed: onAtualizar,
        ),
        const SizedBox(width: 10),
        _acaoBotao(
          tooltip: 'Sair da plataforma',
          icon: Icons.logout,
          onPressed: onSair,
          destaque: true,
        ),
      ],
    );
  }

  Widget _acaoBotao({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    bool destaque = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: destaque
            ? laranjaInstitucional
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _nomeUsuario() {
    final nome = usuario?.nome.trim();

    if (nome == null || nome.isEmpty) {
      return 'usuário';
    }

    return nome.split(' ').first;
  }
}
