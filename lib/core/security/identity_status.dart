enum IdentityStatus {
  naoAutenticado,
  carregando,
  ativo,
  semCadastro,
  inativo,
  perfilInvalido,
  erro;

  bool get identidadeValida => this == IdentityStatus.ativo;

  bool get acessoBloqueado {
    return switch (this) {
      IdentityStatus.semCadastro ||
      IdentityStatus.inativo ||
      IdentityStatus.perfilInvalido ||
      IdentityStatus.erro =>
        true,
      _ => false,
    };
  }
}
