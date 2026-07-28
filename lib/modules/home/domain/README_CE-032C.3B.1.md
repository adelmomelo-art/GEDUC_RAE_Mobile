# CE-032C.3B.1 — Núcleo de Domínio (Rule Engine)

## Objetivo

Criar o primeiro motor de regras operacionais da Plataforma Fênix, totalmente
desacoplado da interface, Firebase, controllers e serviços de infraestrutura.

## Arquivos

```text
lib/modules/home/domain/
├── alert_level.dart
├── operational_alert.dart
├── operational_rule.dart
├── operational_rule_engine.dart
├── rules/
│   ├── offline_rule.dart
│   ├── pending_sync_rule.dart
│   ├── cache_stale_rule.dart
│   ├── sync_error_rule.dart
│   └── last_update_rule.dart
└── README_CE-032C.3B.1.md
```

## Regras incluídas

1. Operação offline.
2. Registros pendentes de sincronização.
3. Cache desatualizado.
4. Falhas consecutivas de sincronização.
5. Ausência de atualização operacional recente.

## Instalação

Copie a pasta `lib` do pacote para a raiz do projeto, preservando a estrutura.

Nenhum arquivo existente deve ser substituído nesta sprint.

## Validação

Execute:

```powershell
dart format lib/modules/home/domain
flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Observação arquitetural

A CE-032C.3B.1 não integra o motor ao `HomeController` nem ao `HomeState`.
Essa integração pertence à CE-032C.3B.2.

O `OperationalRuleContext` funciona como contrato de entrada do domínio.
Na próxima sprint, o controller converterá o estado real da aplicação nesse
contexto e solicitará ao `OperationalRuleEngine` a geração dos alertas.
