import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/localizacao/location_exception.dart';
import '../acoes/controllers/acao_controller.dart';
import 'controllers/localizacao_controller.dart';
import 'widgets/endereco_manual_card.dart';
import 'widgets/faxita_location_card.dart';
import 'widgets/gps_status_card.dart';
import 'widgets/localizacao_action_bar.dart';
import 'widgets/localizacao_form_card.dart';
import 'widgets/mapa_localizacao_widget.dart';

class LocalizacaoPage extends StatefulWidget {
  const LocalizacaoPage({super.key});

  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage> {
  late final LocalizacaoController _localizacaoController;

  String? _mensagemFaxitaTemporaria;
  FaxitaLocationTone? _toneFaxitaTemporario;

  @override
  void initState() {
    super.initState();
    _localizacaoController = LocalizacaoController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final acao = context.read<AcaoController>().acaoAtual;
    _localizacaoController.carregarDadosIniciais(acao);
  }

  Future<void> _capturarLocalizacaoGps() async {
    if (_localizacaoController.capturandoGps) {
      return;
    }

    _limparFeedbackFaxita();

    try {
      final resultado = await _localizacaoController.capturarLocalizacaoGps();

      if (!mounted) {
        return;
      }

      _localizacaoController.sincronizarComAcao(
        context.read<AcaoController>(),
        localizacaoValidada: false,
      );

      final enderecoFoiIdentificado =
          _localizacaoController.enderecoController.text.trim().isNotEmpty;

      _mostrarMensagem(
        enderecoFoiIdentificado
            ? 'Localização e endereço identificados com precisão aproximada '
                'de ${resultado.precisao.toStringAsFixed(1)} metros.'
            : 'Localização capturada com precisão aproximada de '
                '${resultado.precisao.toStringAsFixed(1)} metros. '
                'Confira e complete os dados do endereço.',
      );
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }

      _registrarErroFaxita(error.message);
      await _tratarErroLocalizacao(error);
    } catch (_) {
      if (!mounted) {
        return;
      }

      const mensagem =
          'Não foi possível obter a localização neste momento.';
      _registrarErroFaxita(mensagem);
      _mostrarMensagem(mensagem);
    }
  }

