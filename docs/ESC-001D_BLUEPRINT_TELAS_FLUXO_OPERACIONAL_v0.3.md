# PLATAFORMA FÊNIX
# ESC-001D — BLUEPRINT DE TELAS E FLUXO OPERACIONAL v0.3
## Módulo Escala GEDUC

**Baseline técnica:** `603b891c6c3adfb37543122058c7e23a6dc93766`
**Estado anterior:** ESC-001B homologada / ESC-001C fechada
**Status deste documento:** PROPOSTA PARA HOMOLOGAÇÃO FUNCIONAL — R3
**Escopo:** UX, telas, navegação, ações por perfil e fluxo operacional
**Fora do escopo:** implementação Flutter, rotas definitivas, serviços, repositórios e deploy

---

# 1. OBJETIVO

Criar uma experiência simples para que a GEDUC consiga:

1. consultar a escala completa do dia;
2. identificar rapidamente onde cada agente está escalado;
3. criar e alterar a escala com poucos passos;
4. publicar e revisar a escala;
5. permitir que Coordenador e agentes registrem a execução das missões;
6. manter ações educativas ligadas ao fluxo de RAE;
7. registrar missões administrativas como produtividade da equipe;
8. apresentar alertas sem bloquear a decisão operacional.

O módulo não deve tentar reproduzir literalmente o PDF como formulário.

O PDF atual deve servir como referência visual e operacional, enquanto o
Fênix trabalha com dados estruturados.

---

# 2. PRINCÍPIO DE UX

## Regra principal

```text
CONSULTAR deve ser fácil.
EDITAR deve ser restrito.
EXECUTAR deve ser direto.
PUBLICAR deve ser consciente.
```

## Evitar

- muitas telas;
- formulários longos;
- campos técnicos visíveis ao usuário;
- navegação excessiva;
- obrigar o agente a entrar em "Minha Escala" para entender o dia;
- bloqueios automáticos por férias, folga, compensação ou sobreposição;
- transformar missão administrativa em RAE.

---

# 3. ARQUITETURA DE TELAS

O MVP terá quatro experiências principais:

```text
HOME
 ├── ESCALA GEDUC
 │      ├── Escala completa
 │      └── Minha Escala
 │
 ├── GESTÃO DA ESCALA
 │      ├── criar
 │      ├── editar
 │      ├── revisar
 │      └── publicar
 │
 ├── EXECUÇÃO DA MISSÃO
 │      ├── ação educativa
 │      └── missão administrativa
 │
 └── CONFIGURAÇÃO DA ESCALA
        └── responsável fixo
```

A tela "Minha Escala" não precisa ser uma tela independente.

Ela pode ser um filtro dentro da própria tela Escala GEDUC.

---

# 4. TELA 01 — HOME / ATALHOS

## Objetivo

Oferecer entrada rápida para o módulo.

## Atalhos

### Escala GEDUC

Visível para todos os perfis ativos da Escala.

Abre:

```text
Escala GEDUC
data = hoje
modo = escala completa
```

### Minha Escala

Pode existir como atalho adicional.

Abre a MESMA tela:

```text
Escala GEDUC
data = hoje
filtro = somente minhas atividades
```

### Gestão da Escala

Visível apenas para:

```text
Agente responsável pela escala
Gerente
Administrador
```

### Configuração da Escala

Visível para:

```text
Gerente
Administrador
```

---

# 5. TELA 02 — ESCALA GEDUC

## Objetivo

Ser a tela principal do módulo.

Todo agente deve conseguir abrir e entender a escala do dia rapidamente.

## Cabeçalho

```text
ESCALA GEDUC

<  17 SET 2026  >

[ Escala completa ] [ Minha Escala ]

Status: PUBLICADA
Versão: 2
```

## Informações institucionais de cabeçalho

Podem ser exibidas de forma compacta:

```text
MANHÃ
180H (...)
240H (...)

TARDE
180H (...)
240H (...)

NOITE
180H (...)
240H (...)
```

Esses horários são INFORMATIVOS.

Não comandam a validação da escala.

---

# 6. ORGANIZAÇÃO VISUAL DA ESCALA

