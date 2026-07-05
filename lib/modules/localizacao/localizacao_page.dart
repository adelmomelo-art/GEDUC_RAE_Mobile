import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../acoes/controllers/acao_controller.dart';

class LocalizacaoPage extends StatefulWidget {
  const LocalizacaoPage({super.key});

  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage> {
  final enderecoController = TextEditingController();
  final bairroController = TextEditingController();
  final regionalController = TextEditingController();
  final equipamentoReferenciaController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  double latitude = 0;
  double longitude = 0;
  bool carregandoLocalizacao = false;

  Future<void> buscarRegionalPorBairro(String bairro) async {
    if (bairro.trim().isEmpty) return;

    final snapshot = await firestore
        .collection('regionais')
        .where('ativo', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final nomeRegional = data['nomeRegional'] ?? '';
      final bairros = List<String>.from(data['bairrosVinculados'] ?? []);

      final encontrou = bairros.any(
        (item) => item.toLowerCase().trim() == bairro.toLowerCase().trim(),
      );

      if (encontrou) {
        regionalController.text = nomeRegional;
        return;
      }
    }

    regionalController.text = '';
  }

  Future<void> obterLocalizacaoReal() async {
    try {
      setState(() => carregandoLocalizacao = true);

      final servicoAtivo = await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        throw Exception('Serviço de localização desativado.');
      }

      LocationPermission permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }

      if (permissao == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente.');
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String endereco = 'Endereço não identificado';
      String bairro = 'Bairro não identificado';

      if (!kIsWeb) {
        try {
          final enderecos = await placemarkFromCoordinates(
            posicao.latitude,
            posicao.longitude,
          );

          if (enderecos.isNotEmpty) {
            final p = enderecos.first;

            final rua = p.street ?? '';
            final numero = p.subThoroughfare ?? '';
            final subBairro = p.subLocality ?? '';
            final localidade = p.locality ?? '';

            endereco = [rua, numero]
                .where((item) => item.trim().isNotEmpty)
                .join(', ');

            if (endereco.trim().isEmpty) {
              endereco = 'Endereço não identificado';
            }

            bairro = subBairro.trim().isNotEmpty
                ? subBairro
                : localidade.trim().isNotEmpty
                    ? localidade
                    : 'Bairro não identificado';
          }
        } catch (_) {
          endereco = 'Endereço não identificado';
          bairro = 'Bairro não identificado';
        }
      }

      if (!mounted) return;

      setState(() {
        latitude = posicao.latitude;
        longitude = posicao.longitude;
        enderecoController.text = endereco;
        bairroController.text = bairro == 'Bairro não identificado' ? '' : bairro;
        regionalController.text = '';
        carregandoLocalizacao = false;
      });

      await buscarRegionalPorBairro(bairroController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Localização capturada. Complete os dados se necessário.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => carregandoLocalizacao = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
        ),
      );
    }
  }

  void confirmarLocalizacao() {
    if (latitude == 0 || longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clique em OBTER LOCALIZAÇÃO antes de avançar.'),
        ),
      );
      return;
    }

    if (enderecoController.text.trim().isEmpty ||
        bairroController.text.trim().isEmpty ||
        regionalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha endereço, bairro e regional.'),
        ),
      );
      return;
    }

    if (equipamentoReferenciaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o equipamento ou ponto de referência.'),
        ),
      );
      return;
    }

    context.read<AcaoController>().preencherLocalizacao(
          endereco: enderecoController.text.trim(),
          bairro: bairroController.text.trim(),
          regional: regionalController.text.trim(),
          equipamentoReferencia: equipamentoReferenciaController.text.trim(),
          latitude: latitude,
          longitude: longitude,
        );

    context.go('/caracterizacao');
  }

  @override
  void dispose() {
    enderecoController.dispose();
    bairroController.dispose();
    regionalController.dispose();
    equipamentoReferenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização da Ação'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Localização atual'),
              subtitle: Text(
                'Latitude: $latitude\nLongitude: $longitude',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: carregandoLocalizacao ? null : obterLocalizacaoReal,
            icon: carregandoLocalizacao
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              carregandoLocalizacao
                  ? 'OBTENDO LOCALIZAÇÃO...'
                  : 'OBTER LOCALIZAÇÃO',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: enderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço',
              hintText: 'Informe o endereço da ação',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: bairroController,
            onChanged: buscarRegionalPorBairro,
            decoration: const InputDecoration(
              labelText: 'Bairro',
              hintText: 'Informe o bairro',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: regionalController,
            decoration: const InputDecoration(
              labelText: 'Regional',
              hintText: 'Ex: SER 03',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: equipamentoReferenciaController,
            decoration: const InputDecoration(
              labelText: 'Equipamento ou ponto de referência',
              hintText: 'Ex: escola, praça, terminal, shopping, empresa...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: confirmarLocalizacao,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('CONFIRMAR E AVANÇAR'),
            ),
          ),
        ],
      ),
    );
  }
}
