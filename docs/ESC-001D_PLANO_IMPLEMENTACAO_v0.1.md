# PLATAFORMA FÊNIX
# ESC-001D — PLANO DE IMPLEMENTAÇÃO v0.1
## Gestão, Consulta e Conferência Operacional da Escala GEDUC

**Baseline técnica:** `603b891c6c3adfb37543122058c7e23a6dc93766`
**Blueprint funcional:** `ESC-001D_BLUEPRINT_TELAS_FLUXO_OPERACIONAL_v0.3` — HOMOLOGADO
**Etapa anterior:** ESC-001C — FECHADA
**Status deste documento:** PROPOSTA DE PLANO PARA HOMOLOGAÇÃO TÉCNICA
**Objetivo:** converter o Blueprint aprovado em uma implementação Flutter/Firestore fechada, testável e homologável.

---

# 1. RESULTADO ESPERADO DA ESC-001D

Ao final da ESC-001D, o Fênix deverá permitir:

1. manter o cadastro operacional dos integrantes da GEDUC para fins de escala;
2. identificar o efetivo ativo esperado do dia;
3. criar uma escala diária em rascunho;
4. incluir ações educativas e missões administrativas;
5. alocar agentes e Coordenador;
6. classificar a jornada de cada alocação como `NORMAL`, `HORA_EXTRA` ou `BANCO_HORAS`;
7. calcular horas programadas por natureza de jornada;
8. identificar todos os agentes da GEDUC por pessoa única;
9. detectar agentes sem situação definida;
10. detectar sobreposição e indisponibilidade sem bloquear a decisão operacional;
11. consultar a escala completa;
12. usar “Minha Escala” como filtro da mesma tela;
13. revisar e publicar a escala;
14. revisar uma escala publicada com versionamento;
15. designar o agente fixo responsável pela escala;
16. manter as permissões coerentes entre Flutter e Firestore Rules.

A ESC-001D não implementará ainda a execução completa das missões, o vínculo automático com RAE, o PDF oficial ou indicadores históricos consolidados.

---

# 2. PRINCÍPIO TÉCNICO

A implementação deve obedecer à seguinte separação:

```text
EQUIPE OPERACIONAL
= identidade canônica da pessoa

PERFIL OPERACIONAL DA ESCALA
= participação da pessoa no universo GEDUC da escala

ESCALA
= dia/versionamento/publicação

ATIVIDADE
= missão planejada

ALOCAÇÃO
= pessoa dentro de uma atividade

INDISPONIBILIDADE
= situação informativa do agente no dia

CONFERÊNCIA
= comparação entre efetivo GEDUC e situações do dia

HORAS
= tempo associado às alocações
```

Nenhuma dessas entidades deve substituir outra.

---

# 3. BASELINE TÉCNICA EXISTENTE

A ESC-001C já entregou:

```text
EscalaConfiguracaoModel
EscalaPerfilOperacionalModel
EscalaModel
EscalaAtividadeModel
EscalaAlocacaoModel
EscalaIndisponibilidadeModel
ExecucaoMissaoModel
MissaoEvidenciaModel
```

Também já existem:

```text
EscalaPermission
EscalaAccessPolicy
Firestore Rules específicas da Escala
testes Dart da política
testes Firestore Rules
```

As coleções já estabelecidas são:

```text
escala_configuracoes
escala_perfis_operacionais
escalas
escala_atividades
escala_alocacoes
escala_indisponibilidades
escala_execucoes_missao
```

A ESC-001D deve evoluir essa fundação, e não criar um segundo modelo paralelo.

---

# 4. GAP TÉCNICO A CORRIGIR ANTES DAS TELAS

## ESC-001D-GAP-001 — criação da escala

O Blueprint homologado estabelece:

```text
Agente responsável:
cria, edita, revisa e publica.

Gerente:
revisa, altera, publica e designa responsável.
```

A política atualmente versionada na ESC-001C agrupa `criarEscala`,
`editarEscala`, `revisarEscala` e `publicarEscala` sob a mesma autorização.

A ESC-001D deverá separar explicitamente:

```text
podeCriarEscala
podeEditarEscala
podeRevisarEscala
podePublicarEscala
```

Regra operacional do MVP:

```text
CRIAR NOVA ESCALA
= agente fixo responsável

EDITAR ESCALA EXISTENTE
= agente responsável
  ou Gerente

REVISAR / PUBLICAR
= agente responsável
  ou Gerente

DESIGNAR RESPONSÁVEL
= Gerente
  ou Administrador técnico
```