## Tablet / desktop

Preferência:

```text
┌────────────────┬────────────────┬────────────────┐
│     MANHÃ      │     TARDE      │     NOITE      │
│                │                │                │
│ atividades     │ atividades     │ atividades     │
│                │                │                │
└────────────────┴────────────────┴────────────────┘
```

## Celular

Empilhamento:

```text
MANHÃ
  atividades

TARDE
  atividades

NOITE
  atividades
```

Ou accordion:

```text
▼ MANHÃ
▶ TARDE
▶ NOITE
```

---

# 7. CARD DE ATIVIDADE

Cada atividade será apresentada como card.

## Exemplo — ação educativa

```text
┌────────────────────────────────────┐
│ MOTOCICLISTA SEGURO                │
│ Ação Educativa                     │
│                                    │
│ QTR  06:00                         │
│ QTH  Av. Tenente Benévolo x ...    │
│                                    │
│ Coordenador: Heberfran             │
│ Equipe: 7 agentes                  │
│                                    │
│ [ Ver detalhes ]                   │
└────────────────────────────────────┘
```

## Exemplo — missão administrativa

```text
┌────────────────────────────────────┐
│ INTELIGÊNCIA E TRATAMENTO DE DADOS │
│ Missão Administrativa              │
│                                    │
│ Responsável: Agente X              │
│ Equipe: 2 agentes                  │
│                                    │
│ Status: EM EXECUÇÃO                │
│                                    │
│ [ Ver / Registrar execução ]       │
└────────────────────────────────────┘
```

---

# 8. SEÇÕES DA ESCALA

A escala não deve depender apenas de manhã/tarde/noite.

Ela também pode manter categorias funcionais.

Primeira matriz:

```text
ADMINISTRATIVO

COMANDOS E AÇÕES TEMÁTICAS

PROGRAMAS DE FORMAÇÃO E CAPACITAÇÃO

APOIO GEDUC

COMPENSAÇÕES / FÉRIAS / FOLGAS
```

O turno organiza o tempo.

A seção organiza a natureza visual/funcional da escala.

---

# 9. TELA 03 — DETALHE DA ATIVIDADE

Ao tocar no card:

```text
MOTOCICLISTA SEGURO

Natureza:
Ação Educativa

Data:
17/09/2026

QTR:
06:00

QTH:
Av. Tenente Benévolo x Rua Gonçalves Ledo

Regional:
Regional 12

Orientação:
Montar dispositivo de abordagem educativa...

Coordenador:
Heberfran

Equipe:
Sales
Samoel
João Vitor
Elino José
Alberto
Romario

Status:
PUBLICADA
```

## Ações conforme perfil

Agente comum:

```text
visualizar
```

Agente participante:

```text
visualizar
registrar execução administrativa quando aplicável
```

Coordenador:

```text
visualizar
registrar execução
registrar observações
anexar evidências
concluir missão quando aplicável
```

Agente responsável / Gerente:

```text
visualizar
editar escala
```

---

# 10. TELA 04 — GESTÃO DA ESCALA

## Objetivo

Centralizar planejamento e edição.

Não abrir diretamente um formulário gigante.

## Entrada

```text
GESTÃO DA ESCALA

Data: 17/09/2026

Status:
RASCUNHO

Atividades:
8

Agentes escalados:
23

Alertas:
2
```

## Ações

```text
[ + Nova atividade ]

[ Ver escala ]

[ Revisar alertas ]

[ Publicar ]
```

---

# 11. CRIAÇÃO DE UMA NOVA ESCALA

Fluxo:

```text
Gestão da Escala
      ↓
Selecionar data
      ↓
Criar escala
      ↓
RASCUNHO
      ↓
Adicionar atividades
      ↓
Adicionar agentes
      ↓
Revisar
      ↓
Publicar
```

## Regra

Uma escala nasce em:

```text
RASCUNHO
```

Nunca nasce publicada.

---

# 12. TELA 05 — FORMULÁRIO DE ATIVIDADE

O formulário deve ser curto e progressivo.

## BLOCO A — O que será feito?

