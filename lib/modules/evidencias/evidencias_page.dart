import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/evidencia_storage_service.dart';
import '../../core/services/imagem_service.dart';
import '../acoes/controllers/acao_controller.dart';

class EvidenciasPage extends StatefulWidget {
  const EvidenciasPage({super.key});

  @override
  State<EvidenciasPage> createState() => _EvidenciasPageState();
}

class _EvidenciasPageState extends State<EvidenciasPage> {
  final ImagemService imagemService = ImagemService();
  final EvidenciaStorageService evidenciaStorageService =
      EvidenciaStorageService();

  final List<File> fotos = [];
  final descricaoController = TextEditingController();

  bool salvandoEvidencias = false;

  Future<void> tirarFoto() async {
    final foto = await imagemService.capturarCamera();

    if (foto == null) return;

    setState(() {
      fotos.add(foto);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto capturada com sucesso.')),
    );
  }

  Future<void> escolherFotoGaleria() async {
    final foto = await imagemService.selecionarGaleria();

    if (foto == null) return;

    setState(() {
      fotos.add(foto);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto adicionada com sucesso.')),
    );
  }

  Future<void> escolherVariasFotosGaleria() async {
    final imagens = await imagemService.selecionarMultiplasImagens();

    if (imagens.isEmpty) return;

    setState(() {
      fotos.addAll(imagens);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${imagens.length} foto(s) adicionada(s).')),
    );
  }

  void abrirOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  tirarFoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Escolher uma foto'),
                onTap: () {
                  Navigator.pop(context);
                  escolherFotoGaleria();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Selecionar várias fotos'),
                onTap: () {
                  Navigator.pop(context);
                  escolherVariasFotosGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void removerFoto(int index) {
    setState(() {
      fotos.removeAt(index);
    });
  }

  void abrirFoto(File foto) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualizacaoFotoPage(foto: foto),
      ),
    );
  }

  Future<void> avancar() async {
    if (fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma foto da ação.')),
      );
      return;
    }

    setState(() {
      salvandoEvidencias = true;
    });

    try {
      final controller = context.read<AcaoController>();

      if (controller.acaoAtual == null) {
        controller.criarRascunhoInicial();
      }

      final acaoId = controller.acaoAtual!.id;

      final evidenciasSalvas =
          await evidenciaStorageService.salvarEvidencias(
        arquivos: fotos,
        acaoId: acaoId,
      );

      final caminhosFotos =
          evidenciasSalvas.map((foto) => foto.path).toList();

      controller.preencherEvidencias(
        fotosUrls: caminhosFotos,
        descricaoEvidencias: descricaoController.text.trim(),
      );

      if (!mounted) return;

      context.go('/avaliacao');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar evidências: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvandoEvidencias = false;
        });
      }
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidências'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Registro fotográfico'),
              subtitle: Text(
                fotos.isEmpty
                    ? 'Adicione imagens da ação educativa.'
                    : '${fotos.length} foto(s) adicionada(s).',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: salvandoEvidencias ? null : abrirOpcoesFoto,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('ADICIONAR FOTO'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descricaoController,
            maxLines: 3,
            enabled: !salvandoEvidencias,
            decoration: const InputDecoration(
              labelText: 'Descrição das evidências',
              hintText:
                  'Ex: Fotos da abordagem educativa, público presente, materiais utilizados...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          if (fotos.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.image_not_supported),
                title: Text('Nenhuma foto adicionada'),
                subtitle: Text('Inclua pelo menos uma imagem para continuar.'),
              ),
            )
          else
            _GaleriaEvidencias(
              fotos: fotos,
              onAbrir: abrirFoto,
              onRemover: salvandoEvidencias ? null : removerFoto,
            ),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: salvandoEvidencias
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(
                salvandoEvidencias
                    ? 'SALVANDO EVIDÊNCIAS...'
                    : 'PRÓXIMO',
              ),
              onPressed: salvandoEvidencias ? null : avancar,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaleriaEvidencias extends StatelessWidget {
  const _GaleriaEvidencias({
    required this.fotos,
    required this.onAbrir,
    required this.onRemover,
  });

  final List<File> fotos;
  final void Function(File foto) onAbrir;
  final void Function(int index)? onRemover;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final foto = fotos[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              onTap: () => onAbrir(foto),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  foto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (onRemover != null)
              Positioned(
                right: 4,
                top: 4,
                child: InkWell(
                  onTap: () => onRemover!(index),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        title: const Text('Visualizar Foto'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.file(foto),
        ),
      ),
    );
  }
}