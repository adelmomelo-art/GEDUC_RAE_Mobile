import 'package:flutter/material.dart';

import '../../models/cio_dashboard_filters.dart';
import '../common/dashboard_colors.dart';
import '../common/dashboard_panel.dart';
import '../common/dashboard_title.dart';

class ExecutiveFilters extends StatefulWidget {
  const ExecutiveFilters({
    required this.filtros,
    required this.regionais,
    required this.tiposAcao,
    required this.statusDisponiveis,
    required this.coordenadores,
    required this.onAplicar,
    super.key,
  });

  final CioDashboardFilters filtros;
  final List<String> regionais;
  final List<String> tiposAcao;
  final List<String> statusDisponiveis;
  final List<String> coordenadores;
  final ValueChanged<CioDashboardFilters> onAplicar;

  @override
  State<ExecutiveFilters> createState() => _ExecutiveFiltersState();
}

class _ExecutiveFiltersState extends State<ExecutiveFilters> {
  late CioDashboardFilters _edicao;
  bool _avancados = false;

  @override
  void initState() {
    super.initState();
    _edicao = widget.filtros;
  }

  @override
  void didUpdateWidget(covariant ExecutiveFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filtros != widget.filtros) _edicao = widget.filtros;
  }

  Future<void> _selecionarPeriodoPersonalizado() async {
    final faixa = _edicao.intervalo(DateTime.now());
    final resultado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: faixa.inicio, end: faixa.fim),
      helpText: 'Selecione o período de análise',
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _edicao = _edicao.copyWith(
        periodo: CioPeriodoRapido.personalizado,
        inicioPersonalizado: resultado.start,
        fimPersonalizado: resultado.end,
      );
    });
    widget.onAplicar(_edicao);
  }

  @override
  Widget build(BuildContext context) {
    final faixa = _edicao.intervalo(DateTime.now());
    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardTitle(
            title: 'Período de análise e filtros',
            icon: Icons.filter_alt_outlined,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CioPeriodoRapido.values.map((periodo) {
              final selecionado = _edicao.periodo == periodo;
              return ChoiceChip(
                label: Text(periodo.rotulo),
                selected: selecionado,
                onSelected: (_) {
                  if (periodo == CioPeriodoRapido.personalizado) {
                    _selecionarPeriodoPersonalizado();
                    return;
                  }
                  setState(() => _edicao = _edicao.copyWith(
                        periodo: periodo,
                        limparDatas: true,
                      ));
                  widget.onAplicar(_edicao);
                },
                selectedColor: DashboardColors.primary,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: selecionado ? Colors.white : const Color(0xFF455A64),
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Período analisado: ${_data(faixa.inicio)} a ${_data(faixa.fim)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (_edicao.intervaloComparacao(DateTime.now())
              case final comparacao?)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Comparação: ${_data(comparacao.inicio)} a ${_data(comparacao.fim)}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CioComparacao>(
            initialValue: _edicao.comparacao,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Comparar com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.compare_arrows),
            ),
            items: CioComparacao.values
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item.rotulo,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (valor) {
              if (valor == null) return;
              setState(() => _edicao = _edicao.copyWith(comparacao: valor));
              widget.onAplicar(_edicao);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _avancados = !_avancados),
            icon: Icon(_avancados ? Icons.expand_less : Icons.tune),
            label: Text(
              'Filtros avançados${_edicao.quantidadeFiltrosSecundarios == 0 ? '' : ' (${_edicao.quantidadeFiltrosSecundarios})'}',
            ),
          ),
          if (_avancados) ...[
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final campos = [
                _filtro('Regional', _edicao.regional, widget.regionais,
                    (v) => _edicao = _edicao.copyWith(regional: v)),
                _filtro('Tipo de ação', _edicao.tipoAcao, widget.tiposAcao,
                    (v) => _edicao = _edicao.copyWith(tipoAcao: v)),
                _filtro(
                    'Situação do RAE',
                    _edicao.status,
                    widget.statusDisponiveis,
                    (v) => _edicao = _edicao.copyWith(status: v)),
                _filtro(
                    'Coordenador',
                    _edicao.coordenador,
                    widget.coordenadores,
                    (v) => _edicao = _edicao.copyWith(coordenador: v)),
              ];
              if (constraints.maxWidth < 700) {
                return Column(
                    children: campos
                        .expand((e) => [e, const SizedBox(height: 10)])
                        .toList());
              }
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: campos
                    .map((e) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2, child: e))
                    .toList(),
              );
            }),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _edicao = _edicao.copyWith(
                          regional: '',
                          tipoAcao: '',
                          status: '',
                          coordenador: ''));
                      widget.onAplicar(_edicao);
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('LIMPAR FILTROS'),
                  ),
                  FilledButton.icon(
                    onPressed: () => widget.onAplicar(_edicao),
                    icon: const Icon(Icons.check),
                    label: const Text('APLICAR FILTROS'),
                  ),
                ]),
          ],
          if (_edicao.quantidadeFiltrosSecundarios > 0) ...[
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_edicao.regional.isNotEmpty)
                  _etiqueta('Regional: ${_edicao.regional}',
                      () => _remover(regional: true)),
                if (_edicao.tipoAcao.isNotEmpty)
                  _etiqueta(
                      'Tipo: ${_edicao.tipoAcao}', () => _remover(tipo: true)),
                if (_edicao.status.isNotEmpty)
                  _etiqueta('Situação: ${_edicao.status}',
                      () => _remover(status: true)),
                if (_edicao.coordenador.isNotEmpty)
                  _etiqueta('Coordenador: ${_edicao.coordenador}',
                      () => _remover(coordenador: true)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filtro(String label, String valor, List<String> opcoes,
      ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label:$valor'),
      initialValue: valor.isEmpty ? '' : valor,
      isExpanded: true,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [
        const DropdownMenuItem(value: '', child: Text('Todos')),
        ...opcoes.map((item) => DropdownMenuItem(
            value: item, child: Text(item, overflow: TextOverflow.ellipsis))),
      ],
      onChanged: (novo) => setState(() => onChanged(novo ?? '')),
    );
  }

  Widget _etiqueta(String label, VoidCallback onDeleted) =>
      InputChip(label: Text(label), onDeleted: onDeleted);

  void _remover(
      {bool regional = false,
      bool tipo = false,
      bool status = false,
      bool coordenador = false}) {
    setState(() => _edicao = _edicao.copyWith(
          regional: regional ? '' : null,
          tipoAcao: tipo ? '' : null,
          status: status ? '' : null,
          coordenador: coordenador ? '' : null,
        ));
    widget.onAplicar(_edicao);
  }

  String _data(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}