```text
Natureza
( ) Ação Educativa
( ) Missão Administrativa

Tipo da atividade
[ selecionar ]

Título
[________________________]
```

A natureza poderá ser derivada do tipo da atividade no futuro.

---

# 13. BLOCO B — QUANDO?

```text
Turno
[ Manhã ▼ ]

QTR
[ 06:00 ]

Horário da atividade
Início [ 07:00 ]
Fim    [ 11:00 ]
```

QTR permanece separado do intervalo operacional.

---

# 14. BLOCO C — ONDE?

```text
QTH
[ Av. Tenente Benévolo x Rua... ]

Regional
[ Regional 12 ▼ ]

Ponto de referência
[ opcional ]

Endereço complementar
[ opcional ]
```

Mapa/geolocalização podem ser acrescentados depois.

Não precisam ser obrigatórios no MVP da Escala.

---

# 15. BLOCO D — ORIENTAÇÃO OPERACIONAL

```text
Orientação / Missão

[________________________________]
[________________________________]
[________________________________]
```

Campo textual simples.

---

# 16. BLOCO E — COORDENAÇÃO

```text
Coordenador

[ selecionar da Equipe Operacional ▼ ]
```

Mostrar preferencialmente membros:

```text
ativo = true
podeCoordenar = true
```

---

# 17. BLOCO F — EQUIPE

Não usar um campo de texto para nomes.

Usar seleção estruturada da Equipe Operacional.

```text
Equipe

☑ Agente A
☑ Agente B
☐ Agente C
☑ Agente D
```

## Informações úteis na seleção

```text
Agente A
180H
GEDUC
```

Carga horária é informativa.

---

# 18. ALERTA DE SOBREPOSIÇÃO

Se um agente já estiver em outra atividade no mesmo período:

```text
⚠ Agente A já aparece em outra atividade neste horário.
```

Ações:

```text
[ Ver conflito ]
[ Manter mesmo assim ]
```

Nunca:

```text
Você não pode continuar.
```

---

# 19. ALERTA DE FÉRIAS / FOLGA / COMPENSAÇÃO

Exemplo:

```text
⚠ Agente B possui registro de férias nesta data.
```

Ações:

```text
[ Ver registro ]
[ Manter na atividade ]
```

Também não bloqueia.

---

# 20. SALVAMENTO DA ATIVIDADE

Rodapé:

```text
[ Cancelar ]       [ Salvar atividade ]
```

Não publicar individualmente.

A publicação pertence à escala do dia.

---

# 21. EDIÇÃO DA EQUIPE

Na atividade:

```text
Equipe atual: 7 agentes

[ + Adicionar ]
[ Gerenciar equipe ]
```

A seleção abre modal/bottom sheet.

Evitar navegar para uma nova página sempre que possível.

---

# 22. REVISÃO DA ESCALA

Antes de publicar:

```text
REVISÃO DA ESCALA

17/09/2026

8 atividades
23 agentes
3 ações educativas
5 missões administrativas

ALERTAS
⚠ 1 sobreposição
⚠ 1 agente em férias

ERROS
✓ nenhum
```

## Regra

Erro estrutural:

```text
BLOQUEIA
```

Alerta operacional:

```text
NÃO BLOQUEIA
```

---

# 23. ERROS QUE BLOQUEIAM

Somente problemas que tornam o dado inválido.

Exemplos:

```text
atividade sem data
atividade sem título
atividade sem tipo
atividade educativa com geraRae=false
referência estrutural inválida
```

---

# 24. ALERTAS QUE NÃO BLOQUEIAM

```text
sobreposição de agente

férias

folga

compensação

atividade administrativa sem evidência

atividade educativa ainda sem RAE
```

Os dois últimos dependem da fase da execução.

---

# 25. PUBLICAÇÃO

Modal:

```text
PUBLICAR ESCALA?

Data:
17/09/2026

Atividades:
8

Alertas:
2

A escala ficará disponível para toda a equipe.

[ Cancelar ]    [ Publicar ]
```

Ao confirmar:

```text
status = publicada
publicadoPor
publicadoEm
versao
```

---

# 26. ESCALA PUBLICADA

Depois da publicação:

