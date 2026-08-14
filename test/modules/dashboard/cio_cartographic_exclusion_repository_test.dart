import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_cartographic_exclusion_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('carrega exatamente quatro exclusões G1 e quatro G2', () async {
    final repository = CioCartographicExclusionRepository();
    final exclusions = await repository.load();

    expect(exclusions, hasLength(8));
    expect(exclusions.map((item) => item.actionId).toSet(), hasLength(8));
    expect(exclusions.where((item) => item.group == 'G1'), hasLength(4));
    expect(exclusions.where((item) => item.group == 'G2'), hasLength(4));
    expect(identical(exclusions, await repository.load()), isTrue);
  });
}
