# ESC-001D.2 — BLUEPRINT TÉCNICO
## Equipe GEDUC, Conferência do Efetivo, Horas e Conflitos

**Baseline:** `c4af0b1dbb366b2352d6ac60b4bf20193ad9eda9`
**Etapa anterior:** ESC-001D.1 — FECHADA
**Status:** IMPLEMENTAÇÃO AUTORIZADA PELO PLANO ESC-001D v0.1

## 1. Objetivo

Criar o núcleo de domínio puro que permita à futura Gestão da Escala responder,
sem depender de widgets ou Firestore, às perguntas:

- quantas pessoas compõem o efetivo GEDUC esperado;
- quantas estão explicadas no dia;
- quais ficaram sem situação;
- quantas possuem mais de uma alocação;
- quais alocações são normal, hora extra ou banco de horas;
- quantas horas estão programadas por natureza;
- onde há sobreposição de horários;
- onde existe identidade operacional sem UID canônico.

## 2. Regra de efetivo

O denominador diário é formado por:

```text
MembroEquipeModel.ativo = true
+
EscalaPerfilOperacionalModel.ativo = true
+
setorCodigo = GEDUC
```

A pessoa é deduplicada prioritariamente por `usuarioId` canônico. Quando o UID
não existe, o `membroEquipeId` é usado apenas como fallback operacional
explícito e o resultado marca `identidadeCanonica = false`.

## 3. Cobertura

Cobertura é conjunto de pessoas únicas:

```text
em atividade
OU
com indisponibilidade informada
```

Múltiplas alocações não aumentam o efetivo.

Férias, compensação, folga e outros tipos de indisponibilidade explicam a
situação do agente e não bloqueiam a escala.

## 4. Horas

A ESC-001D.2 calcula apenas horas programadas.

Internamente, o cálculo é feito em minutos inteiros. Não existe valor
financeiro, custo, remuneração ou folha de pagamento.

## 5. Conflitos

Segunda jornada e sobreposição são conceitos separados:

```text
segunda jornada = mais de uma alocação da mesma pessoa no mesmo dia
sobreposição = intervalos horários que se cruzam
```

A detecção de conflito produz informação de domínio; não bloqueia publicação.

## 6. Histórico

Esta etapa usa o efetivo operacional ativo no momento da consulta. Snapshot
histórico/date-effective membership não é criado nesta subetapa e permanece
fora do escopo até decisão específica de histórico.

## 7. Entregáveis

```text
EscalaConferenciaService
EscalaHorasService
EscalaConflitoService
testes unitários
fixture funcional equivalente a 35 agentes
```
