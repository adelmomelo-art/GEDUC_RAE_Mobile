# BUG-RAE-002E.2D.2E.1D — Runner operacional protegido

Status: **READINESS-ONLY / ESCRITA REMOTA INDISPONÍVEL**

## Objetivo

Consolidar os gates necessários antes de qualquer futura autorização do seed institucional
dos 53 projetos, sem implementar ainda a execução remota de escrita.

## Gates modelados

O runner exige:

1. projeto `geduc-rae-mobile`;
2. coleção `projetos`;
3. branch `fix/bug-rae-002-acl-operacional-dinamica`;
4. HEAD esperado informado pelo chamador;
5. working tree limpo;
6. SHA256 do manifesto institucional:
   `C109703987A86B6D22C34CB0C1072CE434BB1E1CFAF6F01A43D40630EDB2A43C`;
7. SHA256 normalizado do ruleset ativo:
   `4546EE8797F6120FFCFEE9ACD2B0A8DA695F3C8E2DCA341A5612F97B95D6769F`;
8. preflight remoto READ-ONLY dos 53 destinos;
9. zero blockers;
10. zero writes no preflight;
11. composição com `remoteWriteEnabled = false`.

## Ordem de avaliação

Os gates locais são verificados primeiro.

Depois:

1. ruleset ativo é auditado;
2. somente se o ruleset estiver correto ocorre o preflight remoto;
3. o resultado pode ficar `readyForExplicitAuthorization = true`.

Isso ainda **não habilita a escrita**.

## Autorização explícita

A frase prevista para uma etapa futura é:

`AUTORIZO SEED CREATE_ONLY DOS 53 PROJETOS`

Nesta etapa ela serve somente para provar que a autorização pode ser reconhecida.
Mesmo quando presente:

- `remoteWriteEnabled = false`;
- `seedExecutionAvailable = false`;
- `seedExecuted = false`.

## Ausências deliberadas

Este runner não possui:

- CLI;
- ADC/gcloud;
- `fetch`;
- REST;
- adaptador CREATE_ONLY;
- executor de escrita;
- POST/PUT/PATCH/DELETE;
- seed remoto.

## Próxima etapa

Após homologação e commit deste readiness runner, a etapa seguinte poderá construir,
em arquivo separado, um runner de execução remota com **dupla trava**. Essa futura
implementação deverá permanecer bloqueada até que seja testada e homologada e até que
o usuário forneça autorização explícita em uma etapa separada.
