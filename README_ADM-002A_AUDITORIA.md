# ADM-002A — Auditoria e Arquitetura do módulo Tipos de Ações

**Projeto:** Plataforma Fênix — GEDUC/RAE Mobile
**Branch:** `feature/adm-002a-tipos-acoes`
**Baseline:** `08a2262`
**Data da auditoria:** 05/08/2026
**Pacote-fonte:** `ADM-002A-AUDITORIA-TIPOS-ACOES_2026-08-05_18-07-42.zip`
**SHA-256 do pacote-fonte:** `E0EB418C294BF489E6D0819078AB4BD10414288AB578DF584D45D53723C402A3`

## Resultado executivo

O módulo **Tipos de Ações** possui uma fundação arquitetural parcialmente pronta:

- `TipoAcaoController` já está registrado no `MultiProvider`;
- `TipoAcaoRepository` e `TipoAcaoService` já existem;
- a rota está protegida por `Permission.gerenciarTiposAcoes`;
- administrador e gestor possuem a permissão;
- as regras do Firestore permitem leitura para usuários ativos e escrita para administrador ou gestor;
- exclusão física já está bloqueada.

Entretanto, a tela atualmente em produção **não utiliza essa arquitetura**. `TiposAcoesPage` acessa o Firestore diretamente, cria UUID na interface e concentra leitura, cadastro e alteração de status no widget. A tela `NovaAcaoPage` também consulta `tipos_acoes` diretamente e não filtra registros inativos.

A conclusão da auditoria é:

> A arquitetura correta já foi iniciada, mas está desconectada da interface. A ADM-002A deve consolidar uma única cadeia de dados e eliminar os acessos diretos ao Firestore nas telas do módulo.

## Decisão

`tipos_acoes` continuará como entidade própria. Não será convertido em item da Central de Domínios porque possui atributos operacionais específicos:

- nome da ação;
- classificação/tipo;
- público estimado padrão;
- público mínimo padrão;
- materiais sugeridos;
- situação ativa;
- metadados de criação e atualização.

## Conteúdo deste pacote

- `BLUEPRINT_ADM-002A.md`
- `PLANO_IMPLEMENTACAO_ADM-002A.md`
- `docs/ADM-002A_DIAGNOSTICO_ARQUITETURAL.md`
- `docs/ADM-002A_DECISOES_TECNICAS.md`
- `tools/manifestos/ADM-002A-AUDITORIA-ARQUITETURA.txt`

Este pacote não contém implementação funcional. Ele formaliza a arquitetura e o plano antes da primeira alteração de código.
