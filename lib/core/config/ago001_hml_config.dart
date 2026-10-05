abstract final class Ago001HmlConfig {
  static const projectId = 'demo-geduc-ago001-hml';
  static const host = '127.0.0.1';
  static const authPort = 9099;
  static const firestorePort = 8080;
  static const webPort = 7351;

  static void validate({
    required bool debug,
    required bool web,
    required Uri origin,
  }) {
    if (!debug ||
        !web ||
        origin.scheme != 'http' ||
        origin.host != host ||
        origin.port != webPort) {
      throw StateError(
          'AGO-001 HML requer debug web em http://$host:$webPort.');
    }
  }
}
