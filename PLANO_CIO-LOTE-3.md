# Plano de implementação — CIO Lote 3

## Etapa 0 — Aprovação

1. Aprovar auditoria, Blueprint, limites e critérios de aceite.
2. Confirmar que mapa permanece condicionado ao portão de qualidade.
3. Criar a branch `feature/cio-historico-territorial-lote3` a partir da baseline.

## Etapa 1 — Contratos e qualidade

1. Criar o contrato imutável de diagnóstico de qualidade.
2. Implementar normalização territorial baseada em `regionalId`.
3. Classificar fallbacks nominais como legado ou não resolvido.
4. Cobrir coordenadas inválidas, datas limítrofes e catálogos incompletos.

## Etapa 2 — Série histórica

1. Criar buckets contínuos para a granularidade selecionada.
2. Agregar ações, pessoas, veículos e credenciais.
3. Calcular janela anterior equivalente.
4. Aplicar regra de amostra mínima para classificação de tendência.
5. Expor os resultados somente por `DashboardCIOResult`.

## Etapa 3 — Inteligência territorial

1. Gerar ranking por identidade territorial estável.
2. Exibir participação, totais e estado de qualidade por regional.
3. Implementar drilldown rastreável aos RAEs de origem.
4. Tratar registros legados e não resolvidos sem agregação silenciosa.

## Etapa 4 — Interface

1. Integrar série histórica ao Dashboard oficial.
2. Integrar comparação e tendência descritiva.
3. Integrar ranking/matriz territorial e drilldown.
4. Exibir cobertura e alertas de qualidade.
5. Garantir vazio, erro, carregamento e responsividade.

## Etapa 5 — Verificação local

1. Testar granularidade diária, mensal e anual.
2. Testar preenchimento de buckets vazios e virada de mês/ano.
3. Testar janela comparativa e amostra insuficiente.
4. Testar normalização, legado, ambiguidade e reconciliação do drilldown.
5. Testar larguras 320, 360, 412 e 800 px e escala de texto 1,3.
6. Executar formatação, análise estática e suíte completa de testes.
7. Confirmar que os arquivos protegidos não foram alterados.

## Etapa 6 — Revisão e homologação

1. Revisar o diff funcional e a ausência de dados simulados.
2. Gerar APK de homologação somente após autorização.
3. Homologar no Samsung Galaxy A05.
4. Verificar filtros, série, comparação, ranking, drilldown e coerência dos
   totais com RAEs conhecidos.
5. Publicar branch/PR, mesclar e formalizar a homologação somente mediante
   autorizações distintas do usuário.

## Gate opcional — mapa

O mapa será planejado em complemento próprio apenas se o relatório de dados
reais cumprir a regra de qualidade aprovada e existir fonte territorial oficial.
Sua ausência não impede a homologação do núcleo do Lote 3.
