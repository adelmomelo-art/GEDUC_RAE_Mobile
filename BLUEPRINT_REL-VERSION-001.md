# REL-VERSION-001 - Versionamento e Identificacao de Ambiente

## Objetivo

Eliminar informacoes de versao, build e ambiente codificadas manualmente na tela de login da Plataforma Fenix.

## Baseline

- baseline: d98b41b4fc812c8af4bb5263cff573613d93d44e
- branch: release/rel-version-001-versionamento
- versao anterior: 1.0.0+1
- versao alvo: 1.0.0+2

## Arquitetura

A versao e o numero de build sao obtidos dos metadados do pacote instalado por package_info_plus.

O ambiente e definido em tempo de compilacao por APP_ENV usando String.fromEnvironment.

Valores oficiais:

- development
- homologacao
- production

Quando APP_ENV estiver ausente ou invalido, o aplicativo exibira NAO DEFINIDO.

Nenhum ambiente produtivo ou de homologacao sera assumido implicitamente.

## Componentes

- lib/core/config/app_environment.dart
- lib/core/version/app_build_info.dart
- lib/modules/auth/login_page.dart
- pubspec.yaml
- pubspec.lock

## Seguranca e preservacao

Esta frente nao altera:

- Firebase App Check
- Firestore Rules
- Firebase Storage
- identidade Android
- assinatura release
- configuracao Firebase

A autorizacao institucional para futura entrada em producao nao elimina os bloqueadores tecnicos de Release Readiness ainda pendentes.
