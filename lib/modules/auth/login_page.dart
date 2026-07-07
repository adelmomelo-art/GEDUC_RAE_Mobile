import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/usuario_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;
  bool ocultarSenha = true;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);
  static const Color azulSuave = Color(0xFFEAF7F7);

  static const String fundoLogin = 'assets/images/login_beira_mar.webp';
  static const String faixitaLogin = 'assets/images/faixita_login.png';

  Future<void> fazerLogin() async {
    try {
      setState(() {
        carregando = true;
      });

      final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final uid = credencial.user!.uid;
      await UsuarioService().buscarUsuario(uid);

      if (!mounted) return;

      context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Erro ao realizar login.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> recuperarSenha() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o e-mail institucional para recuperar a senha.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Link de recuperação enviado para $email.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Não foi possível enviar a recuperação de senha.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Widget _fundo() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          fundoLogin,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FCFC),
                    Color(0xFFEAF7F7),
                    Color(0xFFFFF2E8),
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          color: Colors.white.withValues(alpha: 0.42),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.60),
                Colors.white.withValues(alpha: 0.12),
                Colors.black.withValues(alpha: 0.10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cabecalhoInstitucional() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _marcaTexto(
            icone: Icons.account_balance,
            titulo: 'Fortaleza',
            subtitulo: 'PREFEITURA\nA gente transforma',
          ),
          const SizedBox(width: 28),
          Container(
            height: 78,
            width: 1,
            color: Colors.black26,
          ),
          const SizedBox(width: 28),
          _marcaTexto(
            icone: Icons.traffic,
            titulo: 'AMC',
            subtitulo: 'AUTARQUIA MUNICIPAL\nDE TRÂNSITO E CIDADANIA',
            destaque: true,
          ),
        ],
      ),
    );
  }

  Widget _marcaTexto({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    bool destaque = false,
  }) {
    return Row(
      children: [
        Icon(
          icone,
          size: 48,
          color: destaque ? verdeInstitucional : Colors.black87,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: destaque ? 36 : 28,
                fontWeight: FontWeight.bold,
                color: destaque ? verdeInstitucional : Colors.black,
              ),
            ),
            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logoSistema() {
    return const Column(
      children: [
        Icon(
          Icons.traffic,
          size: 78,
          color: verdeInstitucional,
        ),
        SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'GEDUC ',
                style: TextStyle(
                  color: verdeInstitucional,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'RAE',
                style: TextStyle(
                  color: laranjaInstitucional,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          style: TextStyle(fontSize: 42),
        ),
        Text(
          'Gestão de Ações Educativas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _cardLogin() {
    return Container(
      width: 620,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 12),
            color: Colors.black.withValues(alpha: 0.16),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !carregando,
            decoration: const InputDecoration(
              labelText: 'E-mail institucional',
              helperText:
                  'Utilize seu e-mail institucional (ex.: nome@amc.fortaleza.ce.gov.br)',
              prefixIcon: Icon(Icons.mail_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: senhaController,
            obscureText: ocultarSenha,
            enabled: !carregando,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  ocultarSenha ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    ocultarSenha = !ocultarSenha;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: carregando ? null : recuperarSenha,
              child: const Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: verdeInstitucional,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeInstitucional,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: carregando ? null : fazerLogin,
              icon: carregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login),
              label: Text(
                carregando ? 'ENTRANDO...' : 'ENTRAR',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardFaixita() {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: verdeInstitucional.withValues(alpha: 0.60),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 108,
            height: 150,
            child: Image.asset(
              faixitaLogin,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const CircleAvatar(
                  radius: 42,
                  backgroundColor: azulSuave,
                  child: Text(
                    'F',
                    style: TextStyle(
                      color: verdeInstitucional,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Olá! Eu sou a Faixita!',
                    style: TextStyle(
                      color: verdeInstitucional,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Estou aqui para ajudar durante o registro das suas ações educativas.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Atendimento da Faixita será ativado em uma próxima etapa.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Falar com a Faixita'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodape() {
    return Container(
      height: 118,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          _rodapeItem(
            icone: Icons.verified_user_outlined,
            titulo: 'Ambiente: HOMOLOGAÇÃO',
            texto:
                'Os dados inseridos não são compartilhados com o ambiente de produção.',
          ),
          const SizedBox(width: 42),
          _rodapeItem(
            icone: Icons.lock_outline,
            titulo: 'Seus dados estão protegidos',
            texto: 'Sistema seguro e criptografado conforme LGPD.',
          ),
          const Spacer(),
          const Text(
            'Versão: 0.30.0\nBuild: CE-030\n05/07/2026 • 15:19',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 42),
          const Text(
            'GEDUC\nEDUCAÇÃO PARA\nO TRÂNSITO, CIDADANIA\nE TRANSFORMAÇÃO SOCIAL',
            style: TextStyle(
              color: verdeInstitucional,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodapeItem({
    required IconData icone,
    required String titulo,
    required String texto,
  }) {
    return SizedBox(
      width: 300,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: azulSuave,
            child: Icon(
              icone,
              color: verdeInstitucional,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$titulo\n',
                    style: const TextStyle(
                      color: verdeInstitucional,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: texto),
                ],
              ),
              style: const TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudoPrincipal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1050;

        return Column(
          children: [
            _cabecalhoInstitucional(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _logoSistema(),
                    const SizedBox(height: 28),
                    if (isWide)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _cardLogin(),
                          const SizedBox(width: 24),
                          _cardFaixita(),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _cardLogin(),
                          const SizedBox(height: 20),
                          _cardFaixita(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            _rodape(),
            Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    verdeInstitucional,
                    Color(0xFFFFC400),
                    laranjaInstitucional,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _fundo(),
          _conteudoPrincipal(),
        ],
      ),
    );
  }
}