O Administrador permanece como governança técnica/configuração, não como
autor operacional padrão de uma nova escala.

As regras Dart e Firestore devem produzir a mesma decisão.

---

# 5. CADASTRO DA EQUIPE OPERACIONAL GEDUC

## 5.1. Fonte canônica

Não será criado um novo cadastro de pessoas.

A pessoa continua em:

```text
equipe_operacional
```

O cadastro específico para participação na Escala GEDUC continuará usando:

```text
escala_perfis_operacionais
```

Vínculo:

```text
EscalaPerfilOperacionalModel.membroEquipeId
        ↓
equipe_operacional/{membroEquipeId}
```

---

# 6. CONCEITO DE EFETIVO GEDUC

O universo da conferência diária será:

```text
membro de equipe_operacional
+
membro ativo
+
perfil operacional de escala ativo
+
setorCodigo = GEDUC
```

Exemplo:

```text
Equipe Operacional GEDUC ativa:
35 agentes
```

Esse número é a referência da conferência diária.

Um integrante inativo não entra no denominador.

---

# 7. TELA DE CADASTRO OPERACIONAL GEDUC

A configuração deverá permitir ao Gerente/Administrador visualizar e manter:

```text
nome
vínculo operacional
ativo/inativo na Escala GEDUC
carga horária
pode coordenar
```

A identidade e o nome continuam vindos da Equipe Operacional.

A tela não duplica:

```text
nome
e-mail
usuário Firebase
```

Ela apenas mantém os atributos necessários para a Escala.

---

# 8. CARGA HORÁRIA

Valores iniciais conhecidos:

```text
180H
240H
```

Esses valores são atributos do agente.

Os horários exibidos no documento de referência para 180H/240H permanecem
informativos.

Não deve existir regra:

```text
180H = horário obrigatório X
240H = horário obrigatório Y
```

---

# 9. MODELO DE JORNADA

A ESC-001D adicionará códigos explícitos:

```text
normal
hora_extra
banco_horas
```

Sugestão de constantes:

```text
EscalaCodigos.jornadaNormal
EscalaCodigos.jornadaHoraExtra
EscalaCodigos.jornadaBancoHoras
```

Toda alocação deverá possuir `tipoJornada`.

---

# 10. REGRA DA PRIMEIRA ALOCAÇÃO DO DIA

Quando o agente ainda não possuir outra alocação na data:

```text
tipoJornada sugerido = normal
```

A sugestão pode ser aceita diretamente.

O valor continua persistido explicitamente.

---

# 11. REGRA DA SEGUNDA OU POSTERIOR ALOCAÇÃO

Quando o agente já estiver alocado no mesmo dia, o sistema não pode inferir a
natureza da nova jornada.

Deverá abrir decisão obrigatória:

```text
Como esta nova jornada deve ser classificada?

( ) Jornada normal
( ) Hora extra
( ) Banco de horas
```

Sem classificação:

```text
SALVAR = BLOQUEADO
```

O bloqueio não ocorre por o agente estar em dois turnos.

O bloqueio ocorre apenas porque o novo registro ficaria semanticamente
incompleto.

---

# 12. EVOLUÇÃO DO EscalaAlocacaoModel

Campos já existentes de identidade e vínculo deverão ser preservados.

Adicionar:

```text
tipoJornada
horaInicioReal
horaFimReal
minutosPrevistos
minutosRealizados
motivoJornadaComplementar
classificadoPor
classificadoEm
```

Interpretação na ESC-001D:

```text
horaInicio / horaFim
= planejamento

minutosPrevistos
= cálculo derivado do planejamento

horaInicioReal / horaFimReal
= preparados para ESC-001E

minutosRealizados
= preparado para ESC-001E
```

A ESC-001D NÃO deve apresentar `minutosPrevistos` ao usuário como “horas
trabalhadas”.

Terminologia correta na ESC-001D:

```text
horas programadas
```

Terminologia futura após execução:

```text
horas realizadas / trabalhadas
```

---

# 13. CÁLCULO DE HORAS

Criar serviço de domínio puro:

```text
EscalaHorasService
```

Responsabilidades:

```text
converter HH:mm para minutos
calcular duração
tratar virada de dia quando suportada
somar horas por agente
somar horas por natureza de jornada
somar horas da escala
```

Não deve acessar Firestore.

---

# 14. REGRA DE DURAÇÃO

Para um intervalo comum:

```text
06:00–12:00
= 360 minutos
= 6h
```

Para jornada complementar:

```text
18:00–22:00
= 240 minutos
= 4h
```

