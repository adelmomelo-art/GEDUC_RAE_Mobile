# Validação geométrica dos RAEs — IPLANFOR

## Fonte

- conjunto: “Bairros de Fortaleza”;
- responsável: IPLANFOR / Prefeitura de Fortaleza;
- formato utilizado: GeoJSON;
- feições: 121 bairros;
- sistema de referência: EPSG:4326;
- SHA-256:
  `D04B16BBAD3DD205AA19C616CD8CB4D4061917234E656AEF3DF18159CAEF0CCE`.

O Fortaleza em Mapas publica a camada para acesso e download em formatos
abertos. A política municipal de dados abertos permite uso e redistribuição dos
dados públicos. A atribuição proposta para o aplicativo é: “Fonte: IPLANFOR —
Fortaleza em Mapas, Bairros de Fortaleza”.

## Método

1. leitura somente leitura dos 40 RAEs da janela de 12 meses;
2. conversão das coordenadas para ponto longitude/latitude;
3. teste ponto-em-polígono contra os 121 multipolígonos oficiais;
4. comparação do bairro informado com a feição geométrica;
5. comparação da Regional saneada com a Regional da feição;
6. relatório sem publicação das coordenadas individuais.

## Resultado

| Indicador | Resultado | Percentual |
|---|---:|---:|
| Pontos dentro de Fortaleza | 40/40 | 100% |
| Pontos fora do município | 0/40 | 0% |
| Bairro textual igual ao geométrico | 29/40 | 72,5% |
| Bairro textual divergente | 11/40 | 27,5% |
| Regional saneada igual à geométrica | 36/40 | 90% |
| Regional saneada divergente | 4/40 | 10% |
| Pontos em mais de uma feição | 0 | 0% |

## Interpretação

O portão de pelo menos 90% dos RAEs dentro do limite municipal foi atendido com
100%. A coerência regional geométrica atingiu exatamente 90%.

Sete divergências de bairro permanecem dentro da mesma Regional e podem resultar
de ponto de referência, local da ação próximo a outro bairro ou bairro textual
incorreto. Quatro divergências também alteram a Regional e exigem homologação
humana antes de considerar a qualidade territorial integralmente encerrada.

## Quatro divergências de Regional

Todos são documentos sem número operacional:

| ID técnico | Bairro informado | Regional saneada | Bairro geométrico | Regional geométrica |
|---|---|---|---|---|
| `d7e75f1c-cddb-4663-8c74-772dccf8d9b5` | São Gerardo | SER 03 | Centro | SER 12 |
| `0b8bb1dc-05d1-4d7b-ac04-f1b1e68fdb4c` | São Gerardo | SER 03 | Centro | SER 12 |
| `170bc40a-9691-40c4-b3d0-a3a04874b07f` | São Gerardo | SER 03 | Centro | SER 12 |
| `54d275ce-1512-4d71-b5de-55dfd8212012` | São Gerardo | SER 03 | Centro | SER 12 |

### Homologação humana do G1

O G1 foi homologado com ressalva em 13/08/2026. O endereço textual e o vínculo
territorial São Gerardo/SER 03 foram preservados. Como os quatro documentos, de
ações e horários distintos, compartilham exatamente o mesmo ponto no
Centro/SER 12, suas coordenadas foram consideradas não homologadas e pendentes
de recaptura. Esses documentos não devem alimentar o mapa até nova evidência de
campo. Nenhum RAE foi alterado por essa decisão.

## Sete divergências somente de bairro

- quatro documentos de Passaré possuem pontos em Itaperi ou Serrinha, todos na
  SER 08;
- RAE `0025/2026`, Meireles, possui ponto no Mucuripe, ambos na SER 02;
- RAE `0027/2026`, Manuel Dias Branco, possui ponto na Praia do Futuro I, ambos
  na SER 07;
- RAE `0029/2026`, Tauape, possui ponto no Joaquim Távora, ambos na SER 02.

### Homologação humana do G2

O G2 foi homologado com ressalva em 13/08/2026. Os quatro documentos de Passaré
foram reconhecidos como registros de teste sem evidência territorial suficiente.
Passaré/SER 08 foi preservado provisoriamente, mas os documentos ficam excluídos
do mapa e dos indicadores territoriais oficiais até eventual arquivamento ou
exclusão em ciclo próprio. Nenhum RAE foi alterado por essa decisão.

### Homologação humana do G3

O RAE `0025/2026` foi homologado para Mucuripe/SER 02 em 13/08/2026. O endereço
Avenida Beira-Mar, 4400 e a geometria oficial sustentam a correção do bairro.
A Regional não muda. A atualização produtiva permanece pendente de operação
controlada após a conclusão de todos os grupos.

### Homologação humana do G4

O RAE `0027/2026` foi homologado para Praia do Futuro I/SER 07 em 13/08/2026.
A Regional não muda. A atualização produtiva permanece pendente de operação
controlada após a conclusão de todos os grupos.

### Homologação humana do G5

O RAE `0029/2026` foi homologado para Joaquim Távora/SER 02 em 13/08/2026. O
endereço Avenida Pontes Vieira, 133 e a geometria oficial sustentam a correção
do bairro. A Regional não muda. A atualização produtiva permanece pendente de
operação controlada.

### Resultado consolidado da homologação

Os grupos G1 a G5 foram concluídos. Oito documentos ficaram bloqueados para uso
cartográfico — quatro por coordenadas não homologadas e quatro por serem
registros de teste sem evidência territorial. Três RAEs operacionais foram
homologados para correção de bairro: `0025/2026`, `0027/2026` e `0029/2026`.
Nenhuma dessas decisões alterou o Firestore nesta etapa.

## Estado do portão do mapa

Os critérios numéricos de catálogo, cobertura institucional e contenção
municipal foram atendidos. Ainda assim, a ativação do mapa deve permanecer
bloqueada até:

1. homologar as 11 divergências bairro–coordenada;
2. decidir os quatro casos que também mudam de Regional;
3. incorporar a geometria e a atribuição oficial ao aplicativo;
4. testar renderização, privacidade, desempenho e comportamento offline no A05;
5. aprovar explicitamente a funcionalidade cartográfica.

Nenhum RAE foi alterado nesta validação.

## Revalidação após a homologação produtiva

As correções de G3, G4 e G5 foram executadas e verificadas em 13/08/2026. A
revalidação dos 40 RAEs produziu:

| Indicador | Resultado | Percentual |
|---|---:|---:|
| Pontos dentro de Fortaleza | 40/40 | 100% |
| Bairro textual igual ao geométrico | 32/40 | 80% |
| Bairro textual divergente | 8/40 | 20% |
| Regional saneada igual à geométrica | 36/40 | 90% |
| Pontos fora do município | 0/40 | 0% |

As oito divergências remanescentes são exatamente os documentos homologados
com bloqueio cartográfico em G1 e G2. Retirados esses registros sem aptidão
cartográfica, os 32 RAEs elegíveis apresentam coincidência de bairro e Regional
de 32/32 (100%).
