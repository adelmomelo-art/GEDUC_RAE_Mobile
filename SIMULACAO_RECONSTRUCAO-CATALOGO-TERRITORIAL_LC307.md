# Simulação da reconstrução do catálogo territorial — LC nº 307/2021

## Resultado

A substituição integral das listas de bairros das 12 Regionais foi simulada
contra o estado atual do Firestore. Nenhuma chamada de escrita foi executada.

## Controles

- 12 documentos lidos e incluídos no backup;
- 12 IDs documentais preservados;
- nome e estado ativo validados antes da proposta;
- comparação bairro a bairro por nome normalizado;
- 121 bairros oficiais no resultado;
- 121 nomes únicos;
- 12 Regionais e 39 territórios;
- zero duplicidades após a substituição.

## Comparação geral

| Indicador | Quantidade |
|---|---:|
| Entradas atuais | 105 |
| Entradas corretas preservadas | 72 |
| Entradas incorretas ou malformadas removidas | 33 |
| Bairros oficiais adicionados | 49 |
| Entradas oficiais após substituição | 121 |

## Resultado por Regional

| SER | Antes | Depois | Preservados | Adicionados | Removidos |
|---|---:|---:|---:|---:|---:|
| SER 01 | 9 | 10 | 8 | 2 | 1 |
| SER 02 | 10 | 11 | 7 | 4 | 3 |
| SER 03 | 12 | 13 | 11 | 2 | 1 |
| SER 04 | 12 | 13 | 11 | 2 | 1 |
| SER 05 | 4 | 5 | 2 | 3 | 2 |
| SER 06 | 12 | 15 | 4 | 11 | 8 |
| SER 07 | 10 | 11 | 8 | 3 | 2 |
| SER 08 | 8 | 9 | 4 | 5 | 4 |
| SER 09 | 8 | 7 | 0 | 7 | 8 |
| SER 10 | 10 | 11 | 9 | 2 | 1 |
| SER 11 | 7 | 13 | 6 | 7 | 1 |
| SER 12 | 3 | 3 | 2 | 1 | 1 |

## Campos propostos

Em cada documento de Regional, a futura operação alterará somente:

- `bairrosVinculados`;
- `codigoRegiao`;
- `territorios`;
- `fonteLegal`;
- `fonteCadastral`;
- `versaoCatalogo`;
- `vigenteDesde`;
- `atualizadoEm`.

Nome, ID documental, tipologia, estado ativo e demais campos serão preservados.

## Backup e plano local

- backup: `BACKUP_REGIONAIS_PRE_LC307_2026-08-13T21-48-10-350Z.json`;
- SHA-256 do backup:
  `F5603D29B9EE1DCE032EC29D374590098C1AE50A50A0C0C2C00B6D8EBB9C50BB`;
- plano de simulação: `PLANO_REGIONAIS_LC307_2026-08-13T21-48-10-350Z.json`;
- SHA-256 do plano:
  `CCBFA13E5E49424CAEEEADBD66D2EDA47EF963F9FFC7575E5CACFAF15E4D0955`.

Os arquivos permanecem em `work/`, fora do Git, porque contêm cópia do estado
operacional dos documentos.

## Portão para execução

A simulação está tecnicamente apta para revisão. A escrita em produção dependerá
de autorização específica e deverá usar a versão (`updateTime`) capturada no
backup como pré-condição, interrompendo a operação se qualquer Regional mudar.