```text
ESCALA GEDUC
17/09/2026

PUBLICADA
Versão 1
```

Todos os agentes ativos passam a visualizar a mesma escala.

---

# 27. REVISÃO DE ESCALA PUBLICADA

Agente responsável ou Gerente abre:

```text
[ Revisar escala ]
```

Ao alterar uma escala publicada:

```text
motivo da revisão
[________________________]
```

Ao republicar:

```text
versão 1
     ↓
versão 2
```

Nunca sobrescrever silenciosamente.

---

# 28. FLUXO DO AGENTE RESPONSÁVEL

```text
HOME
 ↓
Gestão da Escala
 ↓
seleciona data
 ↓
cria rascunho
 ↓
adiciona atividades
 ↓
monta equipes
 ↓
visualiza alertas
 ↓
corrige ou mantém
 ↓
publica
```

Ele também pode:

```text
revisar
alterar
republicar
```

---

# 29. FLUXO DO GERENTE

```text
HOME
 ↓
Gestão da Escala
 ↓
revisa planejamento
 ↓
altera se necessário
 ↓
publica / republica
```

Também pode:

```text
Configuração da Escala
 ↓
designar agente responsável
```

---

# 30. FLUXO DO AGENTE COMUM

```text
HOME
 ↓
Escala GEDUC
 ↓
visualiza escala completa
```

Opcionalmente:

```text
[ Minha Escala ]
```

Filtra somente atividades onde aparece.

---

# 31. FLUXO DO COORDENADOR

```text
HOME
 ↓
Escala GEDUC
 ↓
abre atividade coordenada
 ↓
Execução da Missão
```

O Coordenador não entra no fluxo de Gestão da Escala.

---

# 32. TELA 06 — EXECUÇÃO DA MISSÃO

## Cabeçalho

```text
INTELIGÊNCIA E TRATAMENTO DE DADOS

Missão Administrativa

Data:
17/09/2026

Equipe:
3 agentes
```

## Corpo

```text
Status

( ) Em execução
( ) Concluída
( ) Cancelada
```

## Resultado

```text
Resultado / Entrega

[________________________________]
[________________________________]
```

## Observação

```text
[ opcional ]
```

## Evidências

```text
[ + Adicionar evidência ]
```

---

# 33. EVIDÊNCIAS DA MISSÃO ADMINISTRATIVA

Tipos previstos:

```text
foto
documento
arquivo
link
observação
outro
```

No blueprint, evidência é conceito funcional.

O armazenamento físico continua dependente da infraestrutura de evidências
homologada no Fênix.

---

# 34. QUEM PODE REGISTRAR EXECUÇÃO ADMINISTRATIVA

```text
Agente participante
Coordenador da atividade
```

O agente registra a própria execução.

O Coordenador registra execução da missão que coordena.

---

# 35. AÇÃO EDUCATIVA E RAE

No detalhe da ação educativa:

```text
RAE

Status:
Ainda não vinculado
```

Futuro ESC-001F:

```text
[ Criar RAE a partir desta atividade ]
```

ou:

```text
RAE 2026-XXXX
[ Abrir RAE ]
```

Na ESC-001D deve existir apenas o ponto de integração no desenho.

Não implementar ainda a automação Escala → RAE.

---

# 36. MISSÃO ADMINISTRATIVA E PRODUTIVIDADE

Depois de concluída:

```text
✓ Missão concluída

Resultado:
Dados consolidados do período.

Evidências:
2
```

Essa execução será a base futura para os indicadores de produtividade.

---

# 37. TELA 07 — CONFIGURAÇÃO DA ESCALA

Acesso:

```text
Gerente
Administrador
```

Conteúdo simples:

```text
RESPONSÁVEL PELA ESCALA

Atual:
Agente XXXXX

[ Alterar responsável ]
```

Ao alterar:

```text
Novo responsável
[ selecionar agente ▼ ]

[ Cancelar ] [ Confirmar ]
```

Registrar auditoria:

```text
responsável anterior
responsável novo
alterado por
alterado em
```

---

# 38. PERFIL OPERACIONAL DO AGENTE

Não precisa ser uma grande tela no MVP.

