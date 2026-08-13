# Blueprint — reconstrução do catálogo territorial oficial

## Homologação

Blueprint e matriz oficial homologados em 13/08/2026. A aprovação autoriza a
preparação técnica e a validação dos IDs documentais, mas não constitui
autorização de escrita no Firestore.

## Princípios

- fonte normativa: LC nº 307/2021;
- fonte cadastral: IPLANFOR — Bairros de Fortaleza;
- preservar os IDs dos 12 documentos de Regional;
- um bairro por item, com nome oficial;
- nenhuma inferência baseada em proximidade ou nome legado;
- migração reversível, auditável e homologada por etapas.

## Camada de compatibilidade

Os documentos atuais de `regionais` continuarão oferecendo
`bairrosVinculados` como lista de strings, para não quebrar telas existentes.
Essa lista será reconstruída integralmente com os nomes oficiais e sem
duplicidades.

Metadados mínimos propostos em cada Regional:

- `codigoRegiao`;
- `territorios`;
- `fonteLegal`;
- `fonteCadastral`;
- `versaoCatalogo`;
- `vigenteDesde`;
- `atualizadoEm`.

## Camada canônica de bairros

Como o modelo atual não comporta código e território por bairro, propõe-se uma
coleção canônica `bairros`, com 121 documentos identificados pelo código oficial:

- `codigoBairro`;
- `codigoIbge`;
- `nome`;
- `nomeNormalizado`;
- `regionalId`;
- `regionalNome`;
- `codigoRegiao`;
- `territorio`;
- `fonte`;
- `vigenteDesde`;
- `ativo`.

A criação dessa coleção e eventual ajuste das regras do Firestore dependerão de
aprovação específica após a homologação da matriz.

## Etapas

1. Homologar a matriz oficial de 121 bairros e 12 Regionais.
2. Validar a correspondência entre cada SER oficial e o ID documental atual.
3. Gerar backup completo dos 12 documentos de `regionais`.
4. Preparar a substituição condicionada de `bairrosVinculados` e metadados.
5. Propor a coleção canônica `bairros` e as regras mínimas de leitura.
6. Executar primeiro em simulação e validar 121/12/39/0 duplicidades.
7. Escrever em produção somente mediante autorização específica.
8. Reexecutar o diagnóstico dos RAEs e criar novas matrizes de saneamento.

## Portões de qualidade

- 121 códigos e nomes únicos;
- 12 Regionais;
- 39 territórios;
- 100% dos bairros associados a uma única Regional;
- zero strings compostas;
- zero bairros ausentes;
- zero duplicidades;
- 100% dos documentos com fonte, versão e vigência;
- backup e reversão testados antes da escrita.

## Limites

Esta etapa não altera o Firestore, não restaura vínculos de RAEs, não publica a
branch e não libera o mapa.
