import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/dashboard_cio_bridge.dart';

void main() {
  const bridge = DashboardCIOBridge();

  test('mantém equivalência com os sete resultados do BI legado', () {
    final actions = [
      _action(
        '1',
        regional: 'Regional Norte',
        type: 'Oficina',
        people: 100,
        vehicles: 40,
        credentials: 20,
        targetAchieved: true,
      ),
      _action(
        '2',
        regional: 'Regional Norte',
        type: 'Palestra',
        people: 50,
        vehicles: 10,
        credentials: 5,
        targetAchieved: false,
      ),
      _action(
        '3',
        regional: 'Regional Sul',
        type: 'Oficina',
        people: 30,
        vehicles: 8,
        credentials: 2,
        targetAchieved: true,
      ),
    ];

    final snapshot = bridge.processar(actions).biExecutive;

    expect(snapshot.totalActions, actions.length);
    expect(
      snapshot.totalPeople,
      actions.fold<int>(0, (total, action) => total + action.pessoasAlcancadas),
    );
    expect(
      snapshot.totalVehicles,
      actions.fold<int>(0, (total, action) => total + action.veiculosAbordados),
    );
    expect(
      snapshot.totalCredentials,
      actions.fold<int>(
        0,
        (total, action) => total + action.credenciaisEmitidas,
      ),
    );
    expect(
      {for (final item in snapshot.actionsByRegional) item.label: item.count},
      {'Regional Norte': 2, 'Regional Sul': 1},
    );
    expect(
      {for (final item in snapshot.actionsByType) item.label: item.count},
      {'Oficina': 2, 'Palestra': 1},
    );
    expect(snapshot.goals.achieved, 2);
    expect(snapshot.goals.notAchieved, 1);
    expect(snapshot.goals.total, 3);
    expect(snapshot.goals.achievedPercentage, closeTo(66.666, 0.01));
  });

  test('contrato vazio é seguro e não produz divisões inválidas', () {
    final snapshot = bridge.processar(const <AcaoModel>[]).biExecutive;

    expect(snapshot.totalActions, 0);
    expect(snapshot.totalPeople, 0);
    expect(snapshot.totalVehicles, 0);
    expect(snapshot.totalCredentials, 0);
    expect(snapshot.actionsByRegional, isEmpty);
    expect(snapshot.actionsByType, isEmpty);
    expect(snapshot.goals.total, 0);
    expect(snapshot.goals.achievedPercentage, 0);
  });

  test('distribuições preservam ordem oficial e percentuais', () {
    final snapshot = bridge.processar([
      _action('1', regional: 'Sul', type: 'Palestra'),
      _action('2', regional: 'Norte', type: 'Oficina'),
      _action('3', regional: 'Norte', type: 'Oficina'),
      _action('4', regional: 'Norte', type: 'Palestra'),
    ]).biExecutive;

    expect(snapshot.actionsByRegional.map((item) => item.label), [
      'Norte',
      'Sul',
    ]);
    expect(snapshot.actionsByRegional.first.percentage, 75);
    expect(snapshot.actionsByType.map((item) => item.label), [
      'Oficina',
      'Palestra',
    ]);
    expect(snapshot.actionsByType.first.percentage, 50);
  });

  test('listas do contrato não podem ser modificadas', () {
    final snapshot = bridge.processar([
      _action('1', regional: 'Norte', type: 'Oficina'),
    ]).biExecutive;

    expect(
      () => snapshot.actionsByType.add(snapshot.actionsByType.first),
      throwsUnsupportedError,
    );
    expect(
      () => snapshot.actionsByRegional.clear(),
      throwsUnsupportedError,
    );
  });
}

AcaoModel _action(
  String id, {
  required String regional,
  required String type,
  int people = 10,
  int vehicles = 2,
  int credentials = 1,
  bool targetAchieved = true,
}) {
  return AcaoModel.fromMap({
    'id': id,
    'dataAcao': '2026-08-14T10:00:00.000',
    'regional': regional,
    'tipoAcao': type,
    'status': 'concluido',
    'coordenadorNome': 'Coordenação',
    'pessoasAlcancadas': people,
    'veiculosAbordados': vehicles,
    'credenciaisEmitidas': credentials,
    'publicoMinimo': targetAchieved ? people : people + 1,
    'metaAtingida': targetAchieved,
    'agentesTransito': 1,
    'sincronizado': true,
  });
}