Pode aparecer dentro da configuração administrativa.

Exemplo:

```text
Agente XXXXX

Setor:
GEDUC

Carga horária:
180H

Ativo na escala:
SIM
```

Não criar cadastro paralelo de pessoa.

A origem continua sendo a Equipe Operacional.

---

# 39. FILTROS DA ESCALA

Filtros úteis, mas poucos:

```text
[ Todos os turnos ▼ ]
[ Todas as seções ▼ ]
[ Todos os agentes ▼ ]
```

Botão:

```text
Limpar filtros
```

Evitar dezenas de filtros no MVP.

---

# 40. BUSCA

Busca simples:

```text
Buscar agente, atividade ou local
[____________________________]
```

Exemplos:

```text
Sales
Motociclista
UNICHRISTUS
```

---

# 41. ESTADOS VISUAIS IMPORTANTES

## Escala

```text
RASCUNHO
PUBLICADA
ARQUIVADA
```

## Atividade

```text
PLANEJADA
PUBLICADA
EM EXECUÇÃO
CONCLUÍDA
CANCELADA
```

## Alertas

```text
ERRO
ALERTA
INFORMAÇÃO
```

---

# 42. RESPONSIVIDADE

## Celular

Prioridade:

```text
leitura rápida
cards empilhados
bottom sheets
botões grandes
```

## Tablet

Prioridade:

```text
três turnos visíveis
gestão confortável
edição em cards
```

## Desktop/Web

Prioridade:

```text
visão completa
painel lateral
edição rápida
```

---

# 43. USO DA ESCALA DE 16/09/2026 COMO CENÁRIO DE HOMOLOGAÇÃO

A primeira homologação funcional da interface deve conseguir representar:

```text
Administrativo

Manhã
Tarde
Noite

Comandos e Ações Temáticas

Programas de Formação e Capacitação

Apoio GEDUC

Compensações e Férias
```

E deve conseguir representar simultaneamente:

```text
ação educativa
missão administrativa
coordenador
equipe
QTR
QTH
Regional
orientação operacional
férias / compensação
```

---

# 44. HOMOLOGAÇÃO VISUAL MÍNIMA

## H01

Abrir Escala GEDUC no dia 16/09/2026.

## H02

Visualizar Manhã, Tarde e Noite.

## H03

Localizar uma ação educativa.

## H04

Ver QTR e QTH corretamente.

## H05

Abrir equipe da ação.

## H06

Alternar para Minha Escala.

## H07

Criar atividade em rascunho.

## H08

Adicionar agente.

## H09

Receber alerta de sobreposição.

## H10

Receber alerta de férias sem bloqueio.

## H11

Publicar escala.

## H12

Revisar escala publicada gerando nova versão.

## H13

Coordenador registrar execução sem editar escala.

## H14

Agente registrar missão administrativa própria.

## H15

Anexar metadado de evidência à missão administrativa.

---

# 45. ESCOPO RECOMENDADO DA IMPLEMENTAÇÃO ESC-001D

Para evitar uma entrega grande demais, a implementação da ESC-001D deve focar
em gestão e consulta.

## Entram em ESC-001D

```text
Escala GEDUC
Minha Escala como filtro
Gestão da Escala
criar escala
editar escala
atividade
equipe
alertas
publicação
revisão/versionamento
configuração do responsável
```

## Ficam para ESC-001E

```text
Execução operacional detalhada
registro de missão administrativa
evidências administrativas
```

## Ficam para ESC-001F

```text
Escala → RAE
```

## Ficam para ESC-001G

```text
PDF oficial da Escala GEDUC
```

## Ficam para ESC-001H

```text
indicadores
produtividade
Faixita
```

---

# 46. FLUXO OPERACIONAL CONSOLIDADO

