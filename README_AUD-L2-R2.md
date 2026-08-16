# AUD-L2-R2 — Idempotent Persistence

## Objetivo

Eliminar duplicações causadas por salvamentos repetidos da mesma ação na fila
offline e por retries da sincronização remota.

## Alterações

- `OfflineService` substitui a pendência anterior quando recebe novamente o
  mesmo `acao.id`, preservando a posição da entrada na fila;
- entradas sem ID ou dados locais inválidos não são usadas como chave de
  deduplicação;
- `FirebaseAcaoService` usa o ID local como ID documental e grava por
  `set()` em `acoes/{acao.id}`;
- retries da mesma ação passam a atualizar o mesmo documento remoto;
- ações sem ID local são rejeitadas antes da escrita remota.

## Testes

- deduplicação com preservação da versão mais recente;
- preservação da ordem das demais pendências;
- retry após falha ocorrida depois da persistência remota;
- sucesso parcial mantendo somente falhas locais;
- identidade documental estável e rejeição de ID vazio.

## Fora do escopo

- cálculo e preservação de `anoRAE`;
- validação de coordenador e fallback por nome;
- paridade entre listas de IDs e nomes;
- Firestore Rules, ACL, CI, coverage e UI.

## Validação

- suíte específica: 15 testes aprovados;
- testes adicionados: 3;
- suíte completa: 693 testes aprovados;
- `flutter analyze`: `No issues found`;
- nenhuma dependência adicionada.
