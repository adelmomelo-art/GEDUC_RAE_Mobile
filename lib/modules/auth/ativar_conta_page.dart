import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../usuarios/services/cadastro_usuario_service.dart';

class AtivarContaPage extends StatefulWidget {
  const AtivarContaPage({super.key});

  @override
  State<AtivarContaPage> createState() => _AtivarContaPageState();
}

class _AtivarContaPageState extends State<AtivarContaPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  bool _processando = false;
  bool _ocultar = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (_senha.text.length < 8 || _senha.text != _confirmacao.text) {
      _mensagem('Use ao menos 8 caracteres e confirme a mesma senha.');
      return;
    }
    setState(() => _processando = true);
    try {
      await CadastroUsuarioService().criarIdentidade(
        email: _email.text,
        senha: _senha.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirme seu e-mail'),
          content: const Text(
            'A identidade foi criada. Abra a mensagem enviada ao seu e-mail, '
            'confirme o endereço e depois entre normalmente. Na tela de acesso, '
            'informe o código recebido da administração.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ENTENDI'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/login');
    } on FirebaseAuthException catch (erro) {
      _mensagem(erro.message ?? 'Não foi possível criar a identidade.');
    } catch (erro) {
      _mensagem('Não foi possível criar a identidade: $erro');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ativar conta convidada')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Use exatamente o e-mail que recebeu o convite. '
                      'A conta permanecerá inativa até a revisão administrativa.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      key: const ValueKey('ativacao-email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail do convite',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('ativacao-senha'),
                      controller: _senha,
                      obscureText: _ocultar,
                      decoration: InputDecoration(
                        labelText: 'Crie uma senha',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                          icon: Icon(
                            _ocultar ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('ativacao-confirmar-senha'),
                      controller: _confirmacao,
                      obscureText: _ocultar,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('ativacao-criar-identidade'),
                        onPressed: _processando ? null : _criar,
                        icon: const Icon(Icons.mark_email_read_outlined),
                        label: Text(
                          _processando
                              ? 'CRIANDO...'
                              : 'CRIAR E CONFIRMAR E-MAIL',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
