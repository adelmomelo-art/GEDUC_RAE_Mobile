import '../../../data/models/acao_model.dart';
import '../../../data/models/usuario_model.dart';

enum HomeStatus {
  inicial,
  carregando,
  online,
  offline,
  erro,
}

class HomeState {
  const HomeState({
    this.status = HomeStatus.inicial,
    this.usuario,
    this.totalAcoes = 0,
    this.totalPessoas = 0,
    this.totalVeiculos = 0,
    this.totalCredenciais = 0,
    this.ultimosRaes = const [],
    this.mensagem,
  });

  final HomeStatus status;
  final UsuarioModel? usuario;
  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;
  final List<AcaoModel> ultimosRaes;
  final String? mensagem;

  bool get carregando => status == HomeStatus.carregando;
  bool get estaOffline => status == HomeStatus.offline;
  bool get possuiErro => status == HomeStatus.erro;

  HomeState copyWith({
    HomeStatus? status,
    UsuarioModel? usuario,
    bool removerUsuario = false,
    int? totalAcoes,
    int? totalPessoas,
    int? totalVeiculos,
    int? totalCredenciais,
    List<AcaoModel>? ultimosRaes,
    String? mensagem,
    bool removerMensagem = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      usuario: removerUsuario ? null : (usuario ?? this.usuario),
      totalAcoes: totalAcoes ?? this.totalAcoes,
      totalPessoas: totalPessoas ?? this.totalPessoas,
      totalVeiculos: totalVeiculos ?? this.totalVeiculos,
      totalCredenciais: totalCredenciais ?? this.totalCredenciais,
      ultimosRaes: ultimosRaes ?? this.ultimosRaes,
      mensagem: removerMensagem ? null : (mensagem ?? this.mensagem),
    );
  }
}
