import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/acao_model.dart';
import '../acoes/controllers/acao_controller.dart';
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
  final _nomeLocalController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _regionalController = TextEditingController();
  final _pontoReferenciaController = TextEditingController();
  final _pesquisaEnderecoController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool? _estaNoLocal;
  bool _dadosIniciaisCarregados = false;
  bool _processando = false;

  double _latitude = 0;
  double _longitude = 0;
  double? _precisaoGps;
  DateTime? _dataHoraCaptura;

  bool get _possuiLocalizacao {
    return _latitude != 0 || _longitude != 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_dadosIniciaisCarregados) {
      return;
    }

    final acao = context.read<AcaoController>().acaoAtual;

    if (acao != null) {
      _nomeLocalController.text = acao.nomeLocal;
      _enderecoController.text = acao.endereco;
      _bairroController.text = acao.bairro;
      _regionalController.text = acao.regional;
      _pontoReferenciaController.text = acao.pontoReferencia.isNotEmpty
          ? acao.pontoReferencia
          : acao.equipamentoReferencia;

      _latitude = acao.latitude;
      _longitude = acao.longitude;
      _precisaoGps = acao.precisaoGps;
      _dataHoraCaptura = acao.dataHoraCaptura;

      _estaNoLocal = switch (acao.origemLocalizacao) {
        OrigemLocalizacao.gps => true,
        OrigemLocalizacao.enderecoInformado ||
        OrigemLocalizacao.mapa =>
          false,
        null => null,
      };
    }

    _dadosIniciaisCarregados = true;
  }

  Future<void> _buscarRegionalPorBairro(String bairro) async {
    final bairroNormalizado = bairro.trim().toLowerCase();

    if (bairroNormalizado.isEmpty) {
      if (mounted) {
        setState(() => _regionalController.clear());
      }
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('regionais')
          .where('ativo', isEqualTo: true)
          .get();

      String regionalEncontrada = '';

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final nomeRegional = (data['nomeRegional'] ?? '').toString();
        final bairros = List<String>.from(
          data['bairrosVinculados'] ?? const <String>[],
        );

        final encontrou = bairros.any(
          (item) => item.trim().toLowerCase() == bairroNormalizado,
        );

        if (encontrou) {
          regionalEncontrada = nomeRegional;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _regionalController.text = regionalEncontrada;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível identificar a Regional neste momento.',
          ),
        ),
      );
    }
  }

  void _selecionarModo(bool estaNoLocal) {
    setState(() {
      _estaNoLocal = estaNoLocal;
    });
  }

  void _acaoGpsBlocoA() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A captura por GPS será conectada no Bloco B.',
        ),
      ),
    );
  }

  void _pesquisarEnderecoBlocoA() {
    if (_pesquisaEnderecoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um endereço para pesquisar.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A pesquisa e a geocodificação serão conectadas no Bloco B.',
        ),
      ),
    );
  }

  Future<void> _confirmarEAvancar() async {
    if (_estaNoLocal == null) {
      _mostrarMensagem('Informe se você está no local da ação.');
      return;
    }

    if (_enderecoController.text.trim().isEmpty ||
        _bairroController.text.trim().isEmpty ||
        _regionalController.text.trim().isEmpty) {
      _mostrarMensagem('Preencha endereço, bairro e Regional.');
      return;
    }

    if (_pontoReferenciaController.text.trim().isEmpty) {
      _mostrarMensagem('Informe o ponto de referência.');
      return;
    }

    if (!_possuiLocalizacao) {
      _mostrarMensagem(
        'A coordenada será obtida no Bloco B. '
        'Por enquanto, valide somente a interface.',
      );
      return;
    }

    setState(() => _processando = true);

    try {
      context.read<AcaoController>().preencherLocalizacao(
            endereco: _enderecoController.text,
            bairro: _bairroController.text,
            regional: _regionalController.text,
            equipamentoReferencia: _pontoReferenciaController.text,
            latitude: _latitude,
            longitude: _longitude,
            nomeLocal: _nomeLocalController.text,
            pontoReferencia: _pontoReferenciaController.text,
            origemLocalizacao: _estaNoLocal!
                ? OrigemLocalizacao.gps
                : OrigemLocalizacao.enderecoInformado,
            precisaoGps: _precisaoGps,
            dataHoraCaptura: _dataHoraCaptura,
            localizacaoValidada: true,
          );

      if (!mounted) return;
      context.go('/caracterizacao');
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void dispose() {
    _nomeLocalController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _regionalController.dispose();
    _pontoReferenciaController.dispose();
    _pesquisaEnderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensagemFaxita = switch (_estaNoLocal) {
      true =>
        'Ótimo! No próximo bloco vou usar o GPS para localizar a ação '
            'e preencher os dados automaticamente.',
      false =>
        'Sem problemas. Informe o endereço onde a ação aconteceu e '
            'confira a posição antes de avançar.',
      null =>
        'Vamos registrar corretamente o local da ação. Primeiro, '
            'informe se você está no local onde ela aconteceu.',
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => context.go('/nova-acao'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Localização da Ação'),
      ),
      bottomNavigationBar: LocalizacaoActionBar(
        onVoltar: () => context.go('/nova-acao'),
        onAtualizarLocalizacao:
            _estaNoLocal == true ? _acaoGpsBlocoA : null,
        onAcaoPrincipal: _confirmarEAvancar,
        rotuloAcaoPrincipal: 'Confirmar e avançar',
        processando: _processando,
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
                  mensagem: mensagemFaxita,
                  tone: _estaNoLocal == null
                      ? FaxitaLocationTone.informativo
                      : FaxitaLocationTone.sucesso,
                ),
                const SizedBox(height: 12),
                _ModoLocalizacaoCard(
                  valor: _estaNoLocal,
                  onChanged: _selecionarModo,
                ),
                const SizedBox(height: 12),
                if (_estaNoLocal == false) ...[
                  EnderecoManualCard(
                    pesquisaController: _pesquisaEnderecoController,
                    onPesquisar: _pesquisarEnderecoBlocoA,
                  ),
                  const SizedBox(height: 12),
                ],
                MapaLocalizacaoWidget(
                  latitude: _latitude,
                  longitude: _longitude,
                  possuiLocalizacao: _possuiLocalizacao,
                  onCentralizar:
                      _estaNoLocal == true ? _acaoGpsBlocoA : null,
                ),
                const SizedBox(height: 12),
                GpsStatusCard(
                  latitude: _latitude,
                  longitude: _longitude,
                  precisaoGps: _precisaoGps,
                  dataHoraCaptura: _dataHoraCaptura,
                ),
                const SizedBox(height: 12),
                LocalizacaoFormCard(
                  nomeLocalController: _nomeLocalController,
                  enderecoController: _enderecoController,
                  bairroController: _bairroController,
                  regionalController: _regionalController,
                  pontoReferenciaController:
                      _pontoReferenciaController,
                  onBairroChanged: _buscarRegionalPorBairro,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModoLocalizacaoCard extends StatelessWidget {
  const _ModoLocalizacaoCard({
    required this.valor,
    required this.onChanged,
  });

  final bool? valor;
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
              'Você está no local da ação?',
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
              onSelectionChanged: (selecao) {
                if (selecao.isNotEmpty) {
                  onChanged(selecao.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
