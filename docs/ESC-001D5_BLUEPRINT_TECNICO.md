# ESC-001D.5 — BLUEPRINT TÉCNICO
## Publicação, Revisão e Versionamento da Escala GEDUC

**Baseline:** `cf0df4c0aa510e470db209e28cc762700190a878`
**Dependências:** ESC-001D.1 a ESC-001D.4 fechadas
**Plano de origem:** ESC-001D_PLANO_IMPLEMENTACAO_v0.1 — seção 81

## 1. Resultado

A D.5 fecha o ciclo diário:

```text
RASCUNHO
  ↓
REVISÃO DA PUBLICAÇÃO
  ↓
BLOCKERS + ALERTAS
  ↓
PUBLICAÇÃO
  ↓
PUBLICADA v1
  ↓
REVISAR ESCALA
  ↓
RASCUNHO v2
  ↓
REPUBLICAÇÃO
  ↓
PUBLICADA v2
```

## 2. Blockers x alertas

**Blocker** é somente problema estrutural que torna o dado inválido.

Exemplos implementados:

- atividade sem data coerente;
- atividade sem título/tipo/seção/turno;
- natureza inválida;
- educativa com `geraRae=false`;
- administrativa com `geraRae=true`;
- alocação apontando para atividade inexistente;
- jornada complementar sem motivo/autoria/timestamp;
- revisão sem origem, motivo ou preparação completa.

Continuam **não bloqueantes**:

- sobreposição;
- férias;
- folga;
- compensação;
- múltipla alocação;
- agente sem situação definida;
- identidade operacional não canônica.

## 3. Publicação consciente

Antes de publicar, a Gestão apresenta:

```text
Data
Atividades
Agentes
Educativas
Administrativas
Alertas
Blockers
```

Somente blockers desabilitam a publicação.

## 4. Versionamento sem sobrescrita silenciosa

Uma escala publicada nunca tem sua estrutura editada diretamente.

Para revisar:

```text
PUBLICADA v1
  ↓ motivo obrigatório
cria RASCUNHO v2
  ↓
clona atividades/alocações
  ↓
edita v2
  ↓
publica v2 + arquiva v1
```

A versão v1 continua publicada e visível durante a preparação/edição de v2.
Na republicação, a troca de `v1 publicada` para `v1 arquivada` e
`v2 rascunho` para `v2 publicada` ocorre no mesmo batch de publicação.

## 5. Proveniência

A revisão registra:

```text
revisaoDeEscalaId
revisaoPreparada
motivoRevisao
versao
```

Alocação clonada registra:

```text
origemAlocacaoId
```

Esse vínculo permite ao Firestore autorizar o Gerente a copiar uma
classificação complementar já homologada sem permitir que ele invente ou
reclassifique HORA_EXTRA/BANCO_HORAS.

A regra estável da D.4 permanece:

```text
nova classificação / reclassificação
= agente responsável
```

## 6. Gerente

O Gerente:

```text
criar escala inicial      = DENY
editar rascunho           = ALLOW
publicar                  = ALLOW
iniciar revisão           = ALLOW
republicar                = ALLOW
reclassificar jornada     = DENY
```

## 7. Consulta x Gestão durante revisão

Consulta:

```text
prioriza última PUBLICADA
```

Gestão:

```text
prioriza último RASCUNHO
```

Assim, uma revisão v2 não retira v1 da consulta antes da republicação.

## 8. Preparação retomável

A clonagem usa IDs determinísticos e transações de um documento por vez para
reduzir risco de limite de acessos das Firestore Rules e impedir sobrescrita
concorrente.

Se houver interrupção:

```text
revisaoPreparada = false
```

A Gestão bloqueia edição/publicação e oferece **Retomar revisão**.
Após concluir todos os clones:

```text
revisaoPreparada = true
```

## 9. Fora da D.5

- configuração do responsável (D.6);
- execução operacional (E);
- Escala → RAE (F);
- PDF oficial (G);
- indicadores/Faixita (H);
- financeiro.
