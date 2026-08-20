class EvidenceStoragePolicy {
  const EvidenceStoragePolicy({
    this.remoteStorageEnabled = false,
  });

  final bool remoteStorageEnabled;

  bool get localStorageRequired => true;
  bool get localFirst => true;
}
