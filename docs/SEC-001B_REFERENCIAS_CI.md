# SEC-001B — Referências de CI e segurança

Consulta técnica iniciada e consolidada em 03/08/2026.

## GitHub Actions e rulesets

- Uso seguro de actions e fixação por SHA completo:
  <https://docs.github.com/en/actions/reference/security/secure-use>
- Sintaxe de workflows:
  <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>
- Concorrência de workflows e jobs:
  <https://docs.github.com/en/actions/using-jobs/using-concurrency>
- Status checks:
  <https://docs.github.com/en/pull-requests/reference/status-checks>
- Regras disponíveis em rulesets:
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets>
- Criação de rulesets de repositório:
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository>
- Solução de problemas com checks obrigatórios:
  <https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks>

## Actions auditadas

| Action | Tag auditada | SHA fixado |
| --- | --- | --- |
| `actions/checkout` | `v7.0.1` | `3d3c42e5aac5ba805825da76410c181273ba90b1` |
| `actions/setup-node` | `v7.0.0` | `820762786026740c76f36085b0efc47a31fe5020` |
| `actions/setup-java` | `v5.7.0` | `b6effb05e454b25005698d916606bdc6ffcbf961` |
| `subosito/flutter-action` | `v2.23.0` | `1a449444c387b1966244ae4d4f8c696479add0b2` |

Repositórios oficiais:

- <https://github.com/actions/checkout>
- <https://github.com/actions/setup-node>
- <https://github.com/actions/setup-java>
- <https://github.com/subosito/flutter-action>

## Decisões implementadas

1. Actions oficiais e de terceiros estão fixadas por SHA completo.
2. O token possui somente `contents: read`.
3. Não existem filtros de caminho nos eventos que originam checks obrigatórios.
4. Os jobs possuem nomes exclusivos e estáveis.
5. O workflow não contém deploy, segredo ou autenticação Firebase.
6. O ruleset foi criado somente depois da primeira execução bem-sucedida e da
   confirmação dos nomes exatos dos checks.
7. A origem exigida para os checks é o GitHub Actions.
8. A atualização da branch com a base foi exigida no modo estrito.

## Configuração homologada

| Item | Valor |
| --- | --- |
| Ruleset | `main-quality-gates` |
| Identificador | `20301322` |
| Estado | `Active` |
| Check obrigatório | `Quality Gate - Flutter Analyze` |
| Check obrigatório | `Quality Gate - Firestore Rules` |
| Pull Request de prova | nº 9 |
| Merge da prova | `a45c142` |

## Evidência em relação às referências

As regras oficiais do GitHub determinam que checks configurados como
obrigatórios precisam concluir com sucesso antes do merge. A HAT-4 confirmou
esse comportamento no Pull Request nº 9, com os dois checks marcados como
`Required`, sucesso de ambos e merge posterior sem bypass.

A fixação das actions por SHA completo segue a recomendação oficial para obter
referência imutável do código executado. A execução usa apenas dependências
versionadas e o emulador local, reduzindo a superfície de credenciais e de
efeitos remotos.

## Débito de supply chain

O `npm ci` aprovado reportou seis vulnerabilidades moderadas e avisos de scripts
de instalação para `@firebase/util`, `protobufjs` e `re2`. O registro não
invalida os testes homologados, mas exige pacote específico de auditoria e
atualização controlada. Nenhum `npm audit fix --force` foi executado.
