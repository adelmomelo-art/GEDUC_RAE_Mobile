import 'package:flutter/material.dart';

import '../services/cio_territorial_governance_service.dart';
import 'common/dashboard_panel.dart';

class CioTerritorialGovernancePanel extends StatelessWidget {
  const CioTerritorialGovernancePanel({
    required this.report,
    required this.diagnostic,
    required this.catalogUnavailable,
    super.key,
  });

  final CioTerritorialGovernanceReport? report;
  final CioTerritorialDiagnostic? diagnostic;
  final bool catalogUnavailable;

  @override
  Widget build(BuildContext context) {
    final current = report;
    return DashboardPanel(
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portão de qualidade territorial',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Diagnóstico consultivo. Nenhum RAE é alterado automaticamente.',
            ),
            const SizedBox(height: 16),
            if (catalogUnavailable)
              const _GateMessage(
                icon: Icons.cloud_off_outlined,
                text:
                    'Catálogo territorial indisponível. O mapa permanece bloqueado.',
              )
            else if (current == null)
              const _GateMessage(
                icon: Icons.hourglass_empty_rounded,
                text: 'Aguardando leitura do catálogo territorial.',
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      'Cobertura institucional ${_percent(current.institutionalCoverage)}',
                    ),
                  ),
                  Chip(
                    label: Text(
                      'Coordenadas utilizáveis ${_percent(current.coordinateCoverage)}',
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${current.catalog.activeRegionals} regionais ativas',
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${current.catalog.neighborhoodConflicts.length} conflitos de bairro',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ClassificationGrid(report: current),
              const SizedBox(height: 12),
              _GateMessage(
                icon: Icons.lock_outline_rounded,
                text: _gateMessage(current),
              ),
              if (diagnostic != null) ...[
                const SizedBox(height: 20),
                _SanitationQueue(diagnostic: diagnostic!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static String _percent(double value) => '${(value * 100).round()}%';

  static String _gateMessage(CioTerritorialGovernanceReport report) {
    final coverageApproved = report.institutionalCoverage >= 0.95;
    final catalogApproved = !report.catalog.hasNeighborhoodConflicts;
    if (coverageApproved && catalogApproved) {
      return 'Critérios de catálogo e ID aprovados. O mapa ainda depende de limite municipal, fonte e licença oficiais.';
    }
    return 'Mapa bloqueado: cobertura mínima de 95% e zero conflitos de bairro ainda não foram comprovados.';
  }
}

class _SanitationQueue extends StatelessWidget {
  const _SanitationQueue({required this.diagnostic});

  final CioTerritorialDiagnostic diagnostic;

  @override
  Widget build(BuildContext context) {
    final queue = diagnostic.sanitationQueue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fila consultiva · últimos 12 meses',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${_date(diagnostic.start)} a ${_date(diagnostic.end)} · '
          '${diagnostic.report.validations.length} RAEs avaliados',
        ),
        const SizedBox(height: 8),
        if (queue.isEmpty)
          const Text('Nenhuma pendência territorial identificada no período.')
        else ...[
          Text('${queue.length} RAEs exigem avaliação.'),
          const SizedBox(height: 4),
          ...queue.map(
            (item) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                item.raeNumber.trim().isEmpty
                    ? 'RAE ${item.actionId}'
                    : 'RAE ${item.raeNumber}',
              ),
              subtitle: Text(
                '${_classification(item.classification)} · ${_date(item.occurredAt)}',
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      [
                        if (item.regionalName.trim().isNotEmpty)
                          'Regional informada: ${item.regionalName.trim()}',
                        if (item.neighborhood.trim().isNotEmpty)
                          'Bairro: ${item.neighborhood.trim()}',
                        ...item.findings.map(_finding),
                      ].join('\n'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _classification(CioTerritorialClassification value) {
    switch (value) {
      case CioTerritorialClassification.valid:
        return 'Válido';
      case CioTerritorialClassification.legacy:
        return 'Legado';
      case CioTerritorialClassification.orphan:
        return 'ID órfão';
      case CioTerritorialClassification.inactive:
        return 'Regional inativa';
      case CioTerritorialClassification.ambiguous:
        return 'Bairro ambíguo';
      case CioTerritorialClassification.outOfBounds:
        return 'Fora do limite';
      case CioTerritorialClassification.divergent:
        return 'Dados divergentes';
      case CioTerritorialClassification.unresolved:
        return 'Não resolvido';
    }
  }

  static String _finding(CioTerritorialFinding value) {
    switch (value) {
      case CioTerritorialFinding.missingRegionalId:
        return '• ID regional ausente';
      case CioTerritorialFinding.unknownRegionalId:
        return '• ID regional não existe no catálogo';
      case CioTerritorialFinding.inactiveRegional:
        return '• Regional está inativa';
      case CioTerritorialFinding.typeMismatch:
        return '• Tipologia diverge do catálogo';
      case CioTerritorialFinding.missingNeighborhood:
        return '• Bairro não informado';
      case CioTerritorialFinding.ambiguousNeighborhood:
        return '• Bairro consta em mais de uma regional';
      case CioTerritorialFinding.neighborhoodMismatch:
        return '• Bairro não corresponde à regional informada';
      case CioTerritorialFinding.missingCoordinates:
        return '• Coordenadas não informadas';
      case CioTerritorialFinding.invalidCoordinates:
        return '• Coordenadas inválidas';
      case CioTerritorialFinding.coordinatesOutOfBounds:
        return '• Coordenadas fora do limite aprovado';
    }
  }
}

class _ClassificationGrid extends StatelessWidget {
  const _ClassificationGrid({required this.report});

  final CioTerritorialGovernanceReport report;

  @override
  Widget build(BuildContext context) {
    final items = <(String, CioTerritorialClassification)>[
      ('Válidos', CioTerritorialClassification.valid),
      ('Legados', CioTerritorialClassification.legacy),
      ('Órfãos', CioTerritorialClassification.orphan),
      ('Inativos', CioTerritorialClassification.inactive),
      ('Ambíguos', CioTerritorialClassification.ambiguous),
      ('Divergentes', CioTerritorialClassification.divergent),
      ('Não resolvidos', CioTerritorialClassification.unresolved),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: items
          .map(
            (item) => SizedBox(
              width: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${report.count(item.$2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(item.$1),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _GateMessage extends StatelessWidget {
  const _GateMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
