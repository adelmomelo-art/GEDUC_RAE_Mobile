# ADM-002A.2 — Tipos de Ações

Pacote de listagem e formulário administrativos responsivos.

## Incluído

- listagem sem acesso direto ao Firestore;
- formulário de criação e edição;
- Provider e controller modularizados;
- filtros e indicadores operacionais;
- ativação e inativação com confirmação;
- estados de carregamento, erro e vazio;
- compatibilidade temporária para o import antigo do controller;
- testes para A05 e Tab S6.

## Fora do escopo

- integração com `NovaAcaoPage` — ADM-002A.3;
- hardening das Firestore Rules — ADM-002A.4;
- leitura ou alteração de produção;
- atualização de dependências.
