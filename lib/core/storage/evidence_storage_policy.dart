class EvidenceStoragePolicy {
  const EvidenceStoragePolicy({
    this.localStorageRequired = true,
    this.remoteStorageEnabled = false,
  });

  final bool localStorageRequired;
  final bool remoteStorageEnabled;

  bool get localFirst => localStorageRequired;
}
