# Relatório RAE timbrado da Gerência de Educação

## Objetivo

Consolidar no PDF de impressão as informações já registradas durante a jornada do RAE e incorporar a avaliação e a aprendizagem operacional, incluindo a revisão inteligente da Faixita.

O modelo visual de duas páginas foi aprovado em 09/08/2026 como novo padrão do relatório PDF.

## Padrão visual aprovado

- Papel A4 em duas páginas.
- Assinatura conjunta AMC à esquerda da Prefeitura de Fortaleza.
- Marcas centralizadas a 2 cm do topo e alinhadas conforme o manual institucional.
- Rodapé oficial com endereço da AMC e faixa cromática da Prefeitura.
- Itens 1 a 4 distribuídos em três colunas.
- Avaliação e aprendizagem operacional em duas colunas.
- Resultados e revisão inteligente da Faixita preservados.

## Conteúdo do relatório

1. Identificação e planejamento.
2. Localização e validação territorial.
3. Caracterização da ação com nomes dos catálogos.
4. Recursos e integração institucional.
5. Resultados e situação da meta.
6. Avaliação e aprendizagem operacional da equipe.
7. Revisão da Faixita: índice, nível, parecer, pontos fortes, alertas e recomendações.
8. Evidências com três posições fotográficas, QR de validação e assinaturas do coordenador da ação e do Gerente da GEDUC.

## Revisão no aplicativo

A tela de revisão também passa a exibir os detalhes de caracterização, recursos, integração institucional e avaliação/aprendizagem, mantendo correspondência com o documento impresso.

## Validação realizada

- `flutter analyze --no-pub`: sem problemas.
- `flutter test --no-pub`: 524 testes aprovados.
- Teste dedicado de geração do PDF aprovado.
- PDF gerado pelo próprio serviço Flutter em duas páginas A4 e inspecionado visualmente.
- Faixa de evidências validada com três posições para fotos.
- QR Code único e campos de assinatura conferidos em ampliação.
- Samsung A05: homologação física aprovada em 09/08/2026.
- Samsung Tab S6: homologação física aprovada em 09/08/2026.
- APK homologado: `FENIX_RAE_TIMBRADO_CATALOGOS_HOMOLOGACAO_20260809_DEBUG.apk`.
- SHA-256 do APK: `32376944BFC3EAEE0ECBF3C695236B152C9CF6DCF8CA290382E868DA197C4779`.

## Situação

Implementação e APK homologados no A05 e no Tab S6. Commit, push e PR permanecem pendentes de autorização de publicação.
