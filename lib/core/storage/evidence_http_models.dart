class EvidenceHttpPutRequest {
  const EvidenceHttpPutRequest({
    required this.uri,
    required this.localFilePath,
    required this.headers,
  });

  final Uri uri;
  final String localFilePath;
  final Map<String, String> headers;

  bool get valido =>
      uri.scheme.toLowerCase() == 'https' &&
      uri.host.trim().isNotEmpty &&
      localFilePath.trim().isNotEmpty;
}

class EvidenceHttpResponse {
  const EvidenceHttpResponse({
    required this.statusCode,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final Map<String, String> headers;

  bool get sucesso => statusCode >= 200 && statusCode < 300;

  String? header(String name) {
    final procurado = name.trim().toLowerCase();

    for (final entry in headers.entries) {
      if (entry.key.trim().toLowerCase() == procurado) {
        return entry.value;
      }
    }

    return null;
  }
}
