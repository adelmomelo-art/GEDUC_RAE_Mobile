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
          content: Text('Erro: $e'),
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

  Future<void> abrirApresentacaoFaixita() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: const Row(
            children: [
              CircleAvatar(
                backgroundColor: azulSuave,
                child: Text(
                  'F',
                  style: TextStyle(
                    color: verdeInstitucional,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Olá! Eu sou a Faixita.',
                  style: TextStyle(
                    color: verdeInstitucional,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Bem-vindo à Plataforma Fênix!\n\n'
              'Ainda estou em treinamento, mas em breve poderei ajudar você com:\n\n'
              '• preenchimento das ações educativas;\n'
              '• dúvidas sobre o sistema;\n'
              '• leitura dos indicadores;\n'
              '• recomendações operacionais.\n\n'
              'Vou acompanhar a evolução da plataforma e ajudar a transformar '
              'dados operacionais em inteligência para tomada de decisão.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: verdeInstitucional,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('ENTENDI'),
            ),
          ],
        );
      },
    );
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
          color: Colors.white.withValues(alpha: 0.55),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.64),
                Colors.white.withValues(alpha: 0.18),
                Colors.black.withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cabecalhoInstitucional({
    required bool compacto,
  }) {
    final tituloPrefeitura = compacto ? 24.0 : 30.0;
    final tituloAmc = compacto ? 30.0 : 38.0;
    final tamanhoIcone = compacto ? 41.0 : 52.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compacto ? 18 : 32,
        compacto ? 18 : 28,
        compacto ? 18 : 32,
        8,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: compacto ? 16 : 28,
        runSpacing: 12,
        children: [
          _marcaTexto(
            icone: Icons.account_balance,
            titulo: 'Fortaleza',
            subtitulo: 'PREFEITURA\nA gente transforma',
            tamanhoTitulo: tituloPrefeitura,
            tamanhoIcone: tamanhoIcone,
          ),
          Container(
            height: compacto ? 60 : 78,
            width: 1,
            color: Colors.black26,
          ),
          _marcaTexto(
            icone: Icons.traffic,
            titulo: 'AMC',
            subtitulo: 'AUTARQUIA MUNICIPAL\nDE TRÂNSITO E CIDADANIA',
            destaque: true,
            tamanhoTitulo: tituloAmc,
            tamanhoIcone: tamanhoIcone,
          ),
        ],
      ),
    );
  }

  Widget _marcaTexto({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required double tamanhoTitulo,
    required double tamanhoIcone,
    bool destaque = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icone,
          size: tamanhoIcone,
          color: destaque ? verdeInstitucional : Colors.black87,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: tamanhoTitulo,
                fontWeight: FontWeight.bold,
                color: destaque ? verdeInstitucional : Colors.black,
              ),
            ),
            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.22,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logoSistema({
    required bool compacto,
  }) {
    return Column(
      children: [
        Icon(
          Icons.traffic,
          size: compacto ? 64 : 78,
          color: verdeInstitucional,
        ),
        const SizedBox(height: 8),
        Text.rich(
          const TextSpan(
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
          style: TextStyle(
            fontSize: compacto ? 34 : 42,
          ),
        ),
        Text(
          'Gestão de Ações Educativas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compacto ? 17 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _cardLogin({
    required double largura,
  }) {
    return Container(
      width: largura,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
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
                tooltip: ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
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

  Widget _cardFaixita({
    required bool compacto,
    required double largura,
  }) {
    final larguraImagem = compacto ? 128.0 : 108.0;
    final alturaImagem = compacto ? 174.0 : 150.0;

    return Container(
      width: largura,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: const BorderSide(
            color: verdeInstitucional,
            width: 6,
          ),
          top: BorderSide(
            color: verdeInstitucional.withValues(alpha: 0.40),
          ),
          right: BorderSide(
            color: verdeInstitucional.withValues(alpha: 0.40),
          ),
          bottom: BorderSide(
            color: verdeInstitucional.withValues(alpha: 0.40),
          ),
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
            width: larguraImagem,
            height: alturaImagem,
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
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: abrirApresentacaoFaixita,
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                      ),
                      label: const Text('Falar com a Faixita'),
                    ),
                  ),
                ],
              ),
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
    return Container(
      constraints: const BoxConstraints(
        minHeight: 86,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 2),
          CircleAvatar(
            radius: 22,
            backgroundColor: azulSuave,
            child: Icon(
              icone,
              color: verdeInstitucional,
            ),
          ),
          const SizedBox(width: 10),
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
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _versaoCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: azulSuave,
            child: Icon(
              Icons.info_outline,
              color: verdeInstitucional,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Versão: 0.30.0\n'
              'Build: CE-030\n'
              'Ambiente de homologação',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _geducCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: azulSuave,
            child: Icon(
              Icons.local_florist_outlined,
              color: verdeInstitucional,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'GEDUC\n'
              'Educação para o trânsito,\n'
              'cidadania e transformação social',
              style: TextStyle(
                color: verdeInstitucional,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodapeResponsivo({
    required double larguraDisponivel,
  }) {
    const espacamento = 10.0;
    const paddingHorizontal = 28.0;

    final colunas = larguraDisponivel >= 1100
        ? 4
        : larguraDisponivel >= 600
            ? 2
            : 1;

    final larguraInterna =
        (larguraDisponivel - paddingHorizontal).clamp(280.0, double.infinity);

    final larguraItem = colunas == 1
        ? larguraInterna
        : (larguraInterna - (espacamento * (colunas - 1))) / colunas;

    final itens = [
      _rodapeItem(
        icone: Icons.verified_user_outlined,
        titulo: 'Ambiente: HOMOLOGAÇÃO',
        texto:
            'Os dados inseridos não são compartilhados com o ambiente de produção.',
      ),
      _rodapeItem(
        icone: Icons.lock_outline,
        titulo: 'Seus dados estão protegidos',
        texto: 'Sistema seguro e criptografado conforme LGPD.',
      ),
      _versaoCard(),
      _geducCard(),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withValues(alpha: 0.94),
      child: Wrap(
        spacing: espacamento,
        runSpacing: espacamento,
        children: itens
            .map(
              (item) => SizedBox(
                width: larguraItem,
                child: item,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _conteudoPrincipal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final isWide = largura >= 1050;
        final compacto = largura < 850;
        final larguraCard = isWide
            ? 620.0
            : largura.clamp(320.0, 700.0) - 32;
        final larguraFaixita = isWide
            ? 340.0
            : largura.clamp(320.0, 620.0) - 32;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _cabecalhoInstitucional(
                  compacto: compacto,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  child: Column(
                    children: [
                      _logoSistema(
                        compacto: compacto,
                      ),
                      const SizedBox(height: 28),
                      if (isWide)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _cardLogin(
                              largura: larguraCard,
                            ),
                            const SizedBox(width: 20),
                            Transform.translate(
                              offset: const Offset(0, -6),
                              child: _cardFaixita(
                                compacto: compacto,
                                largura: larguraFaixita,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _cardLogin(
                              largura: larguraCard,
                            ),
                            const SizedBox(height: 12),
                            Transform.translate(
                              offset: const Offset(0, -4),
                              child: _cardFaixita(
                                compacto: true,
                                largura: larguraFaixita,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                _rodapeResponsivo(
                  larguraDisponivel: largura,
                ),
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
            ),
          ),
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
