# ADM-002A.2 — Listagem e formulário responsivos

## Objetivo

Substituir o acesso direto ao Firestore na tela de Tipos de Ações por uma
experiência administrativa baseada no fluxo Controller → Repository → Service.

## Decisões

- o controller canônico passa a residir no módulo `tipos_acoes`;
- o caminho antigo em `modules/admin/controllers` permanece como exportação de
  compatibilidade;
- a página não importa `cloud_firestore`;
- cadastro e edição usam formulário próprio e o Provider já registrado em
  `app.dart`;
- inativação preserva o documento e exige confirmação;
- filtros são locais e não geram leituras adicionais;
- a etapa não altera `NovaAcaoPage`, regras do Firestore ou produção.

## Critérios de aceite

- estados de carregamento, erro, vazio e lista preenchida;
- indicadores de total, ativos e inativos;
- pesquisa por nome, classificação e materiais;
- criação, edição e alteração de status pelo controller;
- confirmação antes de ativar ou inativar;
- zero overflow em 360 px e 800 px;
- testes focados, suíte completa, analyze e diff check aprovados.
