abstract final class EvidenceImagePreparationProfile {
  static const String id = 'evidence-photo-jpeg-v1';
  static const String outputContentType = 'image/jpeg';
  static const String outputExtension = '.jpg';
  static const int maxDimension = 2048;
  static const int jpegQuality = 85;

  static const Set<String> supportedContentTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
  };
}
