import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/domains/domain_provider.dart';

class DomainRadioGroup extends StatefulWidget {
  final String grupo;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool habilitado;
  final bool permitirLimpar;
  final Axis direcao;
  final String mensagemSemOpcoes;
  final String? valorLegadoNome;

  const DomainRadioGroup({
    super.key,
    required this.grupo,
    required this.value,
    required this.onChanged,
    this.habilitado = true,
    this.permitirLimpar = false,
    this.direcao = Axis.vertical,
    this.mensagemSemOpcoes = 'Nenhuma opção disponível.',
    this.valorLegadoNome,
  });

  @override
  State<DomainRadioGroup> createState() => _DomainRadioGroupState();
}

class _DomainRadioGroupState extends State<DomainRadioGroup> {
  String? _ultimoGrupoCarregado;

  @override
  void initState() {
    super.initState();
    _agendarCarregamento();
  }

  @override
  void didUpdateWidget(covariant DomainRadioGroup oldWidget) {
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
        // O DomainProvider mantém o erro para apresentação no widget.
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
    if (valorAtual != null &&
        valorAtual.trim().isNotEmpty &&
        !opcoes.containsKey(valorAtual)) {
      opcoes[valorAtual] = widget.valorLegadoNome?.trim().isNotEmpty == true
          ? widget.valorLegadoNome!.trim()
          : 'Valor anteriormente informado';
    }

    if (carregando && opcoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (possuiErro && opcoes.isEmpty) {
      return _RadioErrorState(
        onRetry: () {
          context
              .read<DomainProvider>()
              .recarregarGrupo(widget.grupo)
              .catchError((_) {});
        },
      );
    }

    if (opcoes.isEmpty) {
      return Text(
        widget.mensagemSemOpcoes,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    final itens = opcoes.entries.map((entry) {
      return RadioListTile<String>(
        value: entry.key,
        dense: true,
        enabled: widget.habilitado && !carregando,
        title: Text(entry.value),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }).toList();

    return RadioGroup<String>(
      groupValue: valorAtual,
      onChanged: widget.habilitado && !carregando
          ? widget.onChanged
          : (_) {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.direcao == Axis.vertical)
            ...itens
          else
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: itens
                  .map(
                    (item) => SizedBox(
                      width: 260,
                      child: item,
                    ),
                  )
                  .toList(),
            ),
        if (widget.permitirLimpar && valorAtual != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.habilitado ? () => widget.onChanged(null) : null,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Limpar seleção'),
            ),
          ),
          if (possuiErro)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'As opções podem estar desatualizadas.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _RadioErrorState({required this.onRetry});

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