```text
EQUIPE OPERACIONAL
        ↓
CONFIGURAÇÃO DA ESCALA
        ↓
RESPONSÁVEL FIXO
        ↓
GESTÃO DA ESCALA
        ↓
RASCUNHO
        ↓
ATIVIDADES
        ↓
EQUIPES
        ↓
ALERTAS
        ↓
REVISÃO
        ↓
PUBLICAÇÃO
        ↓
ESCALA GEDUC
        ↓
EXECUÇÃO
   ┌───────────────┴────────────────┐
   ↓                                ↓
AÇÃO EDUCATIVA               MISSÃO ADMINISTRATIVA
   ↓                                ↓
RAE FUTURO                   REGISTRO DE EXECUÇÃO
   ↓                                ↓
INDICADORES EDUCATIVOS       PRODUTIVIDADE ADMIN.
   └───────────────┬────────────────┘
                   ↓
            INDICADORES GEDUC
                   ↓
                FAIXITA
```

---

# 47. DECISÕES DE UX PROPOSTAS PARA HOMOLOGAÇÃO

## P1 — Uma única tela de consulta

Proposta:

```text
Escala GEDUC
+
filtro "Minha Escala"
```

em vez de duas telas independentes.

## P2 — Gestão separada da consulta

Proposta:

```text
Escala GEDUC = leitura
Gestão da Escala = criação/edição/publicação
```

## P3 — Edição de atividade em painel/modal

Proposta:

Evitar uma página longa.

No tablet/web:

```text
painel lateral
```

No celular:

```text
bottom sheet / tela curta
```

## P4 — Publicação única da escala

Proposta:

Atividades são salvas em rascunho.

A publicação ocorre na escala do dia como um todo.

## P5 — Alertas não bloqueantes

Mantém a matriz homologada:

```text
sobreposição
férias
folga
compensação
```

apenas alertam.

---


# 49. CONFERÊNCIA DO EFETIVO GEDUC

A Escala GEDUC deve ser comparada com o cadastro oficial da Equipe Operacional.

Exemplo:

```text
Equipe Operacional GEDUC: 35 agentes

Em atividade:              28
Apoio/administrativo:       2
Férias:                     3
Compensação:                2
Sem situação definida:      0

Cobertura da equipe:      35/35
```

A conferência deve trabalhar com **agentes únicos**, e não com quantidade de
alocações.

Exemplo:

```text
Agente João
Manhã  -> atividade normal
Noite  -> hora extra

Resultado da conferência:
1 agente
2 alocações
```

Se houver agente ativo da GEDUC sem qualquer situação explicada:

```text
⚠ 1 agente da Equipe Operacional não possui situação definida nesta escala.

[ Ver agente ]
```

A ausência de situação é alerta operacional e não bloqueio automático.

---

# 50. NATUREZA DA JORNADA / ALOCAÇÃO COMPLEMENTAR

Uma segunda alocação do agente **não pode ser classificada automaticamente**
pelo sistema.

O responsável pela escala deve definir explicitamente a natureza da jornada.

Primeira matriz:

```text
NORMAL
HORA_EXTRA
BANCO_HORAS
```

Significados:

```text
NORMAL
= jornada ordinária do agente

HORA_EXTRA
= trabalho adicional classificado administrativamente como hora extra

BANCO_HORAS
= trabalho adicional realizado para gerar crédito de horas destinado
  a compensação/folga futura
```

O Fênix não deve inferir a classificação apenas porque o agente apareceu em
dois turnos.

---

# 51. DECISÃO OBRIGATÓRIA DO RESPONSÁVEL PELA ESCALA

Quando o sistema detectar que o mesmo agente possui nova alocação no mesmo dia,
deve apresentar:

```text
Agente João já possui uma jornada/alocação neste dia.

Como esta nova alocação deve ser classificada?

( ) Jornada normal
( ) Hora extra
( ) Banco de horas

[ Cancelar ] [ Confirmar classificação ]
```

A classificação deve ser feita pelo responsável da escala ou pelo Gerente,
conforme as permissões de gestão homologadas.

O sistema pode alertar, mas não deve escolher sozinho.

---

# 52. CONTROLE DA QUANTIDADE DE HORAS

Nesta primeira fase, o objetivo é controlar **quantidade de horas trabalhadas**.

Não entram:

```text
valor financeiro por agente
valor da hora
folha de pagamento
custo individual
custo total financeiro
```

Entram:

```text
horas de jornada normal
horas classificadas como hora extra
horas geradas para banco de horas
total de horas trabalhadas no dia
total de horas trabalhadas no período
```

