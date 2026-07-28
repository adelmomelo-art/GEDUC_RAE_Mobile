import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/domain_service.dart';
import '../../data/models/domain_model.dart';
import '../../repositories/domain_repository.dart';
import 'domain_form_args.dart';

class DomainFormPage extends StatefulWidget {
  final DomainFormArgs args;

  const DomainFormPage({
    super.key,
    required this.args,
  });

  @override
  State<DomainFormPage> createState() => _DomainFormPageState();
}

class _DomainFormPageState extends State<DomainFormPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final DomainRepository repository = DomainRepository(
    domainService: DomainService(),
  );

  late final TextEditingController nomeController;
  late final TextEditingController codigoController;
  late final TextEditingController descricaoController;
  late final TextEditingController ordemController;

  String grupoSelecionado = 'formacao';
  bool ativo = true;
  bool salvando = false;
  bool codigoAlteradoManual = false;

  DomainModel? get domainOrigem => widget.args.domain;

  static const Map<String, String> grupos = {
    'formacao': 'Formação',
    'publico': 'Público',
    'perfil_usuario': 'Perfil do usuário',
    'tipo_participacao': 'Tipo de participação',
    'foco_tematico': 'Foco temático',
    'fator_risco': 'Fatores de risco',
    'material': 'Materiais',
    'orgao': 'Órgãos parceiros',
    'sexo_predominante': 'Sexo predominante',
    'mudanca_comportamento': 'Mudança de comportamento',
  };

  @override
  void initState() {
    super.initState();

    final domain = domainOrigem;

    nomeController = TextEditingController(
      text: widget.args.duplicando
          ? '${domain?.nome ?? ''} — Cópia'
          : domain?.nome ?? '',
    );
    codigoController = TextEditingController(
      text: widget.args.duplicando
          ? '${domain?.codigo ?? ''}_copia'
          : domain?.codigo ?? '',
    );
    descricaoController = TextEditingController(
      text: domain?.descricao ?? '',
    );
    ordemController = TextEditingController(
      text: (domain?.ordem ?? 0).toString(),
    );

    grupoSelecionado = domain?.grupo ?? 'formacao';
    ativo = domain?.ativo ?? true;
    codigoAlteradoManual =
        widget.args.editando || widget.args.duplicando;
  }

  @override
  void dispose() {
    nomeController.dispose();
    codigoController.dispose();
    descricaoController.dispose();
    ordemController.dispose();
    super.dispose();
  }

  String normalizarCodigo(String valor) {
    var texto = valor.trim().toLowerCase();

    const acentos = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    acentos.forEach((origem, destino) {
      texto = texto.replaceAll(origem, destino);
    });

    texto = texto.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    texto = texto.replaceAll(RegExp(r'_+'), '_');
    texto = texto.replaceAll(RegExp(r'^_|_$'), '');

    return texto;
  }

  void atualizarCodigoPeloNome(String nome) {
    if (codigoAlteradoManual) {
      return;
    }

    codigoController.text = normalizarCodigo(nome);
  }

  String? validarObrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $campo.';
    }

    return null;
  }

  String? validarCodigo(String? valor) {
    final obrigatorio = validarObrigatorio(valor, 'o código');

    if (obrigatorio != null) {
      return obrigatorio;
    }

    final normalizado = normalizarCodigo(valor!);

    if (normalizado.length < 2) {
      return 'Use pelo menos 2 caracteres.';
    }

    if (normalizado != valor.trim().toLowerCase()) {
      return 'Use letras minúsculas, números e sublinhado.';
    }

    return null;
  }

  String? validarOrdem(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe a ordem.';
    }

    final ordem = int.tryParse(valor.trim());

    if (ordem == null || ordem < 0) {
      return 'Informe um número inteiro igual ou maior que zero.';
    }

    return null;
  }

  Future<bool> codigoDisponivel() async {
    final codigo = codigoController.text.trim();
    final existente = await repository.buscarPorCodigo(
      grupo: grupoSelecionado,
      codigo: codigo,
    );

    if (existente == null) {
      return true;
    }

    if (!widget.args.editando) {
      return false;
    }

    return domainOrigem?.id == existente.id;
  }

  String gerarId({
    required String grupo,
    required String codigo,
  }) {
    if (widget.args.editando) {
      final idExistente = domainOrigem?.id.trim() ?? '';

      if (idExistente.isEmpty) {
        throw StateError(
          'Domínio em edição sem identificador válido.',
        );
      }

      return idExistente;
    }

    return '${grupo}_$codigo';
  }

  Future<void> salvar() async {
    FocusScope.of(context).unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final disponivel = await codigoDisponivel();

      if (!disponivel) {
        if (!mounted) return;

        setState(() {
          salvando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Já existe um domínio com esse código no grupo selecionado.',
            ),
          ),
        );
        return;
      }

      final codigo = codigoController.text.trim();
      final id = gerarId(
        grupo: grupoSelecionado,
        codigo: codigo,
      );

      final domain = DomainModel(
        id: id,
        grupo: grupoSelecionado,
        codigo: codigo,
        nome: nomeController.text.trim(),
        descricao: descricaoController.text.trim(),
        ordem: int.parse(ordemController.text.trim()),
        ativo: ativo,
        inicioVigencia: domainOrigem?.inicioVigencia,
        fimVigencia: domainOrigem?.fimVigencia,
        metadados: domainOrigem?.metadados ?? const {},
      );

      if (widget.args.editando) {
        await repository.atualizar(domain);
      } else {
        await repository.criar(domain);
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (erro, stackTrace) {
      debugPrint('Erro ao salvar domínio: $erro');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      final mensagem = kDebugMode
          ? 'Não foi possível salvar o domínio. Erro: $erro'
          : 'Não foi possível salvar o domínio.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    }
  }

  Future<bool> confirmarSaida() async {
    if (salvando) {
      return false;
    }

    final nomeInicial = widget.args.duplicando
        ? '${domainOrigem?.nome ?? ''} — Cópia'
        : domainOrigem?.nome ?? '';
    final codigoInicial = widget.args.duplicando
        ? '${domainOrigem?.codigo ?? ''}_copia'
        : domainOrigem?.codigo ?? '';

    final alterado = nomeController.text.trim() != nomeInicial ||
        codigoController.text.trim() != codigoInicial ||
        descricaoController.text.trim() !=
            (domainOrigem?.descricao ?? '') ||
        ordemController.text.trim() !=
            (domainOrigem?.ordem ?? 0).toString() ||
        grupoSelecionado != (domainOrigem?.grupo ?? 'formacao') ||
        ativo != (domainOrigem?.ativo ?? true);

    if (!alterado) {
      return true;
    }

    final sair = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text(
            'As informações preenchidas ainda não foram salvas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );

    return sair ?? false;
  }

  String get tituloPagina {
    switch (widget.args.mode) {
      case DomainFormMode.novo:
        return 'Novo domínio';
      case DomainFormMode.editar:
        return 'Editar domínio';
      case DomainFormMode.duplicar:
        return 'Duplicar domínio';
    }
  }

  String get tituloCard {
    switch (widget.args.mode) {
      case DomainFormMode.novo:
        return 'Cadastro de domínio';
      case DomainFormMode.editar:
        return 'Atualização de domínio';
      case DomainFormMode.duplicar:
        return 'Duplicação de domínio';
    }
  }

  String get textoBotaoSalvar {
    switch (widget.args.mode) {
      case DomainFormMode.novo:
        return 'Cadastrar domínio';
      case DomainFormMode.editar:
        return 'Salvar alterações';
      case DomainFormMode.duplicar:
        return 'Cadastrar cópia';
    }
  }

  Widget campoGrupo() {
    return DropdownButtonFormField<String>(
      initialValue: grupoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Grupo',
        prefixIcon: Icon(Icons.folder_outlined),
        border: OutlineInputBorder(),
      ),
      items: grupos.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: salvando
          ? null
          : (valor) {
              if (valor == null) return;

              setState(() {
                grupoSelecionado = valor;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final podeSair = await confirmarSaida();

        if (podeSair && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tituloPagina),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.category_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tituloCard,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Os valores cadastrados serão utilizados pelos '
                              'catálogos da Plataforma Fênix.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      campoGrupo(),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nomeController,
                        enabled: !salvando,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.label_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) =>
                            validarObrigatorio(valor, 'o nome'),
                        onChanged: atualizarCodigoPeloNome,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: codigoController,
                        enabled: !salvando,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'Código',
                          helperText:
                              'Use letras minúsculas, números e sublinhado.',
                          prefixIcon: Icon(Icons.code_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: validarCodigo,
                        onChanged: (_) {
                          codigoAlteradoManual = true;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descricaoController,
                        enabled: !salvando,
                        minLines: 3,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          prefixIcon: Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ordemController,
                        enabled: !salvando,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ordem',
                          prefixIcon: Icon(Icons.format_list_numbered),
                          border: OutlineInputBorder(),
                        ),
                        validator: validarOrdem,
                      ),
                      const SizedBox(height: 4),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Domínio ativo'),
                        subtitle: Text(
                          ativo
                              ? 'Disponível para uso nos módulos.'
                              : 'Mantido no histórico, mas indisponível para uso.',
                        ),
                        value: ativo,
                        onChanged: salvando
                            ? null
                            : (valor) {
                                setState(() {
                                  ativo = valor;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  salvando ? 'Salvando...' : textoBotaoSalvar,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: salvando
                    ? null
                    : () async {
                        final podeSair = await confirmarSaida();

                        if (podeSair && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
