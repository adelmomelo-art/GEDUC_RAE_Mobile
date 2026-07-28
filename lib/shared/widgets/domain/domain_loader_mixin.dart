import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/domains/domain_provider.dart';

/// Centraliza o ciclo de carregamento e os estados comuns dos widgets
/// alimentados pela Central de Domínios.
mixin DomainLoaderMixin<T extends StatefulWidget> on State<T> {
  String? _ultimoGrupoCarregado;
  String? _ultimaAssinaturaLegados;

  /// Retorna o grupo de domínio usado por uma determinada versão do widget.
  String domainGrupoOf(T widget);

  /// Retorna os valores legados que devem ser preservados no Provider.
  ///
  /// A chave é o identificador persistido e o valor é o nome exibido.
  Map<String, String> domainValoresLegadosOf(T widget);

  String get domainGrupo => domainGrupoOf(widget);

  Map<String, String> get domainValoresLegados =>
      domainValoresLegadosOf(widget);

  @override
  void initState() {
    super.initState();
    _agendarCarregamento();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    final grupoAnterior = domainGrupoOf(oldWidget);
    final assinaturaAnterior = _assinaturaLegados(
      domainValoresLegadosOf(oldWidget),
    );
    final assinaturaAtual = _assinaturaLegados(domainValoresLegados);

    if (grupoAnterior != domainGrupo) {
      _ultimoGrupoCarregado = null;
      _ultimaAssinaturaLegados = null;
      _agendarCarregamento();
      return;
    }

    if (assinaturaAnterior != assinaturaAtual) {
      _agendarCarregamento(
        forcarSincronizacaoLegados: true,
      );
    }
  }

  DomainProvider domainProviderRead() {
    return context.read<DomainProvider>();
  }

  DomainProvider domainProviderWatch() {
    return context.watch<DomainProvider>();
  }

  Map<String, String> domainOpcoes(
    DomainProvider provider, {
    Iterable<String> valoresAtuais = const <String>[],
    String mensagemValorAusente = 'Valor anteriormente informado',
  }) {
    final opcoes = provider.opcoesDoGrupo(domainGrupo);

    for (final idOriginal in valoresAtuais) {
      final id = idOriginal.trim();

      if (id.isEmpty || opcoes.containsKey(id)) {
        continue;
      }

      final nomeLegado = domainValoresLegados[id]?.trim();

      opcoes[id] =
          nomeLegado?.isNotEmpty == true ? nomeLegado! : mensagemValorAusente;
    }

    return opcoes;
  }

  bool domainCarregando(DomainProvider provider) {
    return provider.estaCarregando(domainGrupo);
  }

  bool domainPossuiErro(DomainProvider provider) {
    return provider.possuiErro(domainGrupo);
  }

  bool domainPossuiDadosDesatualizados(DomainProvider provider) {
    return provider.possuiDadosDesatualizados(domainGrupo);
  }

  Future<void> domainRecarregar() async {
    try {
      await domainProviderRead().recarregarGrupo(domainGrupo);
    } catch (_) {
      // O DomainProvider mantém o erro para apresentação no widget.
    }
  }

  void _agendarCarregamento({
    bool forcarSincronizacaoLegados = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final grupo = domainGrupo.trim();

      if (grupo.isEmpty) {
        return;
      }

      final assinaturaAtual = _assinaturaLegados(domainValoresLegados);
      final grupoJaCarregado = _ultimoGrupoCarregado == grupo;
      final legadosJaSincronizados =
          _ultimaAssinaturaLegados == assinaturaAtual;

      if (grupoJaCarregado &&
          legadosJaSincronizados &&
          !forcarSincronizacaoLegados) {
        return;
      }

      final provider = domainProviderRead();

      _preservarValoresLegados(
        provider: provider,
        grupo: grupo,
        valoresLegados: domainValoresLegados,
      );

      _ultimaAssinaturaLegados = assinaturaAtual;

      if (grupoJaCarregado) {
        return;
      }

      _ultimoGrupoCarregado = grupo;

      provider.carregarGrupo(grupo).catchError((Object _) {
        // O DomainProvider mantém o erro para apresentação no widget.
        return provider.dominiosDoGrupo(grupo);
      });
    });
  }

  void _preservarValoresLegados({
    required DomainProvider provider,
    required String grupo,
    required Map<String, String> valoresLegados,
  }) {
    for (final entry in valoresLegados.entries) {
      final id = entry.key.trim();
      final nome = entry.value.trim();

      if (id.isEmpty || nome.isEmpty) {
        continue;
      }

      provider.preservarValorLegado(
        grupo: grupo,
        id: id,
        nome: nome,
      );
    }
  }

  String _assinaturaLegados(Map<String, String> valores) {
    final entries = valores.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .map((entry) => '${entry.key.trim()}=${entry.value.trim()}')
        .join('|');
  }
}
