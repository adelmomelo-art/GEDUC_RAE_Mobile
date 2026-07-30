import 'package:flutter/material.dart';

import 'domain_loader_mixin.dart';

class DomainDropdown extends StatefulWidget {
  final String grupo;
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool obrigatorio;
  final bool habilitado;
  final String? hintText;
  final String? valorLegadoNome;
  final String mensagemSemOpcoes;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const DomainDropdown({
    super.key,
    required this.grupo,
    required this.label,
    required this.value,
    required this.onChanged,
    this.obrigatorio = false,
    this.habilitado = true,
    this.hintText,
    this.valorLegadoNome,
    this.mensagemSemOpcoes = 'Nenhuma opção disponível.',
    this.contentPadding,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<DomainDropdown> createState() => _DomainDropdownState();
}

class _DomainDropdownState extends State<DomainDropdown>
    with DomainLoaderMixin<DomainDropdown> {
  @override
  String domainGrupoOf(DomainDropdown widget) => widget.grupo;

  @override
  Map<String, String> domainValoresLegadosOf(DomainDropdown widget) {
    final value = widget.value?.trim();
    final nome = widget.valorLegadoNome?.trim();

    if (value == null || value.isEmpty || nome == null || nome.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{value: nome};
  }

  @override
  Widget build(BuildContext context) {
    final provider = domainProviderWatch();
    final carregando = domainCarregando(provider);
    final possuiErro = domainPossuiErro(provider);
    final valorAtual = widget.value;

    final opcoes = domainOpcoes(
      provider,
      valoresAtuais:
          valorAtual == null ? const <String>[] : <String>[valorAtual],
    );

    final valorSeguro = valorAtual != null && opcoes.containsKey(valorAtual)
        ? valorAtual
        : null;

    final assinaturaOpcoes = opcoes.keys.join('|');
    final label = widget.obrigatorio ? '${widget.label} *' : widget.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey<String>(
            '${widget.grupo}::$valorSeguro::$assinaturaOpcoes',
          ),
          initialValue: valorSeguro,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            border: const OutlineInputBorder(),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: carregando
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : possuiErro
                    ? IconButton(
                        tooltip: 'Tentar novamente',
                        onPressed: domainRecarregar,
                        icon: const Icon(Icons.refresh),
                      )
                    : null,
          ),
          items: opcoes.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: widget.habilitado && !carregando && opcoes.isNotEmpty
              ? widget.onChanged
              : null,
          validator: widget.validator,
        ),
        if (possuiErro) ...[
          const SizedBox(height: 6),
          Text(
            'Não foi possível carregar as opções. '
            'Toque no ícone para tentar novamente.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ] else if (!carregando && opcoes.isEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.mensagemSemOpcoes,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: domainRecarregar,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Atualizar'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
