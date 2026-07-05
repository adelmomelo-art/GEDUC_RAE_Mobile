import 'package:go_router/go_router.dart';

import '../../modules/acoes/caracterizacao_acao_page.dart';
import '../../modules/acoes/consulta_rae_page.dart';
import '../../modules/acoes/nova_acao_page.dart';
import '../../modules/acoes/resultados_page.dart';
import '../../modules/acoes/revisao_relatorio_page.dart';
import '../../modules/admin/admin_page.dart';
import '../../modules/auth/login_page.dart';
import '../../modules/avaliacao/avaliacao_page.dart';
import '../../modules/coordenadores/coordenadores_page.dart';
import '../../modules/dashboard/bi_geduc_page.dart';
import '../../modules/dashboard/dashboard_page.dart';
import '../../modules/evidencias/evidencias_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/localizacao/localizacao_page.dart';
import '../../modules/materiais/materiais_page.dart';
import '../../modules/recursos/recursos_operacionais_page.dart';
import '../../modules/regionais/regionais_page.dart';
import '../../modules/sincronizacao/sincronizacao_page.dart';
import '../../modules/tipos_acoes/tipos_acoes_page.dart';
import '../../modules/usuarios/usuarios_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/nova-acao',
        builder: (context, state) => const NovaAcaoPage(),
      ),
      GoRoute(
        path: '/localizacao',
        builder: (context, state) => const LocalizacaoPage(),
      ),
      GoRoute(
        path: '/caracterizacao',
        builder: (context, state) => const CaracterizacaoAcaoPage(),
      ),
      GoRoute(
        path: '/recursos-operacionais',
        builder: (context, state) => const RecursosOperacionaisPage(),
      ),
      GoRoute(
        path: '/resultados',
        builder: (context, state) => const ResultadosPage(),
      ),
      GoRoute(
        path: '/evidencias',
        builder: (context, state) => const EvidenciasPage(),
      ),
      GoRoute(
        path: '/avaliacao',
        builder: (context, state) => const AvaliacaoPage(),
      ),
      GoRoute(
        path: '/revisao',
        builder: (context, state) => const RevisaoRelatorioPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPage(),
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