Exemplo:

```text
AGENTE JOÃO

Jornada normal:
06:00–12:00
6h

Banco de horas:
18:00–22:00
4h

Total trabalhado no dia:
10h

Composição:
6h normal
0h hora extra
4h banco de horas
```

---

# 53. HORA EXTRA SEM COMPONENTE FINANCEIRO

Mesmo quando a alocação for classificada como `HORA_EXTRA`, o primeiro objetivo
será somente registrar:

```text
agente
atividade
data
turno
horaInicioPrevista
horaFimPrevista
horaInicioReal
horaFimReal
quantidadeHoras
motivo
autorizadaPor
autorizadaEm
resultado
evidências
```

O sistema poderá responder:

```text
quantas horas extras foram realizadas
por quais agentes
em quais atividades
em quais dias
por quais motivos
```

Sem calcular remuneração.

---

# 54. BANCO DE HORAS — CRÉDITO GERADO

Quando a segunda jornada for classificada como `BANCO_HORAS`, ela representa
crédito de horas gerado pelo trabalho adicional.

Exemplo:

```text
AGENTE MARIA

Jornada normal:
12:00–18:00

Nova alocação:
18:00–22:00

Classificação:
BANCO DE HORAS

Crédito gerado:
4h
```

O registro deve guardar, no mínimo:

```text
agente
data
atividade
horaInicioReal
horaFimReal
quantidadeHoras
motivo
definidoPor
definidoEm
```

---

# 55. BANCO DE HORAS — COMPENSAÇÃO / FOLGA

A situação de compensação já existente na escala deve ser tratada como consumo
de horas do banco, quando esse controle for formalmente implantado.

Conceitualmente:

```text
TRABALHO EM DOBRA / BANCO DE HORAS
        ↓
gera crédito
        ↓
BANCO DE HORAS
        ↓
COMPENSAÇÃO / FOLGA FUTURA
        ↓
consome crédito
```

Na ESC-001D, o ponto essencial é **registrar corretamente a origem das horas**.

O controle de saldo acumulado poderá ser consolidado em etapa específica, sem
misturar com financeiro.

---

# 56. DISTINÇÃO ENTRE AGENTE ÚNICO, ALOCAÇÃO E HORAS

O sistema deve trabalhar com três contagens diferentes:

```text
AGENTES ÚNICOS
= pessoas da Equipe Operacional

ALOCAÇÕES
= quantas posições/atividades foram atribuídas

HORAS
= quantidade de tempo trabalhado
```

Exemplo:

```text
Equipe GEDUC:
35 agentes únicos

Agente João:
Manhã -> jornada normal
Noite -> banco de horas

Resultado:

agentes únicos:
1

alocações:
2

horas:
6h normal + 4h banco = 10h
```

---

# 57. CONFERÊNCIA DO EFETIVO COM JORNADAS COMPLEMENTARES

A conferência dos 35 agentes continua sendo por pessoa única.

Exemplo:

```text
Equipe Operacional GEDUC: 35

Em atividade normal:       28
Apoio/administrativo:       2
Férias:                     3
Compensação:                2
Sem situação definida:      0

Cobertura:
35/35
```

Separadamente, o sistema apresenta:

```text
JORNADAS COMPLEMENTARES

Hora extra:       2 agentes / 7h
Banco de horas:   3 agentes / 11h
```

Os agentes dessas jornadas já foram contados anteriormente na cobertura dos
35.

---

# 58. ALERTAS DE SEGUNDA JORNADA

Alertas propostos:

```text
⚠ Agente já possui jornada neste dia.

⚠ Nova alocação ainda não foi classificada como NORMAL, HORA_EXTRA ou
  BANCO_HORAS.

⚠ Segunda jornada sobrepõe outra atividade.

⚠ Hora extra sem motivo informado.

⚠ Banco de horas sem motivo informado.

⚠ Jornada complementar sem horário real de execução.
```

A existência de duas jornadas não é erro por si só.

O problema é uma segunda jornada **sem classificação clara**.

---

# 59. PAINEL DE HORAS DO DIA

Na Gestão da Escala:

