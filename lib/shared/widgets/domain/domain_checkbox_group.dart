import 'package:flutter/material.dart';

import 'domain_loader_mixin.dart';

class DomainCheckboxGroup extends StatefulWidget {
  final String grupo;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool habilitado;
  final double larguraMinimaDuasColunas;
  final String mensagemSemOpcoes;
  final Map<String, String> valoresLegados;

  const DomainCheckboxGroup({
    super.key,
    required this.grupo,
    required this.selected,
    required this.onChanged,
    this.habilitado = true,
    this.larguraMinimaDuasColunas = 700,
    this.mensagemSemOpcoes = 'Nenhuma opção disponível.',
    this.valoresLegados = const {},
  });

  @override
  State<DomainCheckboxGroup> createState() => _DomainCheckboxGroupState();
}

class _DomainCheckboxGroupState extends State<DomainCheckboxGroup>
    with DomainLoaderMixin<DomainCheckboxGroup> {
  @override
  String domainGrupoOf(DomainCheckboxGroup widget) => widget.grupo;

  @override
  Map<String, String> domainValoresLegadosOf(
    DomainCheckboxGroup widget,
  ) {
    return widget.valoresLegados;
  }

  @override
  Widget build(BuildContext context) {
    final provider = domainProviderWatch();
    final carregando = domainCarregando(provider);
    final possuiErro = domainPossuiErro(provider);

    final opcoes = domainOpcoes(
      provider,
      valoresAtuais: widget.selected,
    );

    if (carregando && opcoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (possuiErro && opcoes.isEmpty) {
      return _ErrorState(
        onRetry: domainRecarregar,
      );
    }

    if (opcoes.isEmpty) {
      return Text(
        widget.mensagemSemOpcoes,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final duasColunas =
                constraints.maxWidth >= widget.larguraMinimaDuasColunas;
            final largura = duasColunas
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 8,
              children: opcoes.entries.map((entry) {
                final marcado = widget.selected.contains(entry.key);

                return SizedBox(
                  width: largura,
                  child: Material(
                    color: marcado
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: CheckboxListTile(
                      value: marcado,
                      dense: true,
                      enabled: widget.habilitado && !carregando,
                      controlAffinity: ListTileControlAffinity.leading,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      title: Text(entry.value),
                      onChanged: (value) {
                        final atualizados = Set<String>.from(widget.selected);

                        if (value == true) {
                          atualizados.add(entry.key);
                        } else {
                          atualizados.remove(entry.key);
                        }

                        widget.onChanged(atualizados);
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (possuiErro) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Algumas opções podem estar desatualizadas.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
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

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Não foi possível carregar as opções.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
