import 'dart:collection';

class CioBiDistributionItem {
  const CioBiDistributionItem({
    required this.label,
    required this.count,
    required this.percentage,
  });

  final String label;
  final int count;
  final double percentage;
}

class CioBiGoalsSummary {
  const CioBiGoalsSummary({
    required this.achieved,
    required this.notAchieved,
    required this.achievedPercentage,
  });

  final int achieved;
  final int notAchieved;
  final double achievedPercentage;

  int get total => achieved + notAchieved;
}

class CioBiExecutiveSnapshot {
  CioBiExecutiveSnapshot({
    required this.totalActions,
    required this.totalPeople,
    required this.totalVehicles,
    required this.totalCredentials,
    required Iterable<CioBiDistributionItem> actionsByRegional,
    required Iterable<CioBiDistributionItem> actionsByType,
    required this.goals,
  })  : actionsByRegional = UnmodifiableListView(actionsByRegional),
        actionsByType = UnmodifiableListView(actionsByType);

  final int totalActions;
  final int totalPeople;
  final int totalVehicles;
  final int totalCredentials;
  final List<CioBiDistributionItem> actionsByRegional;
  final List<CioBiDistributionItem> actionsByType;
  final CioBiGoalsSummary goals;
}
