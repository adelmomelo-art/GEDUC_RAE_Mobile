import '../../../core/services/dashboard_service.dart';
import '../models/cio_bi_executive_snapshot.dart';

class CioBiConsolidationService {
  const CioBiConsolidationService();

  CioBiExecutiveSnapshot fromIndicators(DashboardIndicadores indicators) {
    return CioBiExecutiveSnapshot(
      totalActions: indicators.totalAcoes,
      totalPeople: indicators.pessoasAlcancadas,
      totalVehicles: indicators.veiculosAbordados,
      totalCredentials: indicators.credenciaisEmitidas,
      actionsByRegional: _distribution(indicators.rankingRegionais),
      actionsByType: _distribution(indicators.rankingTiposAcao),
      goals: CioBiGoalsSummary(
        achieved: indicators.metasAtingidas,
        notAchieved: indicators.metasNaoAtingidas,
        achievedPercentage: indicators.percentualMetasAtingidas,
      ),
    );
  }

  List<CioBiDistributionItem> _distribution(
    List<DashboardRankingItem> ranking,
  ) =>
      ranking
          .map(
            (item) => CioBiDistributionItem(
              label: item.nome,
              count: item.quantidade,
              percentage: item.percentual,
            ),
          )
          .toList(growable: false);
}
