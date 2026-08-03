# SEC-001B — Referências de CI e segurança

Consulta técnica realizada em 03/08/2026.

## GitHub Actions

- Uso seguro de actions e fixação por SHA completo:
  <https://docs.github.com/en/actions/reference/security/secure-use>
- Sintaxe de workflows:
  <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>
- Concorrência de workflows e jobs:
  <https://docs.github.com/en/actions/using-jobs/using-concurrency>
- Solução de problemas com checks exigidos e workflows ignorados:
  <https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks>
- Proteção de branches:
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule>
- Requisitos e nomes exclusivos de checks:
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches>

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

## Decisões resultantes

1. Actions de terceiros e oficiais serão fixadas por SHA completo.
2. O token terá somente `contents: read`.
3. Não haverá filtros de caminho nos eventos que originam checks obrigatórios.
4. Os jobs possuirão nomes exclusivos e estáveis.
5. A proteção da `main` será aplicada somente após a primeira execução bem
   sucedida e a confirmação dos nomes exatos dos checks.
6. O workflow não conterá deploy, segredo ou autenticação Firebase.
