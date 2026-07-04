import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/services/firebase_acao_service.dart';

class BiGeducPage extends StatefulWidget {
  const BiGeducPage({super.key});

  @override
  State<BiGeducPage> createState() => _BiGeducPageState();
}

class _BiGeducPageState extends State<BiGeducPage> {
  final FirebaseAcaoService service = FirebaseAcaoService();

  bool carregando = true;

  int totalAcoes = 0;
  int totalPessoas = 0;
  int totalVeiculos = 0;
  int totalCredenciais = 0;

  Map<String, int> regionais = {};
  Map<String, int> tipos = {};
  Map<String, int> metas = {};

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      carregando = true;
    });

    final acoes = await service.totalAcoes();
    final pessoas = await service.totalPessoasAlcancadas();
    final veiculos = await service.totalVeiculosAbordados();
    final credenciais = await service.totalCredenciaisEmitidas();
    final porRegional = await service.acoesPorRegional();
    final porTipo = await service.acoesPorTipo();
    final porMeta = await service.metasAtingidas();

    if (!mounted) return;

    setState(() {
      totalAcoes = acoes;
      totalPessoas = pessoas;
      totalVeiculos = veiculos;
      totalCredenciais = credenciais;
      regionais = porRegional;
      tipos = porTipo;
      metas = porMeta;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel BI GEDUC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarDados,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Visão Executiva GEDUC/RAE',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _indicadoresGerais(),

          const SizedBox(height: 20),

          _graficoRegional(),

          const SizedBox(height: 20),

          _graficoTipoAcao(),

          const SizedBox(height: 20),

          _graficoMetas(),

          const SizedBox(height: 20),

          _rankingRegionais(),
        ],
      ),
    );
  }

  Widget _indicadoresGerais() {
    return Column(
      children: [
        _cardIndicador(
          'Total de ações',
          totalAcoes.toString(),
          Icons.assignment,
          Colors.blue,
        ),
        _cardIndicador(
          'Pessoas alcançadas',
          totalPessoas.toString(),
          Icons.groups,
          Colors.green,
        ),
        _cardIndicador(
          'Veículos abordados',
          totalVeiculos.toString(),
          Icons.directions_car,
          Colors.orange,
        ),
        _cardIndicador(
          'Credenciais emitidas',
          totalCredenciais.toString(),
          Icons.badge,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _cardIndicador(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icone,
          size: 34,
          color: cor,
        ),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _graficoRegional() {
    if (regionais.isEmpty) {
      return _cardSemDados('Ações por regional');
    }

    final entradas = regionais.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloGrafico('Ações por Regional'),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    entradas.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entradas[index].value.toDouble(),
                          width: 20,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= entradas.length) {
                            return const Text('');
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entradas[index].key.length > 6
                                  ? entradas[index].key.substring(0, 6)
                                  : entradas[index].key,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _graficoTipoAcao() {
    if (tipos.isEmpty) {
      return _cardSemDados('Ações por tipo');
    }

    final entradas = tipos.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloGrafico('Ações por Tipo'),
            const SizedBox(height: 20),
            ...entradas.map(
              (item) => ListTile(
                leading: const Icon(Icons.category),
                title: Text(item.key),
                trailing: Text(
                  item.value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _graficoMetas() {
    if (metas.isEmpty) {
      return _cardSemDados('Metas');
    }

    final atingidas = metas['Atingidas'] ?? 0;
    final naoAtingidas = metas['Não atingidas'] ?? 0;
    final total = atingidas + naoAtingidas;

    if (total == 0) {
      return _cardSemDados('Metas');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloGrafico('Metas Atingidas'),
            const SizedBox(height: 20),
            SizedBox(
              height: 230,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: atingidas.toDouble(),
                      title: 'Sim',
                      color: Colors.green,
                      radius: 70,
                    ),
                    PieChartSectionData(
                      value: naoAtingidas.toDouble(),
                      title: 'Não',
                      color: Colors.red,
                      radius: 70,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Atingidas: $atingidas'),
            Text('Não atingidas: $naoAtingidas'),
          ],
        ),
      ),
    );
  }

  Widget _rankingRegionais() {
    if (regionais.isEmpty) {
      return _cardSemDados('Ranking de regionais');
    }

    final entradas = regionais.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituloGrafico('Ranking de Regionais'),
            const SizedBox(height: 8),
            ...entradas.map(
              (item) => ListTile(
                leading: const Icon(Icons.place),
                title: Text(item.key),
                trailing: Text(
                  item.value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloGrafico(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _cardSemDados(String titulo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '$titulo: sem dados disponíveis.',
        ),
      ),
    );
  }
}