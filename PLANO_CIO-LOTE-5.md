# Plano de implementação — CIO Lote 5

**Blueprint homologado:** 13/08/2026
**Execução:** Etapa 1 concluída localmente

## Etapa 1 — Fundação cartográfica

- incorporar e manifestar a geometria oficial;
- implementar leitura, integridade e ponto-em-polígono;
- cruzar as 121 feições com o catálogo canônico;
- criar testes unitários da geometria.

**Saída:** fundação local, sem interface e sem ativação.

**Estado:** concluída em 13/08/2026; testes específicos e análise estática
aprovados.

## Etapa 2 — Elegibilidade e agregação

- incorporar o registro de exclusões G1/G2;
- implementar a política de elegibilidade;
- agregar por bairro e Regional;
- integrar filtros e janela temporal;
- provar 32 incluídos e oito excluídos no conjunto homologado.

**Saída:** modelo cartográfico sem coordenadas no resultado.

**Estado:** concluída localmente em 13/08/2026; integração com interface ainda
não iniciada.

## Etapa 3 — Interface protegida

- substituir a simulação por polígonos oficiais agregados;
- implementar legenda, alternância territorial e atribuições;
- criar estados offline, indisponível e bloqueado;
- manter a configuração de ativação desligada.

**Saída:** interface completa, ainda não liberada em produção.

**Estado:** concluída localmente em 13/08/2026; mapa protegido por padrão e
habilitado somente em testes controlados.

## Etapa 4 — Qualidade técnica

- testes específicos de geometria, elegibilidade, privacidade e widget;
- responsividade em 320, 360, 412 e 800 px;
- `flutter analyze` e suíte completa;
- revisão de diff, dependências, rotas, Providers e arquivos protegidos.

**Saída:** candidato técnico para APK de homologação.

**Estado:** concluída localmente em 13/08/2026; candidato técnico aprovado com
mapa ainda desativado.

## Etapa 5 — Homologação física

- gerar APK de homologação para Samsung Galaxy A05;
- testar online, offline, rolagem, zoom, alternância e atribuições;
- verificar ausência de coordenadas e G1/G2;
- registrar tempos e estabilidade percebida;
- submeter a ativação final à homologação humana.

**Saída:** decisão explícita de manter bloqueado ou ativar o mapa.

**Estado:** concluída e homologada no Samsung Galaxy A05 em 13/08/2026. Após a
homologação, o mapa foi ativado por padrão para as compilações oficiais; a chave
`CIO_MAPA_TERRITORIAL_LOTE5=false` permanece disponível para bloqueio
emergencial. Lote 5 aprovado para publicação.

## Autorizações separadas

Cada etapa exige autorização própria. Implementação, testes completos, APK,
publicação da branch, PR e merge permanecem decisões independentes.
