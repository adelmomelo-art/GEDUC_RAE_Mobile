# ADM-002A — Decisões técnicas

## D-01 — Entidade própria

`tipos_acoes` permanece coleção própria. Não será absorvida por `domains`.

## D-02 — Sem exclusão física

Registros utilizados historicamente serão inativados. `delete` continuará negado.

## D-03 — Gestão por administrador e gestor

A política atual será preservada:

- administrador: gestão completa;
- gestor: gestão completa;
- coordenador e agente: sem acesso administrativo.

## D-04 — Leitura operacional

Usuários ativos poderão ler o catálogo, mas novas seleções utilizarão apenas itens ativos.

## D-05 — Compatibilidade de schema

Os nomes de campos atuais serão preservados nesta intervenção. Renomear `nomeAcao` ou `tipoAcao` exigiria inventário e migração.

## D-06 — ID documental

O identificador confiável será `document.id`. O campo interno `id` será mantido temporariamente por compatibilidade.

## D-07 — Materiais

`materiaisSugeridos` continuará como lista de textos. A ligação com o futuro módulo Materiais fica fora do escopo.

## D-08 — Duplicidade

A primeira barreira será client-side/repository usando comparação normalizada do par `nomeAcao + tipoAcao`. Regra transacional ou chave determinística depende da análise dos dados existentes.

## D-09 — Cores

A paleta da PV-007B-R3 passa a ser referência global. A ADM-002A introduzirá tokens globais sem mudar o resultado visual já homologado da Home.

## D-10 — Rota

`/tipos-acoes` será preservada na ADM-002A. Mudança para `/admin/tipos-acoes` poderá ocorrer depois com redirect legado.

## D-11 — Segurança em duas etapas

Primeiro consolidar o cliente e inventariar os dados; depois endurecer o schema nas regras. Aplicar regra rígida antes do inventário pode bloquear documentos legados.

## D-12 — Homologação multidispositivo

Samsung A05 e Samsung Tab S6 são dispositivos obrigatórios de homologação visual.
