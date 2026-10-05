import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/config/ago001_hml_config.dart';

void main() {
  test('permite somente debug web no endereço isolado', () {
    Ago001HmlConfig.validate(
        debug: true, web: true, origin: Uri.parse('http://127.0.0.1:7351/'));
  });
  for (final origin in [
    'https://127.0.0.1:7351/',
    'http://127.0.0.1:7352/',
    'http://localhost:7351/',
    'https://geduc-rae-mobile.web.app/'
  ]) {
    test('bloqueia origem $origin', () {
      expect(
          () => Ago001HmlConfig.validate(
              debug: true, web: true, origin: Uri.parse(origin)),
          throwsStateError);
    });
  }
  test('bloqueia release', () {
    expect(
        () => Ago001HmlConfig.validate(
            debug: false,
            web: true,
            origin: Uri.parse('http://127.0.0.1:7351/')),
        throwsStateError);
  });
  test('bloqueia plataforma nativa', () {
    expect(
        () => Ago001HmlConfig.validate(
            debug: true,
            web: false,
            origin: Uri.parse('http://127.0.0.1:7351/')),
        throwsStateError);
  });
}
