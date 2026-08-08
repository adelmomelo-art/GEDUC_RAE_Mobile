import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/evidencia_storage_service.dart';
import '../../core/services/imagem_service.dart';
import '../../shared/widgets/journey/fenix_journey_header.dart';
import '../../shared/widgets/layout/fenix_app_bar.dart';
import '../../shared/widgets/layout/fenix_page_scaffold.dart';
import '../acoes/controllers/acao_controller.dart';

class EvidenciasPage extends StatefulWidget {
  const EvidenciasPage({super.key});

  @override
  State<EvidenciasPage> createState() => _EvidenciasPageState();
}

class _EvidenciasPageState extends State<EvidenciasPage> {
  static const int _quantidadeRecomendada = 3;
  static const int _tamanhoMinimoDescricao = 10;

  final ImagemService _imagemService = ImagemService();
  final EvidenciaStorageService _evidenciaStorageService =
      EvidenciaStorageService();
  final TextEditingController _descricaoController = TextEditingController();

  final List<File> _fotos = [];

  bool _inicializado = false;
  bool _processando = false;

  int get _totalFotos => _fotos.length;

  bool get _possuiFotoMinima => _totalFotos >= 1;

  bool get _possuiConjuntoRecomendado => _totalFotos >= _quantidadeRecomendada;

  bool get _possuiDescricao =>
      _descricaoController.text.trim().length >= _tamanhoMinimoDescricao;

  bool get _podeAvancar => _possuiFotoMinima && _possuiDescricao;

  String get _statusDocumentacao {
    if (_podeAvancar && _possuiConjuntoRecomendado) {
      return 'Completa';
    }

    if (_podeAvancar) {
      return 'Mínimo atendido';
    }

    return 'Pendente';
  }

  String get _mensagemFaxita {
    if (!_possuiFotoMinima) {
      return 'Adicione pelo menos uma fotografia para comprovar a execução '
          'da ação educativa.';
    }

    if (!_possuiConjuntoRecomendado && !_possuiDescricao) {
      return 'O registro possui poucas fotografias e ainda não contém uma '
          'descrição contextual. Inclua mais evidências e descreva o cenário '
          'da ação.';
    }

    if (!_possuiConjuntoRecomendado) {
      return 'O requisito mínimo foi atendido. Quando possível, registre pelo '
          'menos três imagens: equipe, público e contexto da atividade.';
    }

    if (!_possuiDescricao) {
      return 'O conjunto fotográfico está adequado. Acrescente uma descrição '
          'com o contexto da ação para concluir esta etapa.';
    }

    return 'As evidências estão organizadas e aptas para integrar o relatório '
        'da ação educativa.';
  }

  Color get _corStatus {
    if (_podeAvancar && _possuiConjuntoRecomendado) {
      return Colors.green;
    }

    if (_podeAvancar || _possuiFotoMinima) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_inicializado) {
      return;
    }

    _inicializado = true;

    final controller = context.read<AcaoController>();
    final acao = controller.acaoAtual;

    if (acao == null) {
      controller.criarRascunhoInicial();
      return;
    }

    _descricaoController.text = acao.descricaoEvidencias;

