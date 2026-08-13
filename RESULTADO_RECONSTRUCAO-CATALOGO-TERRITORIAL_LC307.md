# Resultado da reconstrução do catálogo territorial — LC nº 307/2021

## Execução

- data: 13/08/2026;
- ambiente: Firestore de produção — `geduc-rae-mobile`;
- documentos atualizados: 12 Regionais;
- estratégia: transação atômica com pré-condição de versão;
- documentos criados ou excluídos: nenhum;
- IDs documentais e nomes das Regionais: preservados.

## Campos atualizados

- `bairrosVinculados`;
- `codigoRegiao`;
- `territorios`;
- `fonteLegal`;
- `fonteCadastral`;
- `versaoCatalogo`;
- `vigenteDesde`;
- `atualizadoEm`.

## Verificação independente

| Portão | Resultado |
|---|---:|
| Documentos de Regional | 12 |
| Entradas de bairro | 121 |
| Nomes únicos | 121 |
| Vínculos exatos com a matriz oficial | 121 |
| Bairros na Regional errada | 0 |
| Entradas não oficiais | 0 |
| Bairros oficiais ausentes | 0 |
| Duplicidades entre Regionais | 0 |
| Territórios | 39 |

## Resultado por Regional

| SER | Bairros | Territórios | Código da região |
|---|---:|---|---|
| SER 01 | 10 | 2–6 | II |
| SER 02 | 11 | 7–10 | III |
| SER 03 | 13 | 11–14 | IV |
| SER 04 | 13 | 15–18 | V |
| SER 05 | 5 | 39 | XII |
| SER 06 | 15 | 26–30 | VIII |
| SER 07 | 11 | 22–25 | VII |
| SER 08 | 9 | 19–21 | VI |
| SER 09 | 7 | 31–33 | IX |
| SER 10 | 11 | 34–35 | X |
| SER 11 | 13 | 36–38 | XI |
| SER 12 | 3 | 1 | I |

## Backup

- arquivo local:
  `BACKUP_REGIONAIS_IMEDIATO_PRE_EXECUCAO_2026-08-13T21-51-16-837Z.json`;
- SHA-256:
  `D1416F287AAE3A9537C6F39168BC5BAF38B26F11F3D27023757D24B07E091B91`;
- localização: `work/`, fora do Git.

## Diagnóstico dos RAEs após a reconstrução

- RAEs avaliados: 40;
- válidos: 7;
- legados sem ID: 31;
- divergentes: 2;
- fila consultiva: 33;
- coordenadas utilizáveis: 40;
- conflitos do catálogo: 0.

Os dois registros divergentes detectados são:

- RAE `0033/2026`: Itaperi informado como SER 09; oficial SER 08;
- RAE `0034/2026`: São Gerardo informado como SER 05; oficial SER 03.

Nenhum RAE foi alterado durante a reconstrução do catálogo.

## Estado

O catálogo territorial está reconstruído e atende integralmente aos portões
estruturais da LC nº 307/2021. O mapa continua bloqueado porque o saneamento dos
RAEs e a validação municipal das coordenadas ainda não foram concluídos.
