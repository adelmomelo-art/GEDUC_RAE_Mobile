# Mapeamento dos IDs documentais das Regionais — LC nº 307/2021

## Resultado

Os 12 documentos ativos existentes no Firestore possuem nomes únicos de SER 01
a SER 12. Seus IDs podem ser preservados durante a reconstrução, evitando quebrar
os RAEs que já apontam para essas identidades.

| SER | ID documental preservado | Código da região | Territórios oficiais | Bairros atuais | Bairros oficiais |
|---|---|---|---|---:|---:|
| SER 01 | `36bf7d6a-10c9-4472-a031-aa82936f6b09` | II | 2, 3, 4, 5 e 6 | 9 | 10 |
| SER 02 | `d752e701-6d9b-4447-ba3a-01dd6248943f` | III | 7, 8, 9 e 10 | 10 | 11 |
| SER 03 | `db1ace32-b277-4c98-a1c3-dd492856da8a` | IV | 11, 12, 13 e 14 | 12 | 13 |
| SER 04 | `426156be-552b-4f31-b620-58fd10f3ef76` | V | 15, 16, 17 e 18 | 12 | 13 |
| SER 05 | `825683b4-2f1b-4620-a230-a76fc87e1f7c` | XII | 39 | 4 | 5 |
| SER 06 | `c8a6d75c-8d51-4990-9526-b05e96e4acec` | VIII | 26, 27, 28, 29 e 30 | 12 | 15 |
| SER 07 | `1bc519eb-96bd-40e3-ae64-1bbb21eef2f4` | VII | 22, 23, 24 e 25 | 10 | 11 |
| SER 08 | `4e5ec378-b081-45be-83db-8a3f6b0bd3b6` | VI | 19, 20 e 21 | 8 | 9 |
| SER 09 | `2de1de16-27e4-4d19-ac3e-3d46e3764a94` | IX | 31, 32 e 33 | 8 | 7 |
| SER 10 | `4d6c1ef8-25d5-4652-8843-a5bf3134579a` | X | 34 e 35 | 10 | 11 |
| SER 11 | `71652f7d-737a-4976-8e42-ca32f2cfb063` | XI | 36, 37 e 38 | 7 | 13 |
| SER 12 | `5dc0a523-f787-4804-9a1b-d6d877f5a42d` | I | 1 | 3 | 3 |

## Observação sobre os códigos

O campo “Código da região” do IPLANFOR usa algarismos romanos da Região
Administrativa e não é numericamente igual ao nome da SER em todos os casos.
Exemplos: SER 12 possui código I; SER 01 possui código II; SER 05 possui código
XII. Os dois valores devem ser armazenados separadamente.

## Estratégia aprovada para os IDs

- não criar novos documentos de Regional;
- não renomear IDs documentais;
- preservar `nomeRegional` como SER 01 a SER 12;
- substituir integralmente apenas `bairrosVinculados` pela lista oficial;
- adicionar código, territórios, fonte, versão e vigência;
- usar os IDs acima na futura coleção canônica de bairros e no saneamento dos
  RAEs.

## Portões verificados

- 12 nomes de SER únicos;
- 12 IDs documentais únicos;
- nenhuma Regional ativa ausente;
- nenhuma Regional ativa excedente;
- correspondência completa SER–ID pronta para homologação.

## Limite

Este documento é somente preparatório. Nenhum documento do Firestore foi
alterado.
