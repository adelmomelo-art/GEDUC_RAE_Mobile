import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/services/firebase_acao_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/tipo_acao_service.dart';
import 'core/services/usuario_service.dart';
import 'core/theme/app_theme.dart';
import 'modules/acoes/controllers/acao_controller.dart';
import 'modules/admin/controllers/tipo_acao_controller.dart';
import 'modules/admin/controllers/usuario_controller.dart';
import 'repositories/acao_repository.dart';
import 'repositories/tipo_acao_repository.dart';
import 'repositories/usuario_repository.dart';

class GeducRaeApp extends StatelessWidget {
  const GeducRaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final offlineService = OfflineService();
    final firebaseService = FirebaseAcaoService();
    final usuarioService = UsuarioService();
    final tipoAcaoService = TipoAcaoService();

    final syncService = SyncService(
      offlineService: offlineService,
      firebaseService: firebaseService,
    );

    final acaoRepository = AcaoRepository(
      offlineService: offlineService,
      firebaseService: firebaseService,
      syncService: syncService,
    );

    final usuarioRepository = UsuarioRepository(
      usuarioService: usuarioService,
    );

    final tipoAcaoRepository = TipoAcaoRepository(
      tipoAcaoService: tipoAcaoService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AcaoController(
            acaoRepository: acaoRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UsuarioController(
            usuarioRepository: usuarioRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TipoAcaoController(
            tipoAcaoRepository: tipoAcaoRepository,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'GEDUC RAE Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}