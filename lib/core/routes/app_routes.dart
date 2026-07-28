import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../modules/acoes/caracterizacao_acao_page.dart';
import '../../modules/acoes/consulta_rae_page.dart';
import '../../modules/acoes/nova_acao_page.dart';
import '../../modules/acoes/resultados_page.dart';
import '../../modules/acoes/revisao_relatorio_page.dart';
import '../../modules/admin/admin_home_page.dart';
import '../../modules/admin/admin_page.dart';
import '../../modules/admin/domain_list_page.dart';
import '../../modules/auth/login_page.dart';
import '../../modules/avaliacao/avaliacao_page.dart';
import '../../modules/coordenadores/coordenadores_page.dart';
import '../../modules/dashboard/bi_geduc_page.dart';
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

class AppRoutes {
  AppRoutes._();

  static const String loginPath = '/login';
  static const String homePath = '/home';

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

  static final AuthRouterRefresh _authRouterRefresh = AuthRouterRefresh();

  static final router = GoRouter(
    initialLocation: loginPath,
    refreshListenable: _authRouterRefresh,
    redirect: (context, state) {
      final usuarioAutenticado = FirebaseAuth.instance.currentUser != null;
      final estaNoLogin = state.uri.path == loginPath;

      if (!usuarioAutenticado && !estaNoLogin) {
        return loginPath;
      }

      if (usuarioAutenticado && estaNoLogin) {
        return homePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: novaAcaoPath,
        builder: (context, state) => const NovaAcaoPage(),
      ),
      GoRoute(
        path: localizacaoPath,
        builder: (context, state) => const LocalizacaoPage(),
      ),
      GoRoute(
        path: caracterizacaoPath,
        builder: (context, state) => const CaracterizacaoAcaoPage(),
      ),
      GoRoute(
        path: caracterizacaoLegadoPath,
        redirect: (context, state) => caracterizacaoPath,
      ),
      GoRoute(
        path: recursosOperacionaisPath,
        builder: (context, state) => const RecursosOperacionaisPage(),
      ),
      GoRoute(
        path: integracaoObservacoesPath,
        builder: (context, state) => const IntegracaoObservacoesPage(),
      ),
      GoRoute(
        path: resultadosPath,
        builder: (context, state) => const ResultadosPage(),
      ),
      GoRoute(
        path: evidenciasPath,
        builder: (context, state) => const EvidenciasPage(),
      ),
      GoRoute(
        path: avaliacaoPath,
        builder: (context, state) => const AvaliacaoPage(),
      ),
      GoRoute(
        path: revisaoPath,
        builder: (context, state) => const RevisaoRelatorioPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/admin-legado',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: '/admin/dominios',
        builder: (context, state) => const DomainListPage(),
      ),
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const UsuariosPage(),
      ),
      GoRoute(
        path: '/tipos-acoes',
        builder: (context, state) => const TiposAcoesPage(),
      ),
      GoRoute(
        path: '/coordenadores',
        builder: (context, state) => const CoordenadoresPage(),
      ),
      GoRoute(
        path: '/regionais',
        builder: (context, state) => const RegionaisPage(),
      ),
      GoRoute(
        path: '/materiais',
        builder: (context, state) => const MateriaisPage(),
      ),
      GoRoute(
        path: '/consulta-rae',
        builder: (context, state) => const ConsultaRaePage(),
      ),
      GoRoute(
        path: '/bi-geduc',
        builder: (context, state) => const BiGeducPage(),
      ),
      GoRoute(
        path: '/sincronizacao',
        builder: (context, state) => const SincronizacaoPage(),
      ),
    ],
  );
}
