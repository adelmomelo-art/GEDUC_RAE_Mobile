import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_sha256.dart';

void main() {
  test('calcula vetor conhecido SHA-256', () {
    final digest = CioSha256.digest(Uint8List.fromList(utf8.encode('abc')));
    expect(digest,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });
}