```text
RESUMO DO EFETIVO

Equipe GEDUC:                    35
Agentes com situação definida:  35
Sem situação definida:           0

HORAS / JORNADAS COMPLEMENTARES

Hora extra:
2 agentes
7h realizadas

Banco de horas:
3 agentes
11h geradas
```

Esse painel não exibe valores financeiros.

---

# 60. DETALHE DO AGENTE

Ao abrir um agente:

```text
AGENTE JOÃO

17/09/2026

06:00–12:00
Jornada normal
Motociclista Seguro
6h

18:00–22:00
Banco de horas
Apoio em evento educativo
4h

TOTAL DO DIA
10h

Normal:
6h

Hora extra:
0h

Banco de horas:
4h
```

---

# 61. INDICADORES OPERACIONAIS DE HORAS

Primeiros indicadores:

```text
total de horas normais
total de horas extras
total de horas geradas para banco de horas
agentes que fizeram hora extra
agentes que geraram banco de horas
quantidade de jornadas complementares
horas por atividade
horas por turno
horas por período
horas por motivo
```

Nenhum indicador financeiro nesta fase.

---

# 62. ANÁLISE DA UTILIDADE DA JORNADA COMPLEMENTAR

Mesmo sem calcular dinheiro, será possível avaliar se a jornada complementar
teve utilidade operacional.

O sistema poderá apresentar:

```text
Tipo:
HORA_EXTRA ou BANCO_HORAS

Horas realizadas:
4h

Motivo:
reforço operacional

Missão concluída:
SIM

Resultado registrado:
SIM

Evidência:
SIM
```

A chefia poderá registrar:

```text
Resultado da jornada complementar:

[ Atendeu à necessidade ]
[ Atendeu parcialmente ]
[ Resultado não demonstrado ]

Justificativa:
[________________________________]
```

O Fênix fornece evidências.

A avaliação permanece humana.

---

# 63. FLUXO DA SEGUNDA JORNADA

```text
AGENTE JÁ POSSUI JORNADA
        ↓
NOVA NECESSIDADE
        ↓
RESPONSÁVEL DEFINE A CLASSIFICAÇÃO
        ↓
 ┌───────────────┬─────────────────┐
 ↓               ↓                 ↓
NORMAL        HORA EXTRA       BANCO HORAS
 ↓               ↓                 ↓
EXECUÇÃO      EXECUÇÃO          EXECUÇÃO
 ↓               ↓                 ↓
HORAS         HORAS EXTRAS      CRÉDITO DE HORAS
 ↓               ↓                 ↓
RESULTADO     RESULTADO          RESULTADO
```

---

# 64. IMPACTO NA ESC-001D

A ESC-001D deve nascer preparada para armazenar:

```text
tipoJornada
horaInicioPrevista
horaFimPrevista
horaInicioReal
horaFimReal
quantidadeHoras
motivoJornadaComplementar
definidoPor
definidoEm
```

Valores de `tipoJornada`:

```text
normal
hora_extra
banco_horas
```

O objetivo é evitar que a implantação futura do banco de horas exija
reestruturação das alocações já registradas.

---

# 65. REGRA FUNCIONAL CONSOLIDADA

Toda vez que o mesmo agente receber uma nova alocação em outro turno ou período,
o Fênix deverá perguntar ao responsável pela escala:

```text
Esta nova jornada é:

NORMAL
HORA EXTRA
BANCO DE HORAS
```

A resposta passa a fazer parte do registro operacional da escala.

Essa definição não será inferida automaticamente.

---

# 66. CONCLUSÃO

O módulo deve parecer mais uma **central operacional diária** do que um
formulário administrativo.

A experiência principal fica:

```text
VER A ESCALA
     ↓
ENTENDER RAPIDAMENTE
     ↓
SABER ONDE ESTOU / QUEM ESTÁ ONDE
     ↓
EXECUTAR A MISSÃO
```

Para quem gerencia:

```text
CRIAR
 ↓
ORGANIZAR
 ↓
ALERTAR
 ↓
REVISAR
 ↓
PUBLICAR
```

Sem transformar o processo em burocracia digital.
