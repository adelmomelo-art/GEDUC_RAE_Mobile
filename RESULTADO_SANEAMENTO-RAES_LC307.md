# Resultado do saneamento dos RAEs — LC nº 307/2021

## Execução

- data: 13/08/2026;
- ambiente: Firestore de produção — `geduc-rae-mobile`;
- baseline territorial: catálogo homologado com 121 bairros e zero conflitos;
- RAEs saneados: 33;
- estratégia: três transações por trilha, com pré-condição de versão;
- verificação individual: 33 de 33 aprovados.

## Escopo por trilha

| Trilha | Quantidade | Campos autorizados |
|---|---:|---|
| A | 9 | `regionalId` |
| B | 22 | `regionalId` e `regional`; B6 também `bairro` |
| C | 2 | substituição de `regionalId` e `regional` divergentes |
| **Total** | **33** |  |

Em B6, `Parque Genibaú` foi normalizado para o nome oficial `Genibaú`.

## Controles aplicados

1. nova leitura dos 40 RAEs e do catálogo oficial;
2. reconstrução das propostas pela matriz LC nº 307/2021;
3. exigência exata das contagens homologadas: 9/22/2;
4. backup bruto antes da escrita;
5. pré-condição `updateTime` em cada documento;
6. transações separadas para A, B e C;
7. leitura individual dos 33 documentos;
8. comparação de todos os campos não autorizados;
9. reexecução independente do diagnóstico agregado.

## Resultado final

| Indicador | Antes | Depois |
|---|---:|---:|
| RAEs avaliados | 40 | 40 |
| Válidos | 7 | 40 |
| Cobertura institucional | 17,5% | 100% |
| Legados sem ID | 31 | 0 |
| Divergentes | 2 | 0 |
| Órfãos | 0 | 0 |
| Inativos | 0 | 0 |
| Ambíguos | 0 | 0 |
| Não resolvidos | 0 | 0 |
| Fila consultiva | 33 | 0 |
| Conflitos do catálogo | 0 | 0 |
| Coordenadas utilizáveis | 40 | 40 |

## Pendência não territorial

Oito documentos continuam sem número operacional de RAE. Nenhum número foi
criado ou inferido durante este ciclo. Essa lacuna exige tratamento próprio.

## Backup

- arquivo local:
  `BACKUP_RAES_PRE_SANEAMENTO_LC307_2026-08-13T22-07-29-090Z.json`;
- SHA-256:
  `8557D25B2083303E334642593C1ECDCD56740CE99EA06C596C1DFC3945F595C3`;
- localização: `work/`, fora do Git.

## Estado do mapa

O saneamento atingiu 100% de cobertura institucional e zero conflitos de
catálogo. Entretanto, “coordenadas utilizáveis” valida apenas formato e limites
mundiais; ainda falta comprovar que os 40 pontos estão dentro do limite oficial
de Fortaleza. O mapa permanece bloqueado até a aprovação da geometria municipal,
fonte, licença, atribuição e validação espacial.
