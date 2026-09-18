# ESC-001D.4 — BLUEPRINT TÉCNICO
## Gestão da Escala GEDUC

**Baseline:** `97f7f331c82a845fbabac375610a5d0ecf110d57`
**Dependências fechadas:** ESC-001D.1, ESC-001D.2 e ESC-001D.3
**Status:** implementação da fase D.4 do Plano v0.1

## Resultado desta entrega

A Gestão da Escala passa a permitir abrir a data de planejamento, criar o
rascunho diário exclusivamente pelo agente responsável, editar rascunho pelo
responsável ou Gerente, criar/editar atividades, escolher coordenador, montar
equipe, remover integrante do rascunho, classificar segunda jornada, resumir
horas programadas e conferir efetivo/alertas.

A publicação e a revisão versionada permanecem na ESC-001D.5.

## Autorização

```text
CRIAR RASCUNHO = agente responsável
EDITAR RASCUNHO = agente responsável ou Gerente
CLASSIFICAR NOVA JORNADA ADICIONAL = agente responsável
ADMINISTRADOR = não opera a escala
```

## Segunda jornada

A primeira alocação sem escolha explícita é `NORMAL`. A segunda ou posterior
alocação exige classificação explícita `NORMAL`, `HORA_EXTRA` ou
`BANCO_HORAS`.

As Rules passam a impedir Gerente de criar/reclassificar jornada complementar.
A condição "segunda jornada NORMAL" é detectada no cliente pelo conjunto do
dia; o contrato atual não possui campo ordinal que permita ao Rules Engine
distinguir primeira de segunda alocação quando ambas são `normal`.

## Equipe

O universo do seletor é:

```text
membro equipe_operacional ativo
+ perfil operacional ativo
+ setorCodigo = GEDUC
```

O UID persistido na alocação vem de `equipe_operacional.usuarioId`, mantendo o
vínculo canônico exigido pelas Rules.

## Remoção de integrante

`escala_alocacoes` pode ser excluída por responsável/Gerente somente quando a
escala pai está em `rascunho`. Demais deletes continuam negados.

## Alertas não bloqueantes

- múltipla alocação;
- sobreposição;
- férias;
- compensação;
- folga;
- agente sem situação;
- identidade sem UID canônico.

## Horas

Somente horas programadas. Não existem custo, remuneração, folha ou valor de
hora.

## Rota

`/escala/gestao`, protegida pela ACL específica da Escala e pela configuração
do responsável.

## Fora do escopo D.4

- publicar;
- revisar/republicar;
- configuração do responsável;
- execução;
- RAE automático;
- PDF;
- histórico consolidado.
