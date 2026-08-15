import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../modules/acoes/caracterizacao_acao_page.dart';
import '../../modules/acoes/consulta_rae_page.dart';
import '../../modules/acoes/nova_acao_page.dart';
import '../../modules/acoes/resultados_page.dart';
import '../../modules/acoes/revisao_relatorio_page.dart';
import '../../modules/admin/access_denied_page.dart';
import '../../modules/admin/admin_home_page.dart';
import '../../modules/admin/domain_list_page.dart';
import '../../modules/auth/login_page.dart';
import '../../modules/auth/account_access_page.dart';
import '../../modules/avaliacao/avaliacao_page.dart';
import '../../modules/coordenadores/coordenadores_page.dart';
import '../../modules/dashboard/dashboard_page.dart';
import '../../modules/evidencias/evidencias_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/integracao/integracao_observacoes_page.dart';
import '../../modules/localizacao/localizacao_page.dart';
import '../../modules/materiais/materiais_page.dart';
import '../../modules/recursos/recursos_operacionais_page.dart';
import '../../modules/regionais/regionais_page.dart';
import '../../modules/sincronizacao/sincronizacao_page.dart';
import '../../modules/tipos_acoes/tipos_acoes_page.dart';
import '../../modules/usuarios/usuarios_page.dart';
import '../auth/auth_router_refresh.dart';
import '../config/acl_feature_flags.dart';
import '../security/authorization_service.dart';
import '../security/permission.dart';
import '../security/identity_status.dart';
import 'route_guard.dart';

class AppRoutes {
  AppRoutes._();

  static const String loginPath = '/login';
  static const String homePath = '/home';
  static const String accountAccessPath = '/acesso-conta';

  static const String novaAcaoPath = '/nova-acao';
  static const String localizacaoPath = '/localizacao';
  static const String caracterizacaoPath = '/caracterizacao';

  /// Rota mantida temporariamente para compatibilidade com páginas que ainda
  /// utilizam o endereço antigo.
  static const String caracterizacaoLegadoPath = '/caracterizacao-acao';

  static const String recursosOperacionaisPath = '/recursos-operacionais';
  static const String integracaoObservacoesPath = '/integracao-observacoes';
  static const String resultadosPath = '/resultados';
  static const String evidenciasPath = '/evidencias';
  static const String avaliacaoPath = '/avaliacao';
  static const String revisaoPath = '/revisao';

  static const String dashboardPath = '/dashboard';
  static const String adminPath = '/admin';
  static const String adminLegadoPath = '/admin-legado';
  static const String adminDominiosPath = '/admin/dominios';
  static const String acessoNegadoPath = '/acesso-negado';
  static const String usuariosPath = '/usuarios';
  static const String tiposAcoesPath = '/tipos-acoes';
  static const String coordenadoresPath = '/coordenadores';
  static const String regionaisPath = '/regionais';
  static const String materiaisPath = '/materiais';
  static const String consultaRaePath = '/consulta-rae';
  static const String biGeducPath = '/bi-geduc';
  static const String sincronizacaoPath = '/sincronizacao';

  static final AuthRouterRefresh _authRouterRefresh = AuthRouterRefresh();
  static final AuthorizationService _authorizationService =
      AuthorizationService.instance;

  static Future<String?> _protegerAcl(Permission permissao) {
    if (!AclFeatureFlags.scopedAccessEnabled) {
      return Future<String?>.value();
    }
    return RouteGuard.proteger(
      permissao: permissao,
      loginPath: loginPath,
      acessoNegadoPath: acessoNegadoPath,
    );
  }

  static final router = GoRouter(
    initialLocation: loginPath,
    refreshListenable: Listenable.merge([
      _authRouterRefresh,
      _authorizationService,
    ]),
    redirect: (context, state) async {
      final usuarioAutenticado = _authorizationService.autenticado;
      final estaNoLogin = state.uri.path == loginPath;
      final estaNoAcessoConta = state.uri.path == accountAccessPath;

      if (!usuarioAutenticado && !estaNoLogin) {
        return loginPath;
      }

      if (!usuarioAutenticado) return null;

      await _authorizationService.garantirUsuarioAtual();

      if (_authorizationService.status == IdentityStatus.ativo) {
        if (estaNoLogin || estaNoAcessoConta) return homePath;
        return null;
      }

      if (!estaNoAcessoConta) {
        return accountAccessPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: accountAccessPath,
        builder: (context, state) => const AccountAccessPage(),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: acessoNegadoPath,
        builder: (context, state) => const AccessDeniedPage(),
      ),
      GoRoute(
        path: novaAcaoPath,
        redirect: (context, state) => _protegerAcl(Permission.criarRae),
        builder: (context, state) => const NovaAcaoPage(),
      ),
      GoRoute(
        path: localizacaoPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const LocalizacaoPage(),
      ),
      GoRoute(
        path: caracterizacaoPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const CaracterizacaoAcaoPage(),
      ),
      GoRoute(
        path: caracterizacaoLegadoPath,
        redirect: (context, state) => caracterizacaoPath,
      ),
      GoRoute(
        path: recursosOperacionaisPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const RecursosOperacionaisPage(),
      ),
      GoRoute(
        path: integracaoObservacoesPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const IntegracaoObservacoesPage(),
      ),
      GoRoute(
        path: resultadosPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const ResultadosPage(),
      ),
      GoRoute(
        path: evidenciasPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const EvidenciasPage(),
      ),
      GoRoute(
        path: avaliacaoPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const AvaliacaoPage(),
      ),
      GoRoute(
        path: revisaoPath,
        redirect: (context, state) => _protegerAcl(Permission.editarRae),
        builder: (context, state) => const RevisaoRelatorioPage(),
      ),
      GoRoute(
        path: dashboardPath,
        redirect: (context, state) => _protegerAcl(Permission.acessarCioEscopo),
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: adminPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.acessarAdministracao,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: adminLegadoPath,
        redirect: (context, state) => adminPath,
      ),
      GoRoute(
        path: adminDominiosPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.gerenciarDominios,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const DomainListPage(),
      ),
      GoRoute(
        path: usuariosPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.gerenciarUsuarios,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const UsuariosPage(),
      ),
      GoRoute(
        path: tiposAcoesPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.gerenciarTiposAcoes,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const TiposAcoesPage(),
      ),
      GoRoute(
        path: coordenadoresPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.gerenciarCoordenadores,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const CoordenadoresPage(),
      ),
      GoRoute(
        path: regionaisPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.gerenciarRegionais,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const RegionaisPage(),
      ),
      GoRoute(
        path: materiaisPath,
        redirect: (context, state) => RouteGuard.proteger(
          permissao: Permission.gerenciarMateriais,
          loginPath: loginPath,
          acessoNegadoPath: acessoNegadoPath,
        ),
        builder: (context, state) => const MateriaisPage(),
      ),
      GoRoute(
        path: consultaRaePath,
        redirect: (context, state) => _protegerAcl(Permission.consultarRae),
        builder: (context, state) => const ConsultaRaePage(),
      ),
      GoRoute(
        path: biGeducPath,
        redirect: (context, state) async {
          final bloqueio = await RouteGuard.proteger(
            permissao: Permission.acessarCioExecutivo,
            loginPath: loginPath,
            acessoNegadoPath: acessoNegadoPath,
          );
          return bloqueio ?? dashboardPath;
        },
      ),
      GoRoute(
        path: sincronizacaoPath,
        builder: (context, state) => const SincronizacaoPage(),
      ),
    ],
  );
}
