# CIO Lote 3 — Homologação

## Resultado

O CIO Lote 3 foi publicado e homologado funcionalmente em 13/08/2026.

## Baseline homologado

- branch: `main`;
- commit: `2b5c2b2403e65f2dab213d92d9a463eb480f435a`;
- PR funcional: `#29`;
- correção de normalização territorial: `c212bfea50cf81d3467556ef6d80adf42feaee4a`.

## Escopo aprovado

- série histórica contínua com granularidade diária, mensal ou anual;
- preenchimento de períodos sem RAEs com valor zero;
- comparação com janela anterior equivalente;
- proteção contra classificação de tendência com amostra insuficiente;
- agrupamento territorial priorizando `regionalId`;
- distinção entre identidades por ID, registros legados e não resolvidos;
- indicadores de cobertura de regional, bairro, coordenadas e localização
  validada;
- drilldown territorial rastreável aos RAEs de origem;
- normalização de nomes territoriais com e sem diacríticos.

## Validação técnica

- `flutter analyze`: sem problemas;
- suíte completa: 579 testes aprovados;
- testes relacionados após a correção territorial: 21 aprovados;
- Quality Gate Flutter Analyze: aprovado;
- Quality Gate Firestore Rules: aprovado;
- responsividade automatizada em 320, 360, 412 e 800 px;
- escala ampliada 1,3 aprovada para o perfil do Galaxy A05;
- arquivos protegidos verificados sem alterações.

## Homologação física

Dispositivo: Samsung Galaxy A05.

Resultado dos dez cenários executados:

1. abertura do aplicativo e acesso ao Dashboard CIO: aprovado;
2. regressão dos filtros e indicadores do Lote 2: aprovada;
3. apresentação da seção Histórico e território: aprovada;
4. períodos de 7 dias, 30 dias, mês atual e ano atual: aprovados;
5. períodos sem RAEs exibidos com valor zero: aprovado;
6. indicadores de qualidade territorial: aprovados;
7. abertura de regional no detalhamento territorial: aprovada;
8. correspondência entre RAEs detalhados e regional: aprovada;
9. tratamento de identidade legada ou não resolvida: aprovado;
10. rolagem, responsividade e ausência de cortes ou travamentos: aprovadas.

Também foi confirmada a coerência entre os totais do histórico, do detalhamento
territorial e dos indicadores superiores.

## APK homologado

- arquivo: `Fenix-CIO-Lote3-Homologacao-A05.apk`;
- tipo: debug para homologação;
- tamanho: 170.650.512 bytes;
- SHA-256: `F33468316BE583A9E06766BB4FC74BD564B3545CD3F1D76065E30EADC9350041`;
- instalação: atualização instalada e executada no Samsung Galaxy A05.

## Limite preservado

O mapa geográfico não integra o núcleo homologado. Sua ativação continua
condicionada ao portão de qualidade territorial e a uma fonte oficial de
geometria ou coordenadas regionais.

## Encerramento

O CIO Lote 3 está encerrado, publicado na `main` e homologado no Samsung Galaxy
A05. Evoluções posteriores devem partir do baseline `2b5c2b2`.
