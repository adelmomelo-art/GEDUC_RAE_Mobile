import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

/// Ponto único para operações de navegação da Plataforma Fênix.
class NavigationManager {
  NavigationManager._();

  static const String centroOperacoesRoute = AppRoutes.homePath;
  static const String loginRoute = AppRoutes.loginPath;
  static const String homeRoute = AppRoutes.homePath;
  static const String dashboardRoute = AppRoutes.dashboardPath;
  static const String novaAcaoRoute = AppRoutes.novaAcaoPath;
  static const String consultaRaeRoute = AppRoutes.consultaRaePath;
  static const String adminRoute = AppRoutes.adminPath;
  static const String usuariosRoute = AppRoutes.usuariosPath;
  static const String coordenadoresRoute = AppRoutes.coordenadoresPath;
  static const String regionaisRoute = AppRoutes.regionaisPath;
  static const String materiaisRoute = AppRoutes.materiaisPath;
  static const String tiposAcaoRoute = AppRoutes.tiposAcoesPath;

  static void go(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.go(route, extra: extra);
  }

  static Future<T?> push<T>(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    return context.push<T>(route, extra: extra);
  }

  static void replace(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.replace(route, extra: extra);
  }

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

  static void backOrCentro(BuildContext context) {
    back(context, fallbackRoute: centroOperacoesRoute);
  }

  static void backWithResult<T>(BuildContext context, [T? result]) {
    if (context.canPop()) {
      context.pop<T>(result);
      return;
    }

    context.go(centroOperacoesRoute);
  }

  static void goToCentro(BuildContext context) =>
      context.go(centroOperacoesRoute);

  static void goToLogin(BuildContext context) => context.go(loginRoute);

  static void goToHome(BuildContext context) => context.go(homeRoute);

  static Future<T?> goToDashboard<T>(BuildContext context) =>
      context.push<T>(dashboardRoute);

  static Future<T?> goToNovaAcao<T>(BuildContext context) =>
      context.push<T>(novaAcaoRoute);

  static Future<T?> goToConsultaRae<T>(BuildContext context) =>
      context.push<T>(consultaRaeRoute);

  static Future<T?> goToAdmin<T>(BuildContext context) =>
      context.push<T>(adminRoute);

  static Future<T?> goToUsuarios<T>(BuildContext context) =>
      context.push<T>(usuariosRoute);

  static Future<T?> goToCoordenadores<T>(BuildContext context) =>
      context.push<T>(coordenadoresRoute);

  static Future<T?> goToRegionais<T>(BuildContext context) =>
      context.push<T>(regionaisRoute);

  static Future<T?> goToMateriais<T>(BuildContext context) =>
      context.push<T>(materiaisRoute);

  static Future<T?> goToTiposAcao<T>(BuildContext context) =>
      context.push<T>(tiposAcaoRoute);

  static Future<void> guardedBack(
    BuildContext context, {
    required Future<bool> Function() onBeforeBack,
    String fallbackRoute = centroOperacoesRoute,
  }) async {
    final canLeave = await onBeforeBack();

    if (!canLeave || !context.mounted) {
      return;
    }

    back(context, fallbackRoute: fallbackRoute);
  }
}