Os cálculos internos devem usar minutos inteiros.

A interface pode formatar:

```text
360 → 6h
390 → 6h30
```

Evitar `double` para armazenamento de horas.

---

# 15. SEM FINANCEIRO

Explicitamente fora da ESC-001D:

```text
valor da hora
valor da hora extra
remuneração individual
folha de pagamento
custo financeiro
```

Nenhum campo financeiro deve ser criado por antecipação.

---

# 16. BANCO DE HORAS

Na ESC-001D, `banco_horas` significa:

```text
jornada complementar
+
crédito operacional de horas
```

Nesta etapa, registrar:

```text
agente
atividade
data
horário
minutos programados
tipoJornada = banco_horas
motivo
classificadoPor
classificadoEm
```

O saldo contábil completo:

```text
créditos
débitos
saldo acumulado
compensações consumidas
```

fica fora da ESC-001D.

A modelagem deve, porém, impedir que as horas de banco sejam confundidas com
hora extra.

---

# 17. INDISPONIBILIDADES

Manter/normalizar códigos operacionais:

```text
ferias
compensacao
folga
outro
```

As indisponibilidades servem para explicar a situação do agente no dia.

Não bloqueiam a escala.

---

# 18. ALGORITMO DE CONFERÊNCIA DO EFETIVO

Criar serviço de domínio puro:

```text
EscalaConferenciaService
```

Entrada:

```text
perfis GEDUC ativos
membros operacionais ativos
alocações do dia
indisponibilidades do dia
```

Saída:

```text
totalEfetivo
totalExplicados
totalSemSituacao
agentesEmAtividade
agentesIndisponiveis
agentesSemSituacao
jornadasComplementares
alertas
```

---

# 19. REGRA DE AGENTE ÚNICO

A conferência deve usar:

```text
membroEquipeId
```

como identidade operacional.

Exemplo:

```text
João manhã
João noite
```

resultado:

```text
agentes únicos = 1
alocações = 2
```

Nunca:

```text
agentes = 2
```

---

# 20. REGRA DE COBERTURA

Exemplo:

```text
Efetivo GEDUC:           35

Em atividades:           28
Administrativo/Apoio:     2
Férias:                   3
Compensação:              2
Sem situação:             0
```

Resultado:

```text
Cobertura = 35/35
```

O agente pode possuir mais de uma alocação sem alterar o denominador.

---

# 21. AGENTE SEM SITUAÇÃO

Se:

```text
efetivo = 35
explicados únicos = 34
```

mostrar:

```text
⚠ 1 agente da GEDUC está sem situação definida.

[ Ver agente ]
```

Esse alerta NÃO bloqueia publicação.

---

# 22. SITUAÇÃO DUPLA

Exemplo:

```text
Agente em férias
+
alocado em atividade
```

Resultado:

```text
agente explicado = SIM
alerta de inconsistência = SIM
bloqueio = NÃO
```

O responsável/Gerente decide como proceder.

---

# 23. SOBREPOSIÇÃO

Criar serviço puro:

```text
EscalaConflitoService
```

Detectar:

```text
mesmo membroEquipeId
+
mesma data
+
intervalos sobrepostos
```

Resultado:

```text
ALERTA
```

Nunca bloqueio automático.

---

# 24. DIFERENÇA ENTRE SEGUNDA JORNADA E SOBREPOSIÇÃO

São regras distintas.

```text
SEGUNDA JORNADA
= agente possui outra alocação no mesmo dia
→ exige classificação da nova jornada

SOBREPOSIÇÃO
= horários se cruzam
→ gera alerta
```

Uma segunda jornada pode ser válida e não sobrepor.

Uma sobreposição também pode ser deliberadamente mantida.

---

# 25. RESUMO DE HORAS DA ESCALA

Na Gestão da Escala:

```text
EFETIVO GEDUC
35 agentes

COBERTURA
35/35

JORNADAS PROGRAMADAS

Normal:
30 agentes / XXh

Hora extra:
2 agentes / 7h

Banco de horas:
3 agentes / 11h
```

Os totais de agentes em jornada complementar usam pessoas únicas dentro de
cada categoria.

---

# 26. ARQUITETURA DE DADOS / ACESSO

Criar camada de dados específica:

```text
lib/modules/escala/data/
```

Sugestão:

```text
escala_repository.dart
firestore_escala_repository.dart
```

Responsabilidades do repositório:

```text
carregar configuração
carregar perfis operacionais
observar escala por data
carregar atividades
carregar alocações
carregar indisponibilidades
salvar rascunho
salvar atividade
salvar alocação
publicar
revisar
designar responsável
```