  Future<void> _buscarRegionalPorBairro(String bairro) async {
    _limparFeedbackFaxita();

    try {
      final resultado =
          await _localizacaoController.buscarRegionalPorBairro(bairro);

      if (!mounted || bairro.trim().isEmpty) {
        return;
      }

      if (!resultado.encontrada) {
        final mensagem = 'Identifiquei o bairro “${bairro.trim()}”, mas não '
            'encontrei uma Regional correspondente na base territorial. '
            'Preencha a Regional manualmente e depois revise o cadastro '
            'de bairros no Firebase.';

        _registrarErroFaxita(mensagem);
        _mostrarMensagem(
          'Regional não identificada. O campo foi liberado para '
          'preenchimento manual.',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      const mensagem =
          'Não foi possível identificar a Regional neste momento. '
          'Preencha o campo manualmente.';
      _registrarErroFaxita(mensagem);
      _mostrarMensagem(mensagem);
    }
  }

  Future<void> _pesquisarEndereco() async {
    final enderecoPesquisa =
        _localizacaoController.pesquisaEnderecoController.text.trim();

    if (enderecoPesquisa.isEmpty) {
      const mensagem = 'Informe um endereço para pesquisar.';
      _registrarErroFaxita(mensagem);
      _mostrarMensagem(mensagem);
      return;
    }

    _limparFeedbackFaxita();

    try {
      final resultado =
          await _localizacaoController.pesquisarEnderecoInformado();

      if (!mounted) {
        return;
      }

      _localizacaoController.sincronizarComAcao(
        context.read<AcaoController>(),
        localizacaoValidada: false,
      );

      final bairro = _localizacaoController.bairroController.text.trim();
      final regional = _localizacaoController.regionalController.text.trim();

      setState(() {
        _mensagemFaxitaTemporaria =
            'Endereço localizado no mapa. Confira os dados preenchidos'
            '${bairro.isNotEmpty ? ', o bairro $bairro' : ''}'
            '${regional.isNotEmpty ? ' e a Regional $regional' : ''} '
            'antes de confirmar.';
        _toneFaxitaTemporario = FaxitaLocationTone.sucesso;
      });

      _mostrarMensagem(
        'Endereço localizado em '
        '${resultado.latitude.toStringAsFixed(6)}, '
        '${resultado.longitude.toStringAsFixed(6)}.',
      );
    } on LocationException catch (_) {
      if (!mounted) {
        return;
      }

      const mensagem =
          'Não encontrei uma localização válida para esse endereço. '
          'Acrescente número, bairro e cidade e tente novamente.';
      _registrarErroFaxita(mensagem);
      _mostrarMensagem(mensagem);
    } catch (_) {
      if (!mounted) {
        return;
      }

      const mensagem =
          'Não foi possível pesquisar o endereço neste momento.';
      _registrarErroFaxita(mensagem);
      _mostrarMensagem(mensagem);
    }
  }

  Future<void> _selecionarLocalNoMapa(
    double latitude,
    double longitude,
  ) async {
    if (_localizacaoController.ocupado ||
        _localizacaoController.estaNoLocal != false) {
      return;
    }

    _limparFeedbackFaxita();

    try {
      await _localizacaoController.atualizarPorSelecaoManual(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) {
        return;
      }

      _localizacaoController.sincronizarComAcao(
        context.read<AcaoController>(),
        localizacaoValidada: false,
      );

      final bairro = _localizacaoController.bairroController.text.trim();
      final regional = _localizacaoController.regionalController.text.trim();

      setState(() {
        _mensagemFaxitaTemporaria =
            'Ponto selecionado no mapa. Confira o endereço'
            '${bairro.isNotEmpty ? ', o bairro $bairro' : ''}'
            '${regional.isNotEmpty ? ' e a Regional $regional' : ''} '
            'antes de confirmar.';
        _toneFaxitaTemporario = FaxitaLocationTone.sucesso;
      });

      _mostrarMensagem(
        'Localização selecionada em '
        '${latitude.toStringAsFixed(6)}, '
        '${longitude.toStringAsFixed(6)}.',
      );
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }

      _registrarErroFaxita(error.message);
      _mostrarMensagem(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      const mensagem =
          'Não foi possível identificar o endereço deste ponto. '
          'Tente novamente ou preencha os dados manualmente.';
      _registrarErroFaxita(mensagem);
      _mostrarMensagem(mensagem);
    }
  }

  void _salvarEVoltar() {
    if (_localizacaoController.ocupado) {
      return;
    }

    _limparFeedbackFaxita();
    _localizacaoController.sincronizarComAcao(
      context.read<AcaoController>(),
      localizacaoValidada: false,
    );

    context.go('/nova-acao');
  }

  Future<void> _confirmarEAvancar() async {
    if (_localizacaoController.ocupado) {
      return;
    }

    final mensagemValidacao = _localizacaoController.validarParaAvancar();

    if (mensagemValidacao != null) {
      _registrarErroFaxita(mensagemValidacao);
      _mostrarMensagem(mensagemValidacao);
      return;
    }

    _limparFeedbackFaxita();
    _localizacaoController.iniciarProcessamento();

    try {
      _localizacaoController.sincronizarComAcao(
        context.read<AcaoController>(),
        localizacaoValidada: true,
      );

      if (!mounted) {
        return;
      }

      context.go('/caracterizacao');
    } finally {
      if (mounted) {
        _localizacaoController.finalizarProcessamento();
      }
    }
  }

  Future<void> _tratarErroLocalizacao(
    LocationException error,
  ) async {
    switch (error.type) {
      case LocationExceptionType.servicoDesativado:
        await _mostrarDialogoConfiguracao(
          titulo: 'GPS desativado',
          mensagem: error.message,
          rotuloAcao: 'Abrir localização',
          onConfirmar: _localizacaoController.abrirConfiguracoesDeLocalizacao,
        );

      case LocationExceptionType.permissaoNegadaPermanentemente:
        await _mostrarDialogoConfiguracao(
          titulo: 'Permissão bloqueada',
          mensagem: error.message,
          rotuloAcao: 'Abrir configurações',
          onConfirmar: _localizacaoController.abrirConfiguracoesDoAplicativo,
        );

      default:
        _mostrarMensagem(error.message);
    }
  }

  Future<void> _mostrarDialogoConfiguracao({
    required String titulo,
    required String mensagem,
    required String rotuloAcao,
    required Future<void> Function() onConfirmar,
  }) async {
    final abrir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Agora não'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(rotuloAcao),
            ),
          ],
        );
      },
    );

    if (abrir != true || !mounted) {
      return;
    }

    try {
      await onConfirmar();
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }

      _registrarErroFaxita(error.message);
      _mostrarMensagem(error.message);
    }
  }

  void _selecionarModo(bool valor) {
    _limparFeedbackFaxita();
    _localizacaoController.selecionarModo(valor);
  }

  void _dadosForamEditados() {
    _limparFeedbackFaxita();
    _localizacaoController.notificarEdicaoDeDados();
  }

  void _regionalFoiEditada(String valor) {
    _limparFeedbackFaxita();
    _localizacaoController.registrarEdicaoManualDaRegional(valor);
  }

  void _registrarErroFaxita(String mensagem) {
    if (!mounted) {
      return;
    }

    setState(() {
      _mensagemFaxitaTemporaria = mensagem;
      _toneFaxitaTemporario = FaxitaLocationTone.erro;
    });
  }

  void _limparFeedbackFaxita() {
    if (!mounted ||
        (_mensagemFaxitaTemporaria == null &&
            _toneFaxitaTemporario == null)) {
      return;
    }

    setState(() {
      _mensagemFaxitaTemporaria = null;
      _toneFaxitaTemporario = null;
    });
  }

  FaxitaLocationTone _obterToneFaxita(
    LocalizacaoController controller,
  ) {
    if (_toneFaxitaTemporario != null) {
      return _toneFaxitaTemporario!;
    }

    if (controller.ocupado || controller.estaNoLocal == null) {
      return FaxitaLocationTone.atencao;
    }

    if (controller.validarParaAvancar() == null) {
      return FaxitaLocationTone.sucesso;
    }

    return FaxitaLocationTone.informativo;
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void dispose() {
    _localizacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _localizacaoController,
      builder: (context, _) {
        final controller = _localizacaoController;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _salvarEVoltar();
            }
          },
          child: Scaffold(
            appBar: AppBar(
            leading: IconButton(
              tooltip: 'Voltar',
              onPressed: controller.ocupado ? null : _salvarEVoltar,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Localização da Ação'),
          ),
          bottomNavigationBar: LocalizacaoActionBar(
            onVoltar: controller.ocupado ? null : _salvarEVoltar,
            onAtualizarLocalizacao:
                controller.estaNoLocal == true && !controller.ocupado
                    ? _capturarLocalizacaoGps
                    : null,
            onAcaoPrincipal: controller.ocupado ? null : _confirmarEAvancar,
            rotuloAcaoPrincipal: 'Confirmar e avançar',
            processando: controller.ocupado,
          ),
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    FaxitaLocationCard(
                      mensagem: _mensagemFaxitaTemporaria ??
                          controller.mensagemFaxita,
                      tone: _obterToneFaxita(controller),
                    ),
                    const SizedBox(height: 12),
                    _ModoLocalizacaoCard(
                      valor: controller.estaNoLocal,
                      habilitado: !controller.ocupado,
                      onChanged: _selecionarModo,
                    ),
                    const SizedBox(height: 12),
                    if (controller.estaNoLocal == false) ...[
                      EnderecoManualCard(
                        pesquisaController:
                            controller.pesquisaEnderecoController,
                        onPesquisar:
                            controller.ocupado ? null : _pesquisarEndereco,
                        pesquisando: controller.consultandoEndereco,
                      ),
                      const SizedBox(height: 12),
                    ],
                    MapaLocalizacaoWidget(
                      latitude: controller.latitude,
                      longitude: controller.longitude,
                      possuiLocalizacao: controller.possuiLocalizacao,
                      onCentralizar:
                          controller.estaNoLocal == true && !controller.ocupado
                              ? _capturarLocalizacaoGps
                              : null,
                      selecaoHabilitada:
                          controller.estaNoLocal == false && !controller.ocupado,
                      onSelecionarLocal:
                          controller.estaNoLocal == false && !controller.ocupado
                              ? _selecionarLocalNoMapa
                              : null,
                    ),
                    const SizedBox(height: 12),
                    GpsStatusCard(
                      latitude: controller.latitude,
                      longitude: controller.longitude,
                      precisaoGps: controller.precisaoGps,
                      dataHoraCaptura: controller.dataHoraCaptura,
                    ),
                    const SizedBox(height: 12),
                    LocalizacaoFormCard(
                      nomeLocalController: controller.nomeLocalController,
                      enderecoController: controller.enderecoController,
                      bairroController: controller.bairroController,
                      regionalController: controller.regionalController,
                      pontoReferenciaController:
                          controller.pontoReferenciaController,
                      onBairroChanged: _buscarRegionalPorBairro,
                      onRegionalChanged: _regionalFoiEditada,
                      onDadosChanged: _dadosForamEditados,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}

class _ModoLocalizacaoCard extends StatelessWidget {
  const _ModoLocalizacaoCard({
    required this.valor,
    required this.habilitado,
    required this.onChanged,
  });

  final bool? valor;
  final bool habilitado;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha uma opção',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.my_location),
                  label: Text('Sim, estou no local'),
                ),
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.edit_location_alt_outlined),
                  label: Text('Não estou no local'),
                ),
              ],
              selected: valor == null ? const <bool>{} : {valor!},
              emptySelectionAllowed: true,
              onSelectionChanged: habilitado
                  ? (selecao) {
                      if (selecao.isNotEmpty) {
                        onChanged(selecao.first);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
