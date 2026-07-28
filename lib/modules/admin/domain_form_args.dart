import '../../data/models/domain_model.dart';

enum DomainFormMode {
  novo,
  editar,
  duplicar,
}

class DomainFormArgs {
  final DomainFormMode mode;
  final DomainModel? domain;

  const DomainFormArgs._({
    required this.mode,
    this.domain,
  });

  const DomainFormArgs.novo()
      : this._(
          mode: DomainFormMode.novo,
        );

  const DomainFormArgs.editar(DomainModel domain)
      : this._(
          mode: DomainFormMode.editar,
          domain: domain,
        );

  const DomainFormArgs.duplicar(DomainModel domain)
      : this._(
          mode: DomainFormMode.duplicar,
          domain: domain,
        );

  bool get editando => mode == DomainFormMode.editar;
  bool get duplicando => mode == DomainFormMode.duplicar;
}
