# Blueprint ADM-001B.1 — Fundação Administrativa

## Arquitetura

```text
AdminHomePage
    ↓
AdminModuleCatalog
    ↓
AdminModule
 ├── rota → AppRoutes
 ├── status → AdminModuleStatus
 └── permissão → AdminPermission
    ↓
AdminModuleCard
    ↓
NavigationManager
    ↓
GoRouter
```

## Responsabilidades

- `AdminHomePage`: composição visual e navegação.
- `AdminModuleCatalog`: inventário oficial dos módulos.
- `AdminModule`: metadados imutáveis de cada módulo.
- `AdminModuleStatus`: disponibilidade operacional.
- `AdminPermission`: vocabulário inicial de autorização.
- `AdminPermissionPolicy`: regra provisória e isolada para futura integração.
- `AdminModuleCard`: representação visual reutilizável.
- `AppRoutes`: caminhos oficiais.
- `NavigationManager`: execução padronizada da navegação.

## Não objetivos

- Guardas definitivas por perfil.
- CRUD novo.
- Alteração de Firestore.
- Remoção do módulo legado.
