# MAPA OFICIAL DO PROJETO — PLATAFORMA FÊNIX

**Projeto:** GEDUC_RAE_Mobile  
**Produto:** Plataforma Fênix  
**Documento:** Referência oficial de estrutura e localização de arquivos  
**Versão inicial:** 2026-07-24

> **Mensagem-guia:** “Como a digitalização das ações educativas permitiu transformar dados operacionais em inteligência para tomada de decisão.”

## 1. Finalidade

Este documento estabelece a referência oficial para localização, criação, substituição e organização dos arquivos do projeto GEDUC_RAE_Mobile.

Antes de qualquer alteração estrutural, criação de arquivo ou substituição de código, os caminhos descritos neste documento e na árvore oficial `arvore_projeto.txt` devem ser consultados.

## 2. Fluxo oficial de trabalho

1. Analisar a arquitetura e o arquivo atual.
2. Confirmar o caminho real na árvore do projeto.
3. Gerar o arquivo completo.
4. Substituir o arquivo no VS Code.
5. Executar `flutter analyze`.
6. Corrigir eventuais problemas.
7. Homologar a etapa.
8. Registrar no Git.
9. Atualizar a documentação técnica.

## 3. Estrutura principal

```text
GEDUC_RAE_Mobile/
├── android/
├── assets/
│   └── images/
├── docs/
├── lib/
│   ├── core/
│   ├── data/
│   ├── modules/
│   └── repositories/
├── test/
├── web/
├── windows/
├── pubspec.yaml
├── analysis_options.yaml
└── arvore_projeto.txt
```

Diretórios gerados automaticamente, como `.dart_tool/`, `build/`, `.gradle/` e caches de plataforma, não devem ser usados como destino para arquivos de implementação.

## 4. Arquivos centrais

```text
lib/main.dart
lib/app.dart
lib/firebase_options.dart
lib/core/routes/app_routes.dart
lib/core/service_locator.dart
lib/core/theme/app_theme.dart
lib/core/constants/app_colors.dart
```

## 5. Modelos de dados

```text
lib/data/models/acao_model.dart
lib/data/models/coordenador_model.dart
lib/data/models/domain_model.dart
lib/data/models/dominio_model.dart
lib/data/models/tipo_acao_model.dart
lib/data/models/usuario_model.dart
lib/core/models/evidencia_model.dart
```

## 6. Controllers

```text
lib/modules/acoes/controllers/acao_controller.dart
lib/modules/admin/controllers/tipo_acao_controller.dart
lib/modules/admin/controllers/usuario_controller.dart
```

## 7. Serviços compartilhados

```text
lib/core/services/acao_rules_service.dart
lib/core/services/admin_cadastro_service.dart
lib/core/services/domain_service.dart
lib/core/services/dominio_service.dart
lib/core/services/evidencia_storage_service.dart
lib/core/services/faxita_insights_service.dart
lib/core/services/faxita_review_service.dart
lib/core/services/firebase_acao_service.dart
lib/core/services/geolocalizacao_service.dart
lib/core/services/imagem_service.dart
lib/core/services/kpi_service.dart
lib/core/services/offline_service.dart
lib/core/services/pdf_relatorio_service.dart
lib/core/services/qrcode_service.dart
lib/core/services/sync_service.dart
lib/core/services/thumbnail_service.dart
lib/core/services/tipo_acao_service.dart
lib/core/services/usuario_service.dart
```

## 8. Repositórios

```text
lib/repositories/acao_repository.dart
lib/repositories/assinatura_repository.dart
lib/repositories/domain_repository.dart
lib/repositories/dominio_repository.dart
lib/repositories/escola_repository.dart
lib/repositories/evento_repository.dart
lib/repositories/participante_repository.dart
lib/repositories/repository.dart
lib/repositories/tipo_acao_repository.dart
lib/repositories/usuario_repository.dart
```

## 9. Módulo de ações

