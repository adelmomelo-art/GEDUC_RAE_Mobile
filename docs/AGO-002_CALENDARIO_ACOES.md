# AGO-002 — Calendário com nomes, links e semáforo

## Blueprint aprovado por instrução do usuário — 06/10/2026

Objetivo: reconhecer a ação no calendário e acessar diretamente seu cartão
privado de detalhes. Substituir a contagem principal pelos nomes; manter o
número do dia como referência. Autorização para seguir o fluxo nesta conversa.

| Prioridade | Condição | Cor | Texto acessível |
|---|---|---|---|
| 1 | Ação cancelada, qualquer data | Vermelho | Cancelada |
| 2 | Ação ativa hoje ou nos próximos três dias civis, inclusive | Amarelo | Hoje / próximos 3 dias |
| 3 | Demais ações não canceladas | Verde | Agendada |

Escolha “3 dias” recebida explicitamente do usuário. Uma ação passada ativa
continua verde; cor não infere execução ou conclusão. Estados de planejamento,
prontidão e publicação continuam no cartão de detalhes. Proximidade é calculada
pela data civil local do aparelho, sem comparar horas; cancelamento prevalece.

Cada título é um botão/link para o cartão existente: seleciona o dia, rola até
o cartão correto e destaca sua borda. Não abre edição nem modifica documentos.
Títulos iguais mantêm IDs e destinos distintos. Os filtros continuam aplicados.
Ações canceladas também têm link para consultar motivo/histórico.

Até dois nomes aparecem por célula, com duas linhas e reticências; tooltip e
leitor de tela recebem o nome integral e a situação. Havendo mais ações, botão
“+N ações” abre o grupo do dia e posiciona no primeiro cartão adicional. Todos
os cartões permanecem na lista do dia, separados por turno.

Web ampla exibe as sete colunas. No A05, as sete colunas cabem na largura disponível, sem rolagem horizontal.
Nomes usam apresentação compacta em duas linhas, com reticências e tooltip
completo; cabeçalhos acompanham as colunas. Áreas clicáveis e altura adaptam-se
à escala de texto. O botão adicional usa +N em largura compacta. Legenda
textual acompanha as cores, sem depender apenas da distinção visual.

## Plano técnico

1. Serviço puro define semáforo e rótulos; testes fixam hoje para fronteiras.
2. AgendaPage usa nomes, cores, links e cartão existente; nada é gravado ao clicar.
3. Testes de widget cobrem destino correto, vários itens e layout de celular.
4. Analyze e suíte apropriada; package completo com manifesto e aplicador PS 5.1.
5. Homologação local web/A05 antes de commit, CI, merge e publicação.

Escopo: UI e cálculo de apresentação. Regras, acesso privado, coleções,
montagem/publicação da escala, PDF e Firebase/App Check permanecem na AGO-001.

## Homologação funcional proposta

| Checkpoint | Resultado esperado |
|---|---|
| C01 — nomes | Calendário mostra nome da ação, conserva dia, sem contagem principal |
| C02 — link | Clique no nome posiciona no cartão correto e destaca a borda |
| C03 — verde | Ação fora da janela, ativa, aparece verde |
| C04 — amarelo | Hoje e +3 amarelos; +4 verde; ontem não amarelo |
| C05 — vermelho | Cancelada fica vermelha inclusive hoje/+3; motivo disponível |
| C06 — várias ações | Cores independentes, títulos iguais com destinos próprios, +N acessível |
| C07 — filtros | Nome/link respeitam turno, situação e pesquisa |
| C08 — A05 | Sete colunas visíveis sem deslizar, nomes compactos, link e cartão sem overflow |
| C09 — regressão | Cadastro, pronta, montagem/publicação e PDF continuam consistentes |
| C10 — privacidade | Outros perfis continuam sem agenda e cartões privados |

Situação desta entrega: implementada e pronta para homologação funcional.

## Validação técnica R1

Flutter 3.44.4 / Dart 3.12.2, base 251d260: analyze zero issues; suíte completa
1.161 testes PASS, incluindo 19 da agenda e cinco novos testes de semáforo/link.
Testes de widget cobrem títulos iguais, clique em outro dia, cartão correto,
cores independentes, acesso às ações adicionais e largura 390 px com texto 1,5x.
As semanas têm altura natural pelo conteúdo; não se reserva altura máxima para
semanas vazias. Publicação e homologação funcional da AGO-002 ainda pendentes.

Aplicador validado com PowerShell 7.4.6 em Linux, base LF e CRLF; sintaxe
compatível com PowerShell 5.1. Execução Windows e aceite visual ficam na
homologação local do usuário. Manifesto cobre nove arquivos completos.
Build web debug da entrada isolada de homologação: PASS.
Regras e dependências não mudaram; não se repete auditoria npm ou deploy Rules.


## R2 — correção após homologação móvel

Em 06/10/2026, usuário aprovou nome/link, cores/prioridade do cancelamento,
várias ações/acesso adicional, filtros e montagem sem duplicação.
Layout móvel R1: FAIL; imagem de novembro mostrava apenas Seg/Ter/Qua e ocultava
as demais colunas. Ausência de overflow não significava boa apresentação.

R2 remove a largura mínima/rolagem horizontal: Seg a Dom e todas as datas
ficam dentro da largura do celular. Células adaptam o nome para duas linhas,
com nome integral acessível por tooltip/leitor de tela. Semanas mantêm altura
natural e links/cores; cartão de detalhes continua com o texto completo.
Novo teste confere cabeçalhos e domingo 01/11/2026 dentro da tela de 390 px,
sem scroll horizontal. O teste móvel de texto ampliado/várias ações permanece.

C08 deve ser repetido após R2. Aceites anteriores permanecem válidos; montagem
foi aprovada, publicação/PDF e privacidade da AGO-002 ainda seguem o roteiro.
Validação técnica R2: análise sem problemas; 20 testes de agenda e 1.162 testes
Flutter completos aprovados; build web debug da entrada HML aprovado.
Aplicador R2: base limpa LF e R1 integral CRLF aprovadas em PowerShell 7.4.6
no Linux, com nove hashes de destino conferidos por cenário. Alteração fora
do pacote bloqueada antes de gravar. Escrita e backup preservam os bytes.
Inspeção de renderização em 390 px: sete colunas e nomes em duas linhas.
A homologação visual pelo usuário permanece pendente; não houve commit ou publicação.

### AGO-002 R2 — homologação funcional concluída em 06/10/2026

Homologação local em emuladores e Chrome: PASS.
Nome no calendário, link para cartão, cores e prioridade do cancelamento,
várias ações/+N, filtros, montagem sem duplicação, layout móvel R2,
publicação, participante/privacidade e PDF: todos PASS.
Validação técnica da entrega: analyze sem problemas, 1.162 testes Flutter
aprovados e build web de homologação aprovado.
Publicação da AGO-002 em produção e atualização A05 seguem após merge e CI.
