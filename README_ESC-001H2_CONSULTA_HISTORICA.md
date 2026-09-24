# ESC-001H.2 — Consulta histórica de horas

Esta entrega conecta o núcleo histórico da ESC-001H.1 ao Firestore e a um controller de aplicação. Não cria tela e não introduz cálculo financeiro.

## Entregas

- consulta inclusiva por período, limitada a 366 dias;
- quatro leituras por período: escalas, atividades, alocações e indisponibilidades;
- somente a versão publicada mais recente de cada data;
- consolidação pelo `EscalaIndicadoresHistoricosService` da ESC-001H.1;
- visão geral para administrador, gestor e gerente;
- visão própria para coordenador e agente;
- filtragem de registros de terceiros antes da consolidação pessoal;
- período e listas imutáveis;
- falha fechada para perfil desconhecido ou UID vazio.

## Fora do escopo

- interface visual, reservada para ESC-001H.3;
- produtividade e Faixita, reservados para ESC-001H.3/H.4;
- valores monetários, folha, adicionais, banco financeiro ou conversão de horas em dinheiro;
- novos índices, Functions, Storage, Hosting ou deploy Firebase.

## Validação

Os testes cobrem seleção de versão publicada, intervalo inclusivo, limite de 366 dias, indisponibilidades abrangentes, matriz de acesso, visão pessoal, consolidação e falha fechada.