```text
lib/modules/acoes/consulta_rae_page.dart
lib/modules/acoes/detalhe_acao_page.dart
lib/modules/acoes/nova_acao_page.dart
lib/modules/acoes/resultados_page.dart
lib/modules/acoes/revisao_relatorio_page.dart
lib/modules/acoes/controllers/acao_controller.dart
lib/modules/acoes/widgets/qr_rae_card.dart
```

## 10. Módulo de localização — referência oficial

A localização inteligente não está dentro de `modules/acoes`. O caminho oficial é:

```text
lib/modules/localizacao/
```

Tela principal:

```text
lib/modules/localizacao/localizacao_page.dart
```

Widgets oficiais:

```text
lib/modules/localizacao/widgets/endereco_manual_card.dart
lib/modules/localizacao/widgets/faxita_location_card.dart
lib/modules/localizacao/widgets/gps_status_card.dart
lib/modules/localizacao/widgets/localizacao_action_bar.dart
lib/modules/localizacao/widgets/localizacao_form_card.dart
lib/modules/localizacao/widgets/mapa_localizacao_widget.dart
```

Arquivos relacionados:

```text
lib/core/services/geolocalizacao_service.dart
lib/modules/acoes/controllers/acao_controller.dart
lib/data/models/acao_model.dart
```

Esta seção deve ser consultada obrigatoriamente antes de qualquer alteração do CE-030B.

## 11. Outros módulos

```text
lib/modules/admin/
lib/modules/auth/
lib/modules/avaliacao/
lib/modules/coordenadores/
lib/modules/dashboard/
lib/modules/educacao/
lib/modules/evidencias/
lib/modules/home/
lib/modules/integracao/
lib/modules/localizacao/
lib/modules/materiais/
lib/modules/recursos/
lib/modules/regionais/
lib/modules/revisao/
lib/modules/sincronizacao/
lib/modules/tipos_acoes/
lib/modules/usuarios/
```

## 12. Assets oficiais

```text
assets/images/faixita_login.png
assets/images/footer_timbrado.png
assets/images/header_timbrado.png
assets/images/login_beira_mar.webp
```

Todo novo asset deve ser declarado no `pubspec.yaml` e validado com `flutter pub get`.

## 13. Android

```text
android/settings.gradle.kts
android/build.gradle.kts
android/gradle.properties
android/secrets.properties
android/secrets.properties.example
android/app/build.gradle.kts
android/app/google-services.json
android/app/src/main/AndroidManifest.xml
android/app/src/main/kotlin/com/example/geduc_rae_mobile/MainActivity.kt
```

A chave real de API não deve ser adicionada ao Git.

## 14. Arquivos que não devem ser versionados

```text
.dart_tool/
build/
android/.gradle/
android/.kotlin/
android/local.properties
android/secrets.properties
*.log
```

## 15. Convenções

Arquivos Dart usam `snake_case` e classes usam `PascalCase`.

- Tela principal: pasta do módulo.
- Widgets exclusivos: `widgets/`.
- Controllers exclusivos: `controllers/`.
- Serviços compartilhados: `lib/core/services/`.
- Modelos de domínio: `lib/data/models/`.
- Persistência: `lib/repositories/`.

## 16. Validação antes do commit

```powershell
flutter analyze
flutter test
git status
git diff
```

Nenhuma etapa deve ser homologada com erro no `flutter analyze`.

## 17. Atualização da árvore oficial

Na raiz do projeto:

```powershell
cmd /c tree /F > arvore_projeto.txt
```

Depois, atualizar este documento quando houver novos módulos, movimentação de arquivos ou reorganização estrutural.

## 18. Registro de decisões

| Data | Pacote | Decisão |
|---|---|---|
| 2026-07-24 | Estrutura oficial | Criado o mapa oficial com base em `arvore_projeto.txt`. |
| 2026-07-24 | CE-030B | Confirmado que a localização fica em `lib/modules/localizacao/`. |

## 19. Regra final

Antes de indicar qualquer caminho de arquivo, consultar:

```text
docs/00_MAPA_OFICIAL_DO_PROJETO.md
arvore_projeto.txt
```

Em caso de divergência, a estrutura física mais recente do projeto prevalece e este documento deve ser atualizado no mesmo commit.
