# ESC-001H.1 — Blueprint do núcleo histórico de horas

**Baseline de entrada:** `4f78a102808facd791790042fae3311eedafe4e2`

**Etapa anterior:** ESC-001G — FECHADA

## 1. Objetivo

Estabelecer o contrato puro e testável usado posteriormente pelos indicadores
históricos, análise de produtividade e Faixita. A primeira subetapa consolida
horas e saldo de banco sem depender de UI, Firestore ou estado global.

## 2. Fonte operacional

O serviço recebe dias já carregados como `EscalaDiaConsulta`. Apenas dias cuja
escala esteja em estado `publicada` e cuja data pertença ao período inclusivo
são considerados.

Cada data publicada pode aparecer uma única vez. Duplicidade interrompe a
consolidação para evitar dupla contabilização silenciosa.

## 3. Naturezas de horas realizadas

| Origem | Classificação | Efeito |
|---|---|---|
| alocação `normal` | realizada normal | compõe total realizado |
| alocação `hora_extra` | realizada extra | compõe total realizado, sem efeito no banco |
| alocação `banco_horas` | crédito de banco | compõe total realizado e aumenta saldo |
| indisponibilidade `compensacao` | débito de banco | reduz saldo, sem compor trabalho realizado |

O modelo não atribui valor monetário a nenhuma natureza.

## 4. Validade dos registros

Uma alocação realizada é válida quando início, fim e minutos persistidos estão
presentes e os minutos são iguais à duração calculada. Campo parcial,
formatação inválida ou divergência é classificada como inválida.

Uma compensação é válida quando possui início e fim válidos, duração positiva
e duração máxima de 24 horas. Sem os dois horários, permanece pendente. Campo
parcial ou inválido não gera débito.

## 5. Identidade e saldo

O saldo individual usa `usuarioId` como chave preferencial e
`membroEquipeId` como alternativa. Quando registros posteriores demonstram
que as duas chaves representam a mesma pessoa, os acumuladores são
reconciliados. Nome é apenas snapshot de exibição e nunca chave de união.

Fórmula operacional:

`saldoMinutos = minutosCreditoBanco - minutosCompensadosBanco`

Saldo negativo é exposto, não corrigido automaticamente. Essa decisão mantém
o resultado auditável e permite que a camada de análise sinalize a ocorrência.

## 6. Pendências

O resultado informa separadamente:

- alocações sem horas realizadas;
- alocações com horas inválidas;
- créditos de banco pendentes por pessoa;
- compensações sem horário;
- compensações inválidas;
- registros de banco ou compensação sem identidade canônica.

Nenhuma pendência é convertida em minutos por suposição.

## 7. Faseamento da ESC-001H

- **ESC-001H.1:** núcleo histórico de horas e saldo de banco;
- **ESC-001H.2:** consulta por período, repositório, controlador e acesso;
- **ESC-001H.3:** painel de indicadores e produtividade;
- **ESC-001H.4:** Faixita explicável, sem decisão automática opaca;
- **ESC-001H.5:** homologação integral e fechamento.

## 8. Fora do escopo permanente

Não fazem parte da ESC-001H folha de pagamento, remuneração, adicionais,
conversão monetária, orçamento ou qualquer cálculo financeiro.