    _fotos
      ..clear()
      ..addAll(
        acao.fotosUrls.map(File.new).where((arquivo) => arquivo.existsSync()),
      );
  }

  Future<String> _garantirAcaoId() async {
    final controller = context.read<AcaoController>();

    if (controller.acaoAtual == null) {
      controller.criarRascunhoInicial();
    }

    return controller.acaoAtual!.id;
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
  }

  void _sincronizarController() {
    final controller = context.read<AcaoController>();

    controller.preencherEvidencias(
      fotosUrls: _fotos.map((foto) => foto.path).toList(growable: false),
      descricaoEvidencias: _descricaoController.text.trim(),
    );
  }

  Future<void> _salvarNovasFotos(
    List<File> arquivos, {
    required String mensagemSucesso,
  }) async {
    if (arquivos.isEmpty || _processando) {
      return;
    }

    setState(() {
      _processando = true;
    });

    try {
      final acaoId = await _garantirAcaoId();

      final evidencias = await _evidenciaStorageService.salvarEvidencias(
        acaoId: acaoId,
        arquivos: arquivos,
      );

      final novasFotos = evidencias
          .map((evidencia) => File(evidencia.caminhoArquivo))
          .toList(growable: false);

      if (!mounted) {
        return;
      }

      setState(() {
        _fotos.addAll(novasFotos);
      });

      _sincronizarController();
      _mostrarMensagem(mensagemSucesso);
    } catch (erro) {
      _mostrarMensagem('Não foi possível salvar a evidência: $erro');
    } finally {
      if (mounted) {
        setState(() {
          _processando = false;
        });
      }
    }
  }

  Future<void> _tirarFoto() async {
    try {
      final foto = await _imagemService.capturarCamera();

      if (foto == null) {
        return;
      }

      await _salvarNovasFotos(
        [foto],
        mensagemSucesso: 'Foto capturada e salva com sucesso.',
      );
    } catch (erro) {
      _mostrarMensagem('Não foi possível acessar a câmera: $erro');
    }
  }

  Future<void> _escolherFotoGaleria() async {
    try {
      final foto = await _imagemService.selecionarGaleria();

      if (foto == null) {
        return;
      }

      await _salvarNovasFotos(
        [foto],
        mensagemSucesso: 'Foto adicionada com sucesso.',
      );
    } catch (erro) {
      _mostrarMensagem('Não foi possível acessar a galeria: $erro');
    }
  }

  Future<void> _escolherVariasFotosGaleria() async {
    try {
      final imagens = await _imagemService.selecionarMultiplasImagens();

      if (imagens.isEmpty) {
        return;
      }

      await _salvarNovasFotos(
        imagens,
        mensagemSucesso: '${imagens.length} foto(s) adicionada(s).',
      );
    } catch (erro) {
      _mostrarMensagem('Não foi possível acessar a galeria: $erro');
    }
  }

  void _abrirOpcoesFoto() {
    if (_processando) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              children: [
                const ListTile(
                  title: Text(
                    'Adicionar evidência',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Escolha como deseja registrar as imagens da ação.',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Tirar foto'),
                  subtitle: const Text('Usar a câmera do dispositivo'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _tirarFoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('Escolher uma foto'),
                  subtitle: const Text('Selecionar uma imagem da galeria'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _escolherFotoGaleria();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Selecionar várias fotos'),
                  subtitle: const Text('Adicionar várias imagens de uma vez'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _escolherVariasFotosGaleria();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _removerFoto(int index) async {
    if (_processando || index < 0 || index >= _fotos.length) {
      return;
    }

    final foto = _fotos[index];

    final confirmou = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Remover evidência?'),
              content: const Text(
                'A fotografia será removida desta ação e do armazenamento '
                'local do aplicativo.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('CANCELAR'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('REMOVER'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmou) {
      return;
    }

    setState(() {
      _processando = true;
    });

    try {
      await _evidenciaStorageService.excluirArquivo(foto.path);

      if (!mounted) {
        return;
      }

      setState(() {
        _fotos.removeAt(index);
      });

      _sincronizarController();
      _mostrarMensagem('Evidência removida.');
    } catch (erro) {
      _mostrarMensagem('Não foi possível remover a evidência: $erro');
    } finally {
      if (mounted) {
        setState(() {
          _processando = false;
        });
      }
    }
  }

  void _abrirFoto(File foto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisualizacaoFotoPage(foto: foto),
      ),
    );
  }

  void _voltar() {
    if (_processando) {
      return;
    }

    _sincronizarController();
    context.go('/resultados');
  }

  void _avancar() {
    if (_processando) {
      return;
    }

    if (!_possuiFotoMinima) {
      _mostrarMensagem('Adicione pelo menos uma foto da ação.');
      return;
    }

    if (!_possuiDescricao) {
      _mostrarMensagem(
        'Descreva as evidências com pelo menos '
        '$_tamanhoMinimoDescricao caracteres.',
      );
      return;
    }

    _sincronizarController();
    context.go('/avaliacao');
  }

  Widget _cabecalho() {
    return const FenixJourneyHeader(
      step: 7,
      totalSteps: 9,
      title: 'Evidências da ação',
      subtitle: 'Registre imagens e descreva o contexto da atividade.',
      icon: Icons.photo_camera_back_outlined,
    );
  }

  Widget _cardFaxita() {
    final corFundo = Color.alphaBlend(
      _corStatus.withValues(alpha: 0.10),
      Theme.of(context).colorScheme.surface,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _corStatus.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _corStatus,
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Faixita',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _mensagemFaxita,
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraItem = constraints.maxWidth >= 760
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: larguraItem,
              child: _IndicadorCard(
                titulo: 'Fotos',
                valor: '$_totalFotos',
                icone: Icons.photo_library_outlined,
              ),
            ),
            SizedBox(
              width: larguraItem,
              child: const _IndicadorCard(
                titulo: 'Obrigatórias',
                valor: '1',
                icone: Icons.task_alt_outlined,
              ),
            ),
            SizedBox(
              width: larguraItem,
              child: const _IndicadorCard(
                titulo: 'Recomendadas',
                valor: '3',
                icone: Icons.recommend_outlined,
              ),
            ),
            SizedBox(
              width: larguraItem,
              child: _IndicadorCard(
                titulo: 'Status',
                valor: _statusDocumentacao,
                icone: Icons.verified_outlined,
                valorCompacto: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _checklist() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checklist das evidências',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _itemChecklist(
              concluido: _possuiFotoMinima,
              texto: 'Pelo menos uma fotografia obrigatória',
            ),
            _itemChecklist(
              concluido: _possuiConjuntoRecomendado,
              texto: 'Conjunto recomendado de três fotografias',
              recomendacao: true,
            ),
            _itemChecklist(
              concluido: _possuiDescricao,
              texto: 'Descrição contextual com pelo menos 10 caracteres',
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemChecklist({
    required bool concluido,
    required String texto,
    bool recomendacao = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            concluido
                ? Icons.check_circle
                : recomendacao
                    ? Icons.info_outline
                    : Icons.radio_button_unchecked,
            color: concluido
                ? Colors.green
                : recomendacao
                    ? Colors.orange
                    : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  Widget _areaRegistro() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Registro fotográfico',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Inclua imagens da equipe, do público e do ambiente da ação.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _processando ? null : _abrirOpcoesFoto,
              icon: _processando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _processando ? 'PROCESSANDO EVIDÊNCIA...' : 'ADICIONAR FOTO',
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _descricaoController,
              enabled: !_processando,
              maxLines: 4,
              maxLength: 500,
              onChanged: (_) {
                setState(() {});
              },
              onEditingComplete: _sincronizarController,
              decoration: const InputDecoration(
                labelText: 'Descrição das evidências',
                hintText: 'Ex.: equipe executora, público presente, atividade '
                    'realizada e materiais utilizados.',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _galeriaOuVazio() {
    if (_fotos.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 46,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'Nenhuma fotografia adicionada',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Adicione pelo menos uma imagem para concluir esta etapa.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _GaleriaEvidencias(
      fotos: _fotos,
      processando: _processando,
      onAbrir: _abrirFoto,
      onRemover: _removerFoto,
    );
  }

  Widget _barraInferior() {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _processando ? null : _voltar,
                icon: const Icon(Icons.arrow_back),
                label: const Text('VOLTAR'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _processando ? null : _avancar,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('PRÓXIMO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _voltar();
        }
      },
      child: FenixPageScaffold(
        appBar: FenixAppBar(
          title: 'Evidências',
          onBack: _voltar,
          backEnabled: !_processando,
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _cabecalho(),
            const SizedBox(height: 16),
            _cardFaxita(),
            const SizedBox(height: 16),
            _dashboard(),
            const SizedBox(height: 16),
            _checklist(),
            const SizedBox(height: 16),
            _areaRegistro(),
            const SizedBox(height: 16),
            _galeriaOuVazio(),
            const SizedBox(height: 24),
          ],
        ),
        bottomNavigationBar: _barraInferior(),
      ),
    );
  }
}

class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    this.valorCompacto = false,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final bool valorCompacto;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              icone,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    valor,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: valorCompacto ? 14 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaleriaEvidencias extends StatelessWidget {
  const _GaleriaEvidencias({
    required this.fotos,
    required this.processando,
    required this.onAbrir,
    required this.onRemover,
  });

  final List<File> fotos;
  final bool processando;
  final void Function(File foto) onAbrir;
  final Future<void> Function(int index) onRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galeria (${fotos.length})',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fotos.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final foto = fotos[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Material(
                        color: Colors.grey.shade200,
                        child: InkWell(
                          onTap: processando ? null : () => onAbrir(foto),
                          child: Image.file(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 38,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Foto ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Remover foto',
                            visualDensity: VisualDensity.compact,
                            onPressed:
                                processando ? null : () => onRemover(index),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class VisualizacaoFotoPage extends StatelessWidget {
  const VisualizacaoFotoPage({
    super.key,
    required this.foto,
  });

  final File foto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar foto'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Image.file(
            foto,
            errorBuilder: (_, __, ___) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 54,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Não foi possível carregar esta imagem.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
