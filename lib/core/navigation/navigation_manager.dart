import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centraliza as regras de navegação da Plataforma Fênix.
///
/// Este componente reduz o uso direto de `context.go`, `context.push`,
/// `context.pop` e `Navigator` nas telas da aplicação.
///
/// As rotas devem ser ajustadas de acordo com o arquivo `app_routes.dart`.
class NavigationManager {
  NavigationManager._();

  /// Rota segura principal da aplicação.
  ///
  /// Altere este valor caso a rota real do Centro de Operações Educativas
  /// seja diferente.
  static const String centroOperacoesRoute = '/home';

  /// Rota de login.
  static const String loginRoute = '/login';

  /// Rota inicial/home, quando existir como rota diferente do Centro.
  static const String homeRoute = '/home';

  /// Rota do dashboard.
  static const String dashboardRoute = '/dashboard';

  /// Rota de nova ação.
  static const String novaAcaoRoute = '/nova-acao';

  /// Rota de consulta de RAE.
  static const String consultaRaeRoute = '/consulta-rae';

  /// Rota administrativa.
  static const String adminRoute = '/admin';

  /// Rota de usuários.
  static const String usuariosRoute = '/usuarios';

  /// Rota de coordenadores.
  static const String coordenadoresRoute = '/coordenadores';

  /// Rota de regionais.
  static const String regionaisRoute = '/regionais';

  /// Rota de materiais.
  static const String materiaisRoute = '/materiais';

  /// Rota de tipos de ação.
  static const String tiposAcaoRoute = '/tipos-acoes';

  /// Rota da Faxita.
  static const String faxitaRoute = '/faxita';

  /// Substitui toda a rota atual.
  ///
  /// Use quando a tela anterior não deve permanecer no histórico.
  static void go(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.go(route, extra: extra);
  }

  /// Abre uma nova rota mantendo a tela atual no histórico.
  static Future<T?> push<T>(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    return context.push<T>(route, extra: extra);
  }

  /// Substitui a rota atual por outra, preservando o restante do histórico.
  ///
  /// Nesta versão do go_router, `replace` retorna `void`.
  static void replace(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.replace(route, extra: extra);
  }

  /// Retorna para a página anterior quando possível.
  ///
  /// Quando não existe histórico, direciona para a rota segura informada.
  static void back(
    BuildContext context, {
    String fallbackRoute = centroOperacoesRoute,
  }) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute);
  }

  /// Retorna para a página anterior quando possível.
  ///
  /// Caso contrário, direciona sempre ao Centro de Operações Educativas.
  static void backOrCentro(BuildContext context) {
    back(
      context,
      fallbackRoute: centroOperacoesRoute,
    );
  }

  /// Retorna um resultado para a tela anterior.
  ///
  /// Caso não exista histórico, vai para o Centro de Operações Educativas.
  static void backWithResult<T>(
    BuildContext context, [
    T? result,
  ]) {
    if (context.canPop()) {
      context.pop<T>(result);
      return;
    }

    context.go(centroOperacoesRoute);
  }

  /// Direciona para o Centro de Operações Educativas.
  static void goToCentro(BuildContext context) {
    context.go(centroOperacoesRoute);
  }

  /// Direciona para o login.
  ///
  /// Deve ser usado apenas em logout, expiração de sessão ou autenticação
  /// inválida.
  static void goToLogin(BuildContext context) {
    context.go(loginRoute);
  }

  /// Direciona para a home.
  static void goToHome(BuildContext context) {
    context.go(homeRoute);
  }

  /// Abre o dashboard mantendo a tela atual no histórico.
  static Future<T?> goToDashboard<T>(BuildContext context) {
    return context.push<T>(dashboardRoute);
  }

  /// Abre o cadastro de nova ação.
  static Future<T?> goToNovaAcao<T>(BuildContext context) {
    return context.push<T>(novaAcaoRoute);
  }

  /// Abre a consulta de RAE.
  static Future<T?> goToConsultaRae<T>(BuildContext context) {
    return context.push<T>(consultaRaeRoute);
  }

  /// Abre a área administrativa.
  static Future<T?> goToAdmin<T>(BuildContext context) {
    return context.push<T>(adminRoute);
  }

  /// Abre o módulo de usuários.
  static Future<T?> goToUsuarios<T>(BuildContext context) {
    return context.push<T>(usuariosRoute);
  }

  /// Abre o módulo de coordenadores.
  static Future<T?> goToCoordenadores<T>(BuildContext context) {
    return context.push<T>(coordenadoresRoute);
  }

  /// Abre o módulo de regionais.
  static Future<T?> goToRegionais<T>(BuildContext context) {
    return context.push<T>(regionaisRoute);
  }

  /// Abre o módulo de materiais.
  static Future<T?> goToMateriais<T>(BuildContext context) {
    return context.push<T>(materiaisRoute);
  }

  /// Abre o módulo de tipos de ação.
  static Future<T?> goToTiposAcao<T>(BuildContext context) {
    return context.push<T>(tiposAcaoRoute);
  }

  /// Abre a Faxita.
  static Future<T?> goToFaxita<T>(BuildContext context) {
    return context.push<T>(faxitaRoute);
  }

  /// Confirma uma ação antes de sair da tela.
  ///
  /// Quando [onBeforeBack] retornar `false`, a navegação é cancelada.
  static Future<void> guardedBack(
    BuildContext context, {
    required Future<bool> Function() onBeforeBack,
    String fallbackRoute = centroOperacoesRoute,
  }) async {
    final canLeave = await onBeforeBack();

    if (!canLeave || !context.mounted) {
      return;
    }

    back(
      context,
      fallbackRoute: fallbackRoute,
    );
  }
}
