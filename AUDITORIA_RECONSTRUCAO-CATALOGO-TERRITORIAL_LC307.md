# Auditoria da reconstrução do catálogo territorial — LC nº 307/2021

## Fontes oficiais

1. Lei Complementar nº 307, de 13 de dezembro de 2021 — vinculação das 12
   Secretarias Executivas Regionais aos 39 territórios administrativos.
2. IPLANFOR — conjunto “Bairros de Fortaleza”, com 121 bairros, código do
   bairro, código IBGE, Regional atual, código da região e território.
3. Manual Técnico do Orçamento Municipal 2025 — confirmação da regionalização
   administrativa utilizada pela Prefeitura.

## Integridade da fonte oficial

- bairros: 121;
- códigos de bairro únicos: 121;
- nomes normalizados únicos: 121;
- Regionais: 12;
- territórios: 39;
- divergências território–Regional contra a LC nº 307/2021: zero;
- SHA-256 do CSV bruto do IPLANFOR:
  `4AC3848EDAD45BF567A6D7513953B220D0BBD351360767EC04CDBDB19AAD08A3`;
- SHA-256 do CSV canônico derivado:
  `1D0F1D4C62876384A7AA7B5CDD51A37104A69138F9658D47BBF709F9F0BF7E1D`.

## Diagnóstico do catálogo atual no Firestore

| Indicador | Resultado |
|---|---:|
| Documentos de Regional | 12 |
| Entradas de bairro | 105 |
| Nomes normalizados únicos | 97 |
| Vínculos exatos com a fonte oficial | 72 |
| Bairros associados à Regional errada | 11 |
| Entradas compostas, truncadas ou não oficiais | 22 |
| Bairros oficiais ausentes | 43 |
| Nomes duplicados entre Regionais | 8 |

## Associações atuais incompatíveis

- Pedras: SER 06; oficial SER 09;
- Sabiaguaba: SER 06; oficial SER 07;
- Cajazeiras: SER 06; oficial SER 09;
- Barroso: SER 06; oficial SER 09;
- Conjunto Palmeiras: SER 06; oficial SER 09;
- Jangurussu: SER 06; oficial SER 09;
- Serrinha: SER 09; oficial SER 08;
- Dias Macedo: SER 09; oficial SER 08;
- Parque Dois Irmãos: SER 09; oficial SER 08;
- Passaré: SER 09; oficial SER 08;
- Itaperi: SER 09; oficial SER 08.

## Problemas de modelagem observados

- múltiplos bairros armazenados em uma única string;
- pontuação final incorporada ao nome do bairro;
- observações operacionais no nome, como “Itaperi (sua região)”;
- nomes truncados, como “Siqueir”;
- prefixos indevidos, como “Regional 2: Aldeota”;
- omissões de bairros oficiais;
- duplicidade de bairros em Regionais diferentes;
- ausência de código do bairro, território e vigência no modelo atual.

## Correções relevantes para os RAEs já analisados

- Itaperi → SER 08, território 19;
- Meireles → SER 02, território 7;
- Jangurussu → SER 09, território 32;
- Granja Lisboa → SER 05, território 39;
- Edson Queiroz → SER 07, território 25;
- Jardim Cearense → SER 10, território 35;
- Parque Iracema → SER 06, território 28;
- Genibaú → SER 11, território 38;
- Tauape → SER 02, território 10;
- Passaré → SER 08, território 20;
- São Gerardo → SER 03, território 13.

## Conclusão

O catálogo atual não deve ser corrigido pontualmente. A estratégia segura é a
substituição integral das listas de bairros das 12 Regionais pela matriz
canônica, preservando os IDs documentais já existentes e adicionando metadados
de fonte, versão e vigência.

Nenhuma alteração no Firestore foi realizada nesta etapa.
