import '../../../data/models/acao_model.dart';
import '../../../data/models/usuario_model.dart';
import '../domain/operational_alert.dart';
import 'home_operational_status.dart';

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
    this.dadosEmCache = false,
    this.cacheDisponivel = false,
    this.atualizadoEm,
    this.sincronizandoDashboard = false,
    this.ultimaSincronizacaoAutomaticaEm,
    this.monitoramentoOperacional = const HomeOperationalStatus(),
    this.alertasOperacionais = const <OperationalAlert>[],
  });

  final HomeStatus status;
  final UsuarioModel? usuario;

  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  final List<AcaoModel> ultimosRaes;
  final String? mensagem;

  final bool dadosEmCache;
  final bool cacheDisponivel;
  final DateTime? atualizadoEm;

  final bool sincronizandoDashboard;
  final DateTime? ultimaSincronizacaoAutomaticaEm;
  final HomeOperationalStatus monitoramentoOperacional;
  final List<OperationalAlert> alertasOperacionais;

  bool get carregando {
    return status == HomeStatus.inicial || status == HomeStatus.carregando;
  }

  bool get estaOnline => status == HomeStatus.online;

  bool get estaOffline => status == HomeStatus.offline;

  bool get possuiErro => status == HomeStatus.erro;

  bool get possuiAlertasOperacionais => alertasOperacionais.isNotEmpty;

  bool get possuiDadosOperacionais {
    return cacheDisponivel ||
        totalAcoes > 0 ||
        totalPessoas > 0 ||
        totalVeiculos > 0 ||
        totalCredenciais > 0 ||
        ultimosRaes.isNotEmpty;
  }

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
    bool? dadosEmCache,
    bool? cacheDisponivel,
    DateTime? atualizadoEm,
    bool removerAtualizadoEm = false,
    bool? sincronizandoDashboard,
    DateTime? ultimaSincronizacaoAutomaticaEm,
    bool removerUltimaSincronizacaoAutomaticaEm = false,
    HomeOperationalStatus? monitoramentoOperacional,
    List<OperationalAlert>? alertasOperacionais,
  }) {
    return HomeState(
      status: status ?? this.status,
      usuario: removerUsuario ? null : usuario ?? this.usuario,
      totalAcoes: totalAcoes ?? this.totalAcoes,
      totalPessoas: totalPessoas ?? this.totalPessoas,
      totalVeiculos: totalVeiculos ?? this.totalVeiculos,
      totalCredenciais: totalCredenciais ?? this.totalCredenciais,
      ultimosRaes: ultimosRaes ?? this.ultimosRaes,
      mensagem: removerMensagem ? null : mensagem ?? this.mensagem,
      dadosEmCache: dadosEmCache ?? this.dadosEmCache,
      cacheDisponivel: cacheDisponivel ?? this.cacheDisponivel,
      atualizadoEm:
          removerAtualizadoEm ? null : atualizadoEm ?? this.atualizadoEm,
      sincronizandoDashboard:
          sincronizandoDashboard ?? this.sincronizandoDashboard,
      ultimaSincronizacaoAutomaticaEm: removerUltimaSincronizacaoAutomaticaEm
          ? null
          : ultimaSincronizacaoAutomaticaEm ??
              this.ultimaSincronizacaoAutomaticaEm,
      monitoramentoOperacional:
          monitoramentoOperacional ?? this.monitoramentoOperacional,
      alertasOperacionais: alertasOperacionais ?? this.alertasOperacionais,
    );
  }
}
