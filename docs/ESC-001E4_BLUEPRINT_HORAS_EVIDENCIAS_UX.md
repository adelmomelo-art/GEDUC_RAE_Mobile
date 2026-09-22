# PLATAFORMA FÊNIX
# ESC-001E.4 — HORAS REALIZADAS E EVIDÊNCIAS NA UX

**Baseline de entrada:** `1aa4177f496c63e52b629b689df09f1bacaf1940`
**Etapa anterior:** ESC-001E.3 — FECHADA
**Objetivo:** conectar à interface os contratos de horas realizadas e de
metadados de evidência já protegidos nas etapas E.1 e E.2.

## 1. Horas realizadas

O titular da alocação em escala publicada pode informar:

```text
horaInicioReal
horaFimReal
minutosRealizados calculados
observacao
```

O controller calcula a duração, inclusive quando o intervalo atravessa a
meia-noite. O repositório confirma a identidade da alocação e o estado
`publicada` antes de gravar somente os seis campos autorizados pelas Rules.

Na tela da Escala, a ação aparece apenas na atividade que possui alocação do
usuário autenticado. Coordenar a atividade não autoriza alterar horas de outro
agente.

## 2. Evidências administrativas

Na execução de missão em andamento, o executor pode incluir e remover até 20
metadados dos tipos:

```text
foto
documento
arquivo
link
observacao
outro
```

Cada item exige descrição ou referência e recebe autoria e data do próprio
executor. Execuções concluídas ou canceladas permanecem somente para consulta.

## 3. Proteções preservadas

```text
planejamento/QTR/QTH       = imutável
tipo de jornada            = imutável na execução
classificação da dobra     = NORMAL | HORA_EXTRA | BANCO_HORAS
Storage/R2/App Check       = inalterados
arquivo físico             = não enviado
financeiro                 = ausente
Escala → RAE               = ESC-001F
```

## 4. Homologação mínima

```text
participante registra e edita as próprias horas
minutos são calculados a partir de HH:mm
horas de outro usuário são negadas
rascunho não aceita horas realizadas
planejamento publicado não é alterado
executor inclui e remove metadado de evidência
limite de 20 evidências é respeitado
registro terminal não permite alteração
nenhum upload físico é executado
```
