import 'package:flutter/material.dart';

import 'admin_module_status.dart';
import '../../../core/security/permission.dart';

class AdminModule {
  final String id;
  final String titulo;
  final String descricao;
  final IconData icone;
  final String rota;
  final AdminModuleStatus status;
  final Permission permissao;

  const AdminModule({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.rota,
    required this.status,
    required this.permissao,
  });

  bool get permiteNavegacao => rota.isNotEmpty && status.permiteAcesso;
}
