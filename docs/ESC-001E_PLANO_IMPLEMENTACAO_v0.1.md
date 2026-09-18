# PLATAFORMA FÊNIX
# ESC-001E — PLANO DE IMPLEMENTAÇÃO v0.1
## Execução Operacional da Escala GEDUC

**Baseline:** `f1fe5fa513f42524fac64c74d824e623f9dcf2ff`
**Blueprint:** `ESC-001E_BLUEPRINT_EXECUCAO_OPERACIONAL_v0.1`

## 1. E.1 — contratos e segurança

Entregar:

```text
tipos canônicos de evidência
permissão registrarHorasRealizadas
EscalaExecucaoService
resumo de horas realizadas
Rules para execução somente em escala publicada
Rules para horas reais da própria alocação
proteção dos campos planejados
lifecycle terminal da execução
testes Dart
testes Firestore
```

Sem rota/tela nova nesta subetapa.

## 2. E.2 — camada de dados e controller

Criar:

```text
EscalaExecucaoRepository
FirestoreEscalaExecucaoRepository
EscalaExecucaoController
```

Responsabilidades:

```text
carregar atividade publicada
carregar equipe
carregar execução do usuário
iniciar execução
salvar resultado/observação
concluir/cancelar
anexar/remover metadado de evidência
```

ID de execução deverá ser determinístico por atividade + usuário autenticado
para impedir duplicidade acidental.

## 3. E.3 — UI Execução da Missão

Rota proposta:

```text
/escala/execucao/:atividadeId
```

Abertura somente para:

```text
atividade administrativa publicada
+
participante ou coordenador
```

Tela:

```text
atividade
data
equipe
status
resultado
observação
evidências
concluir/cancelar
```

Não expor campos de planejamento para edição.

## 4. E.4 — horas realizadas

Na própria atividade/alocação:

```text
Início real
Fim real
Minutos realizados calculados
Observação
```

Critério:

```text
usuário autenticado == usuarioId da própria alocação
escala publicada
```

O controller calcula minutos; Rules validam estrutura e ownership.

## 5. E.5 — fechamento

Executar:

```text
dart format
flutter test focado
flutter test completo
flutter analyze
npm ci
npm run test:rules
git diff --check
CPB
6 Quality Gates
merge
cleanup
```

## 6. Critérios de homologação ESC-001E

```text
[ ] execução administrativa só em escala publicada
[ ] educativa não usa execução administrativa
[ ] participante executa própria missão
[ ] coordenador executa missão coordenada
[ ] não participante = DENY
[ ] executor não pode ser forjado
[ ] conclusão exige resultado e timestamp
[ ] terminal não reabre no cliente
[ ] evidências limitadas e tipadas no domínio
[ ] participante registra próprias horas reais
[ ] coordenador não altera horas de outro agente
[ ] planejamento publicado permanece imutável
[ ] horas previstas continuam chamadas programadas
[ ] horas reais são separadas por normal/extra/banco
[ ] nenhum financeiro
[ ] Flutter Test PASS
[ ] Flutter Analyze PASS
[ ] Firestore Rules PASS
[ ] 6/6 Quality Gates
```
