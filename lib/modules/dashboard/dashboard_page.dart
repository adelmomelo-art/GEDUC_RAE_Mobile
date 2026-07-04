import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/services/firebase_acao_service.dart';
import '../../core/services/offline_service.dart';
import '../../core/services/sync_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAcaoService service = FirebaseAcaoService();
  final OfflineService offlineService = OfflineService();

  late final SyncService syncService;

  int totalAcoes = 0;
  int totalPessoas = 0;
  int totalVeiculos = 0;
  int totalCredenciais = 0;

  int totalPendentes = 0;
  int totalSincronizadas = 0;
  bool online = false;
  DateTime? ultimaSincronizacao;

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    syncService = SyncService(
      offlineService: offlineService,
      firebaseService: service,
    );

    syncService.addListener(_atualizarSyncListener);
    carregarIndicadores();
  }

  @override
  void dispose() {
    syncService.removeListener(_atualizarSyncListener);
    super.dispose();
  }

  void _atualizarSyncListener() {
    if (!mounted) return;

    setState(() {
      totalSincronizadas = syncService.totalSincronizadas;
    });
  }

  Future<void> carregarIndicadores() async {
    setState(() {
      carregando = true;
    });

    final acoes = await service.totalAcoes();
    final pessoas = await service.totalPessoasAlcancadas();
    final veiculos = await service.totalVeiculosAbordados();
    final credenciais = await service.totalCredenciaisEmitidas();
    final pendentes = await offlineService.listarAcoesPendentes();
    final conectado = await syncService.temInternet();

    if (!mounted) return;

    setState(() {
      totalAcoes = acoes;
      totalPessoas = pessoas;
      totalVeiculos = veiculos;
      totalCredenciais = credenciais;
      totalPendentes = pendentes.length;
      online = conectado;
      carregando = false;
    });
  }

  Future<void> sincronizarAgora() async {
    await syncService.sincronizarAcoesPendentes();

    final pendentes = await offlineService.listarAcoesPendentes();
    final conectado = await syncService.temInternet();

    if (!mounted) return;

    setState(() {
      totalPendentes = pendentes.length;
      totalSincronizadas = syncService.totalSincronizadas;
      online = conectado;
      ultimaSincronizacao = DateTime.now();
    });

    await carregarIndicadores();

    if (!mounted) return;

    final mensagem = syncService.erro == null
        ? 'Sincronização concluída.'
        : syncService.erro!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Executivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarIndicadores,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Indicadores GEDUC/RAE',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _cardSincronizacao(),
          const SizedBox(height: 16),
          _cardIndicador(
            icon: Icons.assignment,
            titulo: 'Total de ações',
            valor: totalAcoes.toString(),
            cor: Colors.blue,
          ),
          _cardIndicador(
            icon: Icons.groups,
            titulo: 'Pessoas alcançadas',
            valor: totalPessoas.toString(),
            cor: Colors.green,
          ),
          _cardIndicador(
            icon: Icons.directions_car,
            titulo: 'Veículos abordados',
            valor: totalVeiculos.toString(),
            cor: Colors.orange,
          ),
          _cardIndicador(
            icon: Icons.badge,
            titulo: 'Credenciais emitidas',
            valor: totalCredenciais.toString(),
            cor: Colors.purple,
          ),
          const SizedBox(height: 24),
          _graficoBarras(),
          const SizedBox(height: 24),
          _graficoPizza(),
          const SizedBox(height: 24),
          _cardStatusSistema(),
        ],
      ),
    );
  }

  Widget _cardSincronizacao() {
    final status = syncService.sincronizando
        ? 'Sincronizando...'
        : online
            ? 'Online'
            : 'Offline';

    final icone = syncService.sincronizando
        ? Icons.sync
        : online
            ? Icons.cloud_done
            : Icons.cloud_off;

    final cor = syncService.sincronizando
        ? Colors.orange
        : online
            ? Colors.green
            : Colors.red;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                icone,
                color: cor,
                size: 36,
              ),
              title: const Text(
                'Sincronização',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(status),
            ),
            const Divider(),
            Text('RAEs pendentes: $totalPendentes'),
            Text('RAEs sincronizadas nesta sessão: $totalSincronizadas'),
            Text(
              'Última sincronização: ${_formatarDataHora(ultimaSincronizacao)}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    syncService.sincronizando ? null : sincronizarAgora,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardIndicador({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          size: 36,
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

  Widget _graficoBarras() {
    final maiorValor = [
      totalPessoas,
      totalVeiculos,
      totalCredenciais,
    ].reduce((a, b) => a > b ? a : b);

    final maxY = maiorValor == 0 ? 10.0 : maiorValor * 1.2;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativo de resultados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: [
                    _barra(0, totalPessoas.toDouble(), Colors.green),
                    _barra(1, totalVeiculos.toDouble(), Colors.orange),
                    _barra(2, totalCredenciais.toDouble(), Colors.purple),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Pessoas');
                            case 1:
                              return const Text('Veículos');
                            case 2:
                              return const Text('Cred.');
                            default:
                              return const Text('');
                          }
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

  BarChartGroupData _barra(
    int x,
    double valor,
    Color cor,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: valor,
          color: cor,
          width: 26,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _graficoPizza() {
    final soma = totalPessoas + totalVeiculos + totalCredenciais;

    if (soma == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Ainda não há dados suficientes para o gráfico.'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição dos indicadores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: totalPessoas.toDouble(),
                      title: 'Pessoas',
                      color: Colors.green,
                      radius: 70,
                    ),
                    PieChartSectionData(
                      value: totalVeiculos.toDouble(),
                      title: 'Veículos',
                      color: Colors.orange,
                      radius: 70,
                    ),
                    PieChartSectionData(
                      value: totalCredenciais.toDouble(),
                      title: 'Cred.',
                      color: Colors.purple,
                      radius: 70,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardStatusSistema() {
    return const Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.cloud_done, color: Colors.teal),
            title: Text('Firebase'),
            subtitle: Text('Sincronização ativa'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.qr_code, color: Colors.blue),
            title: Text('RAE Digital'),
            subtitle: Text('QR Code e PDF ativados'),
          ),
        ],
      ),
    );
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) {
      return 'Ainda não realizada';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}