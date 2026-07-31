import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import 'admin_module.dart';
import 'admin_module_status.dart';
import 'admin_permission.dart';

class AdminModuleCatalog {
  AdminModuleCatalog._();

  static const List<AdminModule> modulos = [
    AdminModule(
      id: 'dominios',
      titulo: 'Central de Domínios',
      descricao: 'Gerencie listas, grupos e opções utilizadas na plataforma.',
      icone: Icons.category_outlined,
      rota: AppRoutes.adminDominiosPath,
      status: AdminModuleStatus.disponivel,
      permissao: AdminPermission.gerenciarDominios,
    ),
    AdminModule(
      id: 'usuarios',
      titulo: 'Usuários',
      descricao: 'Consulte cadastros, perfis e situação de acesso.',
      icone: Icons.people_outline,
      rota: AppRoutes.usuariosPath,
      status: AdminModuleStatus.emEvolucao,
      permissao: AdminPermission.gerenciarUsuarios,
    ),
    AdminModule(
      id: 'tipos-acoes',
      titulo: 'Tipos de Ações',
      descricao: 'Administre os tipos de ações educativas disponíveis.',
      icone: Icons.assignment_outlined,
      rota: AppRoutes.tiposAcoesPath,
      status: AdminModuleStatus.emEvolucao,
      permissao: AdminPermission.gerenciarTiposAcoes,
    ),
    AdminModule(
      id: 'coordenadores',
      titulo: 'Coordenadores',
      descricao: 'Consulte responsáveis e vínculos operacionais.',
      icone: Icons.badge_outlined,
      rota: AppRoutes.coordenadoresPath,
      status: AdminModuleStatus.emEvolucao,
      permissao: AdminPermission.gerenciarCoordenadores,
    ),
    AdminModule(
      id: 'regionais',
      titulo: 'Regionais',
      descricao: 'Administre regionais e referências territoriais.',
      icone: Icons.map_outlined,
      rota: AppRoutes.regionaisPath,
      status: AdminModuleStatus.emEvolucao,
      permissao: AdminPermission.gerenciarRegionais,
    ),
    AdminModule(
      id: 'materiais',
      titulo: 'Materiais',
      descricao: 'Consulte e mantenha os materiais utilizados nas ações.',
      icone: Icons.inventory_2_outlined,
      rota: AppRoutes.materiaisPath,
      status: AdminModuleStatus.emEvolucao,
      permissao: AdminPermission.gerenciarMateriais,
    ),
  ];
}
