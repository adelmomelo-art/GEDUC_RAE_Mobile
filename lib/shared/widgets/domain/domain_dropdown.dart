import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/domains/domain_provider.dart';

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

class _DomainDropdownState extends State<DomainDropdown> {
  String? _ultimoGrupoCarregado;

  @override
  void initState() {
    super.initState();
    _agendarCarregamento();
  }

  @override
  void didUpdateWidget(covariant DomainDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.grupo != widget.grupo) {
      _ultimoGrupoCarregado = null;
      _agendarCarregamento();
    }
  }

  void _agendarCarregamento() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _ultimoGrupoCarregado == widget.grupo) {
        return;
      }

      _ultimoGrupoCarregado = widget.grupo;
      final provider = context.read<DomainProvider>();

      final value = widget.value;
      final nomeLegado = widget.valorLegadoNome;

      if (value != null &&
          value.trim().isNotEmpty &&
          nomeLegado != null &&
          nomeLegado.trim().isNotEmpty) {
        provider.preservarValorLegado(
          grupo: widget.grupo,
          id: value,
          nome: nomeLegado,
        );
      }

      provider.carregarGrupo(widget.grupo).catchError((Object _) {
        // O estado de erro é mantido pelo DomainProvider e exibido pelo widget.
        return provider.dominiosDoGrupo(widget.grupo);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DomainProvider>();
    final dominios = provider.dominiosDoGrupo(widget.grupo);
    final carregando = provider.estaCarregando(widget.grupo);
    final possuiErro = provider.possuiErro(widget.grupo);

    final opcoes = <String, String>{
      for (final dominio in dominios) dominio.id: dominio.nome,
    };

    final valorAtual = widget.value;
    final valorAusente = valorAtual != null &&
        valorAtual.trim().isNotEmpty &&
        !opcoes.containsKey(valorAtual);

    if (valorAusente) {
      opcoes[valorAtual] = widget.valorLegadoNome?.trim().isNotEmpty == true
          ? widget.valorLegadoNome!.trim()
          : 'Valor anteriormente informado';
    }

    final label = widget.obrigatorio ? '${widget.label} *' : widget.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: valorAtual,
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
                        onPressed: () {
                          context
                              .read<DomainProvider>()
                              .recarregarGrupo(widget.grupo)
                              .catchError((_) {});
                        },
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
            'Não foi possível carregar as opções. Toque no ícone para tentar novamente.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ] else if (!carregando && opcoes.isEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.mensagemSemOpcoes,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
