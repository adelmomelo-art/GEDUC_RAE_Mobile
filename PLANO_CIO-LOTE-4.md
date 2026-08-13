# Plano de implementação — CIO Lote 4

## Etapa 0 — Aprovação institucional

1. Aprovar auditoria, Blueprint e limites do lote.
2. Confirmar período de avaliação dos dados reais, inicialmente 12 meses.
3. Aprovar ou ajustar os percentuais do portão de qualidade.
4. Identificar o responsável institucional pelo saneamento territorial.

## Etapa 1 — Contratos puros

1. Criar snapshot imutável do catálogo.
2. Criar enumerações de apontamento e classificação primária.
3. Criar relatório de integridade do catálogo.
4. Criar relatório de qualidade dos RAEs.
5. Cobrir vazio, duplicidade, inatividade e IDs órfãos com testes.

## Etapa 2 — Validação territorial

1. Validar ID, estado e tipologia.
2. Resolver bairro contra catálogo e detectar ambiguidade.
3. Validar coordenadas contra limite territorial aprovado.
4. Detectar divergência entre ID, bairro e coordenada.
5. Manter regras determinísticas e sem escrita.

## Etapa 3 — Dados reais

1. Executar leitura autenticada e somente leitura de `acoes` e `regionais`.
2. Gerar relatório agregado sem dados pessoais desnecessários.
3. Registrar cobertura, conflitos e distribuição temporal.
4. Submeter resultados e thresholds à aprovação institucional.

## Etapa 4 — Integração CIO

1. Expor o relatório pelo `DashboardCIOBridge`.
2. Substituir “com ID” por cobertura institucional validada.
3. Adicionar painel de integridade e fila consultiva.
4. Exibir explicitamente cada critério aprovado ou bloqueado do mapa.
5. Preservar filtros, histórico e drilldown do Lote 3.

## Etapa 5 — Verificação

1. Testar catálogos ativos, inativos, duplicados e indisponíveis.
2. Testar IDs válidos, órfãos e legados.
3. Testar bairros ambíguos e normalização de diacríticos.
4. Testar coordenadas inválidas, fora do limite e divergentes.
5. Testar reconciliação dos totais.
6. Testar 320, 360, 412 e 800 px e escala de texto 1,3.
7. Executar análise estática e suíte completa.
8. Confirmar que arquivos protegidos não foram alterados.

## Etapa 6 — Homologação

1. Revisar diff e relatório de dados reais.
2. Gerar APK somente após autorização.
3. Homologar somente no Samsung Galaxy A05, salvo expansão autorizada.
4. Publicar, mesclar e formalizar homologação mediante autorizações distintas.

## Gate posterior — mapa

O mapa não faz parte da implementação nuclear deste lote. Se todos os critérios
forem aprovados, deverá ser tratado em complemento ou ciclo próprio, incluindo
fonte oficial, licença, atribuição, provedor e testes específicos.
