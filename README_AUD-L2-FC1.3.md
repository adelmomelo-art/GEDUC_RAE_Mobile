# AUD-L2-FC1.3 — Supply Chain Dependency Remediation

## Status

HOMOLOGADO LOCALMENTE — PRE-COMMIT.

## Data

09/09/2026

## Baseline

`c9345e8350533ccb7da831a84070df2d0ed29ee1`

## Branch

`audit/aud-l2-fc1-supply-chain-remediation`

## Contexto

Durante o fechamento consolidado da Auditoria Lote 2, o gate
`npm audit --audit-level=high` identificou 14 vulnerabilidades transitivas na
toolchain Node:

- 12 moderate;
- 2 high;
- 0 critical.

O audit restrito a dependências de produção retornou zero vulnerabilidades,
demonstrando que o achado estava restrito às devDependencies utilizadas pela
toolchain de engenharia, Firebase CLI, emuladores e testes.

## Remediação

A intervenção foi mantida fora do código Flutter e das regras Firestore.

Alterações:

1. `firebase-tools`: `15.25.1` -> `15.30.0`;
2. override de `fast-uri` para `3.1.7`;
3. override de `js-yaml` para `4.3.2`;
4. regeneração reprodutível do `package-lock.json`.

Os overrides permanecem dentro dos ranges declarados pelas dependências
superiores:

- AJV aceita `fast-uri ^3.0.1`;
- Firebase Tools aceita `js-yaml ^4.2.0`;
- JSON Schema Ref Parser aceita `js-yaml ^4.1.0`.

Não foi utilizado `npm audit fix` nem `npm audit fix --force`.

## Resultado de segurança

Após a remediação:

- high: 0;
- critical: 0;
- moderate: 12;
- `npm audit --audit-level=high`: PASS;
- `npm audit --omit=dev --audit-level=high`: 0 vulnerabilities / PASS.

As vulnerabilidades moderate remanescentes pertencem à cadeia transitiva da
toolchain Node e não bloqueiam o contrato atual do Quality Gate, configurado
para falhar a partir de severidade high.

## Gates de homologação

- `npm ci`: PASS;
- resolução `firebase-tools@15.30.0`: PASS;
- `fast-uri@3.1.7`: PASS;
- `js-yaml@4.3.2`: PASS;
- security audit high/critical: PASS;
- production dependency audit: PASS / zero vulnerabilidades;
- Firestore Rules: 22/22 PASS;
- MIG-001E3: 25/25 PASS;
- MIG-001E4: 15/15 PASS;
- MIG-001E5: 16/16 PASS;
- MIG-001E6: 12/12 PASS;
- `flutter analyze --no-pub`: PASS / 0 issues;
- `flutter test --no-pub`: 919/919 PASS;
- `git diff --check`: PASS.

## Escopo funcional

Nenhum código de produção Flutter foi alterado.

Nenhuma alteração foi realizada em:

- Firestore Rules;
- Firebase App Check;
- Firebase Storage;
- RBAC;
- identidade Android;
- fluxo funcional da aplicação;
- MIG-001E3/E4/E5/E6.

## Observações residuais

Permanecem registradas para acompanhamento:

1. 12 vulnerabilidades moderate na toolchain Node;
2. dependências transitivas Node com avisos de depreciação;
3. avisos de fonte Helvetica sem suporte Unicode nos testes do relatório PDF.

Esses itens não reprovaram os gates desta remediação.

## Parecer

AUD-L2-FC1.3: HOMOLOGADO TECNICAMENTE.

O bloqueador de supply chain encontrado durante o fechamento do Lote 2 foi
removido sem regressão funcional e sem ampliar o escopo para o aplicativo ou
para as regras de segurança.

Próxima etapa: reconciliação documental e parecer consolidado da Auditoria
Lote 2.