A UI não deve chamar `FirebaseFirestore.instance` diretamente.

---

# 27. SERVIÇOS DE DOMÍNIO

Criar:

```text
escala_conferencia_service.dart
escala_horas_service.dart
escala_conflito_service.dart
escala_publicacao_service.dart
```

Características:

```text
puros sempre que possível
determinísticos
testáveis sem Firebase
```

---

# 28. CONTROLLER / STATE

Criar:

```text
EscalaController
EscalaState
```

Estado mínimo:

```text
dataSelecionada
escala
atividades
alocacoes
indisponibilidades
perfisGeduc
membrosEquipe
conferencia
alertas
filtroMinhaEscala
filtroTurno
filtroSecao
filtroAgente
loading
saving
publishing
erro
```

---

# 29. RESPONSABILIDADE DO CONTROLLER

O Controller coordena:

```text
carregamento
filtros
criação de rascunho
edição de atividade
seleção de equipe
classificação de jornada
recalcular conferência
recalcular horas
recalcular alertas
publicação
revisão
```

Não colocar regra de negócio complexa dentro de widgets.

---

# 30. PROVIDER

Registrar `EscalaController` no padrão já usado pelo aplicativo.

A instância deverá ser acessível às páginas do módulo sem singleton de UI.

O controller poderá depender de:

```text
EscalaRepository
EquipeOperacionalService
AuthorizationService
```

---

# 31. TELA — ESCALA GEDUC

Arquivo sugerido:

```text
lib/modules/escala/pages/escala_page.dart
```

Responsabilidades:

```text
seleção de data
status/versão
Escala completa / Minha Escala
filtros
turnos
seções
cards de atividade
estado vazio
estado loading
estado erro
```

---

# 32. MINHA ESCALA

Não criar uma página duplicada.

Implementar:

```text
filtroMinhaEscala = true
```

Critério:

```text
atividade possui alocação cujo usuarioId == usuário autenticado
```

Se um membro legado não possuir `usuarioId`, ele não pode ser reconhecido como
“Minha Escala” de um usuário autenticado.

---

# 33. TELA — GESTÃO DA ESCALA

Arquivo sugerido:

```text
lib/modules/escala/pages/gestao_escala_page.dart
```

Exibir:

```text
data
status
versão
quantidade de atividades
quantidade de agentes únicos
cobertura do efetivo
horas programadas por natureza
alertas
```

Ações conforme autorização:

```text
Criar escala
Nova atividade
Editar
Revisar
Publicar
```

---

# 34. BOTÃO CRIAR ESCALA

Exibir somente quando:

```text
usuário = agente fixo responsável
+
não existe escala para a data
```

Gerente não recebe botão “Criar escala”.

Gerente pode abrir e gerenciar escala já existente.

---

# 35. DOCUMENTO DA ESCALA POR DATA

Adotar chave determinística sugerida:

```text
yyyy-MM-dd
```

Exemplo:

```text
escalas/2026-09-17
```

Benefícios:

```text
impede duplicidade por data
simplifica consulta
simplifica criação idempotente
```

Antes da implementação, validar compatibilidade com as Rules já existentes.

---

# 36. FORMULÁRIO DE ATIVIDADE

Componente sugerido:

```text
atividade_form_sheet.dart
```

Seções:

```text
natureza/tipo/título
turno/QTR/horário
QTH/Regional
orientação
Coordenador
equipe
```

Tablet/Web:

```text
painel lateral ou dialog largo
```

Celular:

```text
tela curta / modal fullscreen
```

---

# 37. SELEÇÃO DE EQUIPE

Componente:

```text
equipe_selector_sheet.dart
```

Cada item:

```text
nome
carga horária
setor
indicador de situação do dia
```

Exemplos:

```text
João
180H
Já alocado: manhã

Maria
240H
Férias
```

A existência de situação não desabilita o agente.

---

# 38. CLASSIFICAÇÃO DA JORNADA NA SELEÇÃO

Primeira alocação:

```text
Normal sugerido
```

Segunda/posterior:

```text
dialog obrigatório
```

A opção escolhida passa para `EscalaAlocacaoModel.tipoJornada`.

---

# 39. CARD DE ATIVIDADE

Widget sugerido:

```text
escala_atividade_card.dart
```

Exibir:

```text
título
natureza
turno
QTR
QTH
Coordenador
quantidade de agentes
status
```

Evitar excesso de detalhes no card.

---

# 40. VISUALIZAÇÃO RESPONSIVA

Criar widget de layout:

```text
escala_turnos_layout.dart
```

Regras:

```text
mobile
→ turnos empilhados

tablet/web
→ manhã/tarde/noite em colunas quando houver largura
```

A lógica não deve depender de plataforma.

Deve depender de largura disponível.

---

# 41. TELA — CONFIGURAÇÃO DA ESCALA

Arquivo sugerido:

```text
lib/modules/escala/pages/escala_configuracao_page.dart
```

Blocos:

```text
Responsável fixo
Equipe GEDUC
Carga horária dos integrantes
Ativo na escala
```

Não transformar a tela em cadastro geral de usuários.

---

# 42. DESIGNAÇÃO DO RESPONSÁVEL

A seleção deve aceitar somente:

```text
membro ativo
perfil da Escala ativo
perfil de acesso = agente
usuarioId canônico não vazio
```

Salvar:

```text
responsavelEscalaUsuarioId
responsavelEscalaMembroEquipeId
designadoPor
designadoEm
```

---

# 43. PUBLICAÇÃO

Criar fluxo:

```text
rascunho
→ revisar
→ calcular blockers
→ calcular alertas
→ confirmar
→ publicar
```

Publicação deve ser transacional sempre que múltiplos documentos precisarem
manter consistência.

---

# 44. BLOCKERS DE PUBLICAÇÃO

Inicialmente:

```text
atividade sem título
atividade sem tipo
atividade sem natureza
atividade sem data
alocação sem tipoJornada
ação educativa com geraRae=false
missão administrativa com geraRae=true
referência operacional inválida
```

---

# 45. ALERTAS DE PUBLICAÇÃO

Não bloqueiam:

```text
agente GEDUC sem situação
sobreposição
férias + alocação
folga + alocação
compensação + alocação
segunda jornada
hora extra sem execução ainda
banco de horas sem execução ainda
```

Antes da execução, ausência de horário real também não é blocker da
publicação.

---

# 46. REVISÃO / VERSIONAMENTO

Ao editar uma escala publicada:

```text
motivoRevisao obrigatório
versao = versao anterior + 1
atualizadoPor
atualizadoEm
```

Na republicação:

```text
publicadoPor
publicadoEm
```

Não sobrescrever silenciosamente o histórico lógico.

---

# 47. HISTÓRICO COMPLETO

A ESC-001D não criará ainda uma coleção de snapshots de versão, salvo se a
auditoria técnica demonstrar necessidade imediata.

MVP:

```text
versão atual
motivo da revisão
auditoria de autor/data
```

Snapshot histórico completo pode ser uma evolução posterior.

---

# 48. ROUTES

Adicionar rotas protegidas:

```text
/escala
/escala/gestao
/escala/configuracao
```

Sugestão:

```text
AppRoutes.escalaPath
AppRoutes.gestaoEscalaPath
AppRoutes.configuracaoEscalaPath
```

A proteção deve usar política específica de Escala.

Não reutilizar permissões de RAE para liberar o módulo.

---

# 49. ROUTE GUARD DA ESCALA

Criar adaptador/guard que consulte:

```text
usuário atual
perfil
configuração do responsável
EscalaPermission
```

Leitura:

```text
todos os perfis reconhecidos da Escala
```

Gestão:

```text
agente responsável
Gerente
```

Configuração:

```text
Gerente
Administrador
```

---

# 50. HOME

Adicionar no Home:

```text
Escala GEDUC
```

para todos os perfis ativos reconhecidos.

Adicionar:

```text
Gestão da Escala
```

somente quando houver autorização.

“Minha Escala” poderá ser:

```text
atalho próprio que abre /escala?minha=1
```

sem criar nova página.

---

# 51. FIRESTORE RULES — EVOLUÇÃO

Atualizar Rules para:

```text
separar create de update
validar tipoJornada
validar campos de classificação
validar minutos previstos
preservar delete = false
preservar leitura geral para perfis ativos da Escala
```

Não adicionar `gerente` ao ACL global legado.

---

# 52. FIRESTORE — TIPO DE JORNADA

Valores aceitos:

```text
normal
hora_extra
banco_horas
```

Regra:

```text
tipoJornada obrigatório
```

Para `hora_extra` e `banco_horas`:

```text
motivoJornadaComplementar não vazio
classificadoPor não vazio
classificadoEm válido
```

---

# 53. MINUTOS PREVISTOS

Firestore deve aceitar inteiro:

```text
>= 0
<= 1440
```

Se a estratégia permitir jornada atravessando meia-noite, a validação será
adequada sem permitir intervalos absurdos.

O cálculo principal permanece no cliente/domínio.

---

# 54. HORAS REAIS

Campos:

```text
horaInicioReal
horaFimReal
minutosRealizados
```

devem existir no contrato de dados, porém podem permanecer nulos/vazios na
ESC-001D.

A ESC-001E será responsável por preenchê-los durante execução.

---

# 55. DENORMALIZAÇÃO CONTROLADA

`EscalaAtividadeModel.participanteUsuarioIds` deve continuar sincronizado com
as alocações da atividade.

Ao adicionar/remover uma alocação com `usuarioId` canônico:

```text
recalcular participanteUsuarioIds
```

A operação deve ser realizada pelo serviço/repositório, não pelo widget.

---

# 56. CONSISTÊNCIA DE ESCRITA

Operações que alteram:

```text
atividade
+
alocações
+
participanteUsuarioIds
```

devem usar:

```text
WriteBatch
ou Transaction
```

quando necessário.

Evitar estado parcial.

---

# 57. CONSULTA DA ESCALA

Consulta por data deverá carregar:

```text
escala
atividades da escala
alocações
indisponibilidades
```

A ordenação visual pode ser executada no domínio:

```text
turno
horário
seção
título
```

Não criar índice composto sem necessidade real comprovada.

---

# 58. ESTADOS VAZIOS

## Sem escala

```text
Nenhuma escala encontrada para esta data.
```

Responsável:

```text
[ Criar escala ]
```

Demais usuários:

```text
A escala ainda não foi publicada/criada.
```

---

# 59. ESTADO RASCUNHO PARA AGENTE COMUM

Agente comum não deve acessar um rascunho operacional ainda não publicado,
salvo se a regra de produto for explicitamente ampliada depois.

Consulta geral do agente deve priorizar escala publicada.

Gestores autorizados podem visualizar o rascunho no fluxo de gestão.

---

# 60. TESTES DE DOMÍNIO — CONFERÊNCIA

Criar casos:

```text
35/35 todos explicados
34/35 gera 1 sem situação
agente com duas alocações conta 1
agente em férias conta explicado
agente compensando conta explicado
agente com férias + alocação gera alerta
inativo não entra no denominador
membro fora da GEDUC não entra no denominador
```

---

# 61. TESTES DE DOMÍNIO — JORNADA

Casos:

```text
primeira alocação normal
segunda exige classificação
normal + hora extra
normal + banco de horas
duas normais explicitamente aceitas
hora extra sem motivo inválida
banco sem motivo inválido
```

---

# 62. TESTES DE DOMÍNIO — HORAS

Casos:

```text
06:00–12:00 = 360
18:00–22:00 = 240
somatório por agente
somatório normal
somatório hora_extra
somatório banco_horas
formatação 390 = 6h30
```

---

# 63. TESTES DE DOMÍNIO — CONFLITO

Casos:

```text
06:00–12:00 x 12:00–18:00 = sem sobreposição
06:00–12:00 x 11:00–13:00 = sobreposição
mesmo horário agentes diferentes = sem conflito individual
mesmo agente em atividade sobreposta = alerta
```

---

# 64. TESTES DE ACESSO DART

Validar:

```text
agente comum lê
agente comum não gerencia
agente responsável cria
Gerente NÃO cria nova escala
Gerente edita existente
Gerente revisa
Gerente publica
Gerente designa responsável
Coordenador não gerencia
Administrador configura
```

---

# 65. TESTES FIRESTORE RULES

Espelhar a matriz Dart:

```text
responsável cria rascunho
Gerente create = DENY
Gerente update = ALLOW
agente comum create/update = DENY
todos perfis ativos reconhecidos leem
tipoJornada desconhecido = DENY
hora_extra sem motivo = DENY
banco_horas sem motivo = DENY
delete = DENY
```

Preservar todos os testes legados.

---

# 66. TESTES DE WIDGET

Cobrir no mínimo:

```text
Escala completa
Minha Escala
layout mobile
layout tablet
card de atividade
estado sem escala
alerta de agente sem situação
diálogo de segunda jornada
resumo de horas
```

---

# 67. TESTE FUNCIONAL COM CENÁRIO 35 AGENTES

Fixture de homologação:

```text
Equipe GEDUC = 35

3 férias
2 compensação
30 disponíveis
```

Cenário A:

```text
30 agentes únicos alocados
+ 3 férias
+ 2 compensação
= 35/35
```

Esperado:

```text
sem alerta de ausência
```

Cenário B:

```text
29 agentes únicos alocados
+ 3 férias
+ 2 compensação
= 34/35
```

Mesmo com um dos 29 tendo duas alocações.

Esperado:

```text
1 agente sem situação
```

---

# 68. TESTE FUNCIONAL DE HORA EXTRA

```text
João
06:00–12:00 normal
18:00–22:00 hora_extra
```

Esperado:

```text
1 agente único
2 alocações
6h normal
4h hora extra
10h programadas
```

---

# 69. TESTE FUNCIONAL DE BANCO DE HORAS

```text
Maria
12:00–18:00 normal
18:00–22:00 banco_horas
```

Esperado:

```text
1 agente único
2 alocações
6h normal
4h banco de horas
10h programadas
```

---

# 70. TESTE DE ALERTA DE SOBREPOSIÇÃO

```text
João
06:00–12:00
11:00–14:00
```

Esperado:

```text
alerta
publicação permitida após ciência
```

---

# 71. TESTE DE FÉRIAS COM ALOCAÇÃO

```text
João
situação = férias
atividade = manhã
```

Esperado:

```text
alerta
não bloquear
```

---

# 72. HOMOLOGAÇÃO DE PUBLICAÇÃO

Antes do botão Publicar confirmar:

```text
efetivo
cobertura
atividades
agentes únicos
jornadas normais
horas extras
banco de horas
alertas
blockers
```

Publicar somente quando:

```text
blockers = 0
```

Alertas podem ser maiores que zero.

---

# 73. HOMOLOGAÇÃO DE REVISÃO

Escala publicada:

```text
versao = 1
```

Editar:

```text
motivo obrigatório
```

Republicar:

```text
versao = 2
```

A UI deve deixar explícito que houve revisão.

---

# 74. ARQUIVOS NOVOS — CANDIDATOS

Estrutura proposta:

```text
lib/modules/escala/
  controllers/
    escala_controller.dart
    escala_state.dart

  data/
    escala_repository.dart
    firestore_escala_repository.dart

  services/
    escala_conferencia_service.dart
    escala_horas_service.dart
    escala_conflito_service.dart
    escala_publicacao_service.dart

  pages/
    escala_page.dart
    gestao_escala_page.dart
    escala_configuracao_page.dart

  widgets/
    escala_header.dart
    escala_turnos_layout.dart
    escala_atividade_card.dart
    escala_filtros.dart
    escala_resumo_efetivo.dart
    escala_resumo_horas.dart
    atividade_form_sheet.dart
    equipe_selector_sheet.dart
    jornada_classificacao_dialog.dart
    escala_alertas_panel.dart
```

A implementação final pode consolidar widgets pequenos para evitar fragmentação
excessiva.

---

# 75. ARQUIVOS EXISTENTES — ALTERAÇÕES PROVÁVEIS

```text
lib/modules/escala/models/escala_models.dart
lib/modules/escala/security/escala_permission.dart
lib/modules/escala/security/escala_access_policy.dart
lib/core/routes/app_routes.dart
lib/modules/home/widgets/atalhos_widget.dart
lib/app.dart
firestore.rules
package.json
```

E testes correspondentes.

---

# 76. EVITAR SOBREENGENHARIA

Não criar nesta etapa:

```text
BLoC adicional se Provider já atende
Event Bus
microservices
Cloud Functions para regra que pode ser transacional no cliente
sistema financeiro
motor genérico de escalas de toda a instituição
saldo contábil completo de banco de horas
```

O módulo é GEDUC-first.

---

# 77. FASEAMENTO DA IMPLEMENTAÇÃO

## ESC-001D.1 — Segurança e contratos

```text
corrigir GAP criação
tipoJornada
campos de horas/classificação
Rules
testes de segurança/modelo
```

Gate:

```text
focused tests
Firestore Rules
flutter analyze
```

---

# 78. ESC-001D.2 — Equipe GEDUC e conferência

```text
cadastro operacional GEDUC
carregamento do efetivo
EscalaConferenciaService
EscalaHorasService
EscalaConflitoService
fixtures 35 agentes
```

Gate:

```text
unit tests completos
```

---

# 79. ESC-001D.3 — Consulta

```text
Escala GEDUC
turnos
cards
filtros
Minha Escala
responsividade
```

Gate:

```text
widget tests
homologação visual
```

---

# 80. ESC-001D.4 — Gestão

```text
criar rascunho
atividade
equipe
classificação de jornada
alertas
resumo efetivo
resumo horas
```

Gate:

```text
functional/widget tests
```

---

# 81. ESC-001D.5 — Publicação e revisão

```text
blockers
alertas
publicação
versão
motivo de revisão
republicação
```

Gate:

```text
integration/domain tests
Firestore Rules
```

---

# 82. ESC-001D.6 — Configuração e Home

```text
responsável fixo
Equipe GEDUC
rotas
guards
atalhos Home
```

Gate:

```text
route/access tests
```

---

# 83. ESC-001D.7 — Fechamento integral

Executar:

```text
dart format
flutter pub get
flutter test focado
flutter test completo
flutter analyze
npm ci
npm run test:rules
git diff --check
escopo exato
```

Depois:

```text
CPB
commit
push
PR
6 Quality Gates
merge
sync main
cleanup
```

---

# 84. CRITÉRIOS DE HOMOLOGAÇÃO FUNCIONAL

A ESC-001D só poderá ser considerada fechada quando:

```text
[ ] Cadastro GEDUC representa o efetivo ativo.
[ ] 35 agentes podem ser conferidos por pessoa única.
[ ] Férias explicam agente sem contar como atividade.
[ ] Compensação explica agente sem contar como atividade.
[ ] Agente com duas alocações continua contando uma pessoa.
[ ] Segunda jornada exige classificação.
[ ] Hora extra é separada de banco de horas.
[ ] Horas programadas são calculadas corretamente.
[ ] Nenhum valor financeiro existe.
[ ] Agente sem situação gera alerta.
[ ] Sobreposição gera alerta e não bloqueia.
[ ] Indisponibilidade + alocação gera alerta e não bloqueia.
[ ] Minha Escala é filtro da Escala GEDUC.
[ ] Responsável cria escala.
[ ] Gerente não cria escala nova.
[ ] Gerente pode alterar/revisar/publicar escala existente.
[ ] Publicação exige zero blocker.
[ ] Revisão incrementa versão.
[ ] Mobile/tablet/web permanecem utilizáveis.
[ ] Flutter Test = PASS.
[ ] Flutter Analyze = 0 issues.
[ ] Firestore Rules = PASS.
[ ] 6 GitHub Quality Gates = PASS.
```

---

# 85. FORA DO ESCOPO DA ESC-001D

Continuam para etapas seguintes:

## ESC-001E

```text
execução detalhada
hora de início/fim real
minutos realizados
evidências administrativas
conclusão operacional
```

## ESC-001F

```text
Escala → RAE
```

## ESC-001G

```text
PDF oficial da Escala GEDUC
```

## ESC-001H

```text
indicadores históricos
saldo consolidado de banco de horas
análise de produtividade
Faixita
```

Sem componente financeiro até decisão futura específica.

---

# 86. REGRA DE VERDADE DAS HORAS

Este ponto é obrigatório:

```text
ESC-001D
→ horas PROGRAMADAS

ESC-001E
→ horas REALIZADAS/TRABALHADAS
```

O sistema não deve chamar uma hora prevista de “hora trabalhada”.

Essa separação evita indicador falso.

---

# 87. DECISÃO DE IMPLEMENTAÇÃO RECOMENDADA

A ESC-001D deve ser implementada em pacotes internos sequenciais:

```text
D.1 segurança/modelo
D.2 efetivo/conferência
D.3 consulta
D.4 gestão
D.5 publicação
D.6 configuração/integração
D.7 fechamento
```

Cada pacote deve manter a branch funcional, com testes específicos.

O fechamento final será único e integral.

---

# 88. CRITÉRIO DE SUCESSO OPERACIONAL

Ao selecionar uma data, a chefia deverá conseguir responder em poucos segundos:

```text
Quantos agentes compõem a GEDUC hoje?
Todos estão explicados?
Quem está trabalhando?
Quem está de férias?
Quem está compensando?
Quem ficou sem situação?
Quem está em mais de uma jornada?
Qual segunda jornada é hora extra?
Qual segunda jornada gera banco de horas?
Quantas horas estão programadas em cada natureza?
Quais conflitos precisam apenas de decisão operacional?
A escala já foi publicada?
Qual versão está vigente?
```

Se a tela não responder essas perguntas com clareza, a implementação ainda não
está homologada.

---

# 89. CONCLUSÃO

A ESC-001D não será apenas um editor de escala.

Ela será a primeira camada operacional do Fênix capaz de conciliar:

```text
PESSOAS
+
SITUAÇÃO DO DIA
+
ALOCAÇÕES
+
JORNADAS
+
HORAS
+
ALERTAS
+
PUBLICAÇÃO
```

sem confundir quantidade de pessoas com quantidade de alocações e sem misturar
controle operacional de horas com financeiro.
