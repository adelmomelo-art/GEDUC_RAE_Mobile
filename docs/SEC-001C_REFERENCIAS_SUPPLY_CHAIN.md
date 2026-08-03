# SEC-001C — Referências de supply chain npm

Consulta técnica consolidada em 03/08/2026.

## Referências oficiais

- Auditoria npm:
  <https://docs.npmjs.com/cli/v11/commands/npm-audit/>
- Aprovação de scripts de instalação:
  <https://docs.npmjs.com/cli/v11/commands/npm-approve-scripts/>
- Configuração npm, incluindo `audit-level` e `strict-allow-scripts`:
  <https://docs.npmjs.com/cli/v11/using-npm/config/>
- Advisory OpenTelemetry:
  <https://github.com/advisories/GHSA-8988-4f7v-96qf>
- Advisory RE2 — leitura fora dos limites:
  <https://github.com/advisories/GHSA-ff84-5f28-78qj>
- Advisory RE2 — loop e consumo de memória:
  <https://github.com/advisories/GHSA-6hxr-mr5r-9836>
- Advisory UUID:
  <https://github.com/advisories/GHSA-w5hq-g745-h8pq>

## Decisões

1. `audit-level=high` define o limiar de falha, mas mantém todas as
   vulnerabilidades no relatório.
2. `npm audit fix --force` foi proibido porque a solução proposta exige
   downgrade major do Firebase CLI.
3. A correção não forçada do `re2` foi incorporada ao lockfile.
4. Scripts de instalação foram aprovados individualmente e fixados por versão.
5. O script de `fsevents` foi negado por ser opcional e exclusivo de macOS.
6. A política estrita faz versões futuras voltarem ao estado não aprovado.
7. As exceções moderadas remanescentes serão reavaliadas quando a cadeia do
   Firebase CLI disponibilizar correção compatível.

## Scripts revisados

### `@firebase/util@1.12.1`

O `postinstall` lê configuração opcional do ambiente, prepara defaults locais e
grava arquivos internos do próprio pacote. No fluxo do emulador isolado não são
fornecidas credenciais nem configuração de produção.

### `protobufjs@7.6.5`

O `postinstall` lê manifests locais para validar a convenção de versão usada por
dependentes. Não realiza deploy nem acesso a credenciais.

### `re2@1.26.1`

O `install` obtém artefato nativo compatível ou executa compilação local via
`node-gyp`. É necessário para materializar o módulo opcional usado pela cadeia
do `superstatic` e fica aprovado somente nessa versão auditada.

## Resultado homologado

- diagnóstico inicial: seis ocorrências moderadas;
- `re2` atualizado de `1.24.1` para `1.26.1` sem `--force`;
- resultado final: cinco ocorrências moderadas, zero alta e zero crítica;
- scripts de instalação pendentes: zero;
- Pull Request nº 11 aprovado pelos dois checks obrigatórios;
- merge: `6b53c8f`;
- workflow pós-merge da `main`: sucesso em 43 segundos.

Os advisories `GHSA-ff84-5f28-78qj` e `GHSA-6hxr-mr5r-9836`, associados à
versão anterior do `re2`, deixaram de compor o relatório após a atualização.

## Exceções temporárias

| Advisory | Severidade | Motivo da exceção |
| --- | --- | --- |
| `GHSA-8988-4f7v-96qf` | moderada | sem correção compatível na árvore atual |
| `GHSA-w5hq-g745-h8pq` | moderada | correção sugerida exige downgrade do CLI |

As exceções não autorizam uso de `--force`, não dispensam monitoramento e não
alteram o bloqueio automático para severidades alta e crítica.

## Rastreabilidade Git

| Item | Referência |
| --- | --- |
| Baseline de entrada | `3400563` |
| Branch | `security/sec-001c-hardening-supply-chain` |
| Commit de implementação | `2c16d4d86c7a4d25f421cb0e36f79b6d58c1d5df` |
| Pull Request | nº 11 |
| Merge / baseline final | `6b53c8fe0964d91dc018799bcff8fcd429fa53af` |
