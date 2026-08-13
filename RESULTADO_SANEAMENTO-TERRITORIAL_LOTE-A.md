# Resultado do saneamento territorial — Lote A

> **Resultado parcialmente revertido em 13/08/2026.** Após identificação de
> inconsistência entre o catálogo do aplicativo e a regionalização oficial
> vigente, 18 dos 22 vínculos foram removidos. O estado final válido está
> registrado na seção “Correção posterior”.

## Execução

- data: 13/08/2026;
- ambiente: Firestore de produção do projeto `geduc-rae-mobile`;
- escopo: 22 RAEs homologados humanamente;
- campo alterado: somente `regionalId`;
- documentos criados ou excluídos: nenhum;
- demais campos modificados: nenhum.

## Controles aplicados

1. conferência de ID técnico, número do RAE, regional nominal e bairro;
2. confirmação de que o `regionalId` permanecia vazio;
3. backup lógico anterior à escrita;
4. pré-condição pelo `updateTime` de cada documento;
5. seis commits pequenos, agrupados por regional;
6. leitura individual pós-escrita dos 22 documentos;
7. reexecução independente do diagnóstico agregado.

## Resultado dos blocos

| Bloco | Regional | RAEs atualizados | Resultado |
|---:|---|---:|---|
| 1 | SER 09 | 13 | Verificado |
| 2 | SER 05 | 1 | Verificado |
| 3 | SER 06 | 1 | Verificado |
| 4 | SER 07 | 2 | Verificado |
| 5 | SER 10 | 1 | Verificado |
| 6 | SER 02 | 4 | Verificado |
| **Total** |  | **22** | **22 verificados** |

## Comparação antes e depois

| Indicador — janela fixa de 12 meses | Antes | Depois |
|---|---:|---:|
| RAEs avaliados | 40 | 40 |
| Identidade territorial válida | 5 | 27 |
| Cobertura institucional | 12,5% | 67,5% |
| Registros legados | 35 | 13 |
| Fila consultiva | 35 | 13 |
| Coordenadas utilizáveis | 40 | 40 |
| IDs órfãos | 0 | 0 |
| Referências a regionais inativas | 0 | 0 |
| Conflitos de bairro no catálogo | 8 | 8 |

## Pendências preservadas

- 13 RAEs continuam dependendo de decisão institucional;
- quatro estão relacionados a bairros ambíguos;
- nove utilizam bairros ausentes do catálogo ativo;
- oito RAEs continuam sem número operacional;
- oito conflitos permanecem no catálogo;
- o limite municipal oficial ainda não foi integrado.

## Portão territorial

O mapa permanece bloqueado. A cobertura institucional da janela fixa chegou a
67,5%, ainda abaixo do mínimo de 95%, e o catálogo continua com oito conflitos,
quando o critério exige zero.

## Backup e reversibilidade

Os backups lógicos foram mantidos somente na área local `work/`, fora do Git,
por conterem identificadores operacionais. Eles sustentaram a reversão parcial
descrita a seguir.

## Correção posterior — catálogo territorial inconsistente

Durante a abertura do Lote B foi identificado que o catálogo de regionais não
representa corretamente a divisão oficial vigente. A execução original não foi
usada como base para novos lotes.

Com autorização específica, foram removidos preventivamente os `regionalId` de:

- 13 RAEs de Itaperi vinculados à SER 09;
- um RAE de Jangurussu vinculado à SER 06;
- quatro RAEs de Meireles vinculados à SER 02.

A validação posterior da LC nº 307/2021 e do arquivo oficial do IPLANFOR
confirmou que Meireles pertence à SER 02. Assim, 14 vínculos eram efetivamente
incompatíveis; os quatro de Meireles foram removidos por cautela e deverão ser
restaurados somente após a homologação do catálogo reconstruído.

Foram preservados quatro vínculos compatíveis com a fonte oficial:

- Granja Lisboa / SER 05;
- Edson Queiroz / SER 07;
- Manuel Dias Branco / SER 07;
- Jardim Cearense / SER 10.

### Estado final após reversão

| Indicador | Resultado |
|---|---:|
| RAEs avaliados | 40 |
| Identidade territorial válida | 9 |
| Cobertura institucional | 22,5% |
| Registros legados | 31 |
| Fila consultiva | 31 |
| Coordenadas utilizáveis | 40 |
| Conflitos de bairro | 8 |

Os 18 documentos foram verificados individualmente após a remoção preventiva. O próximo
passo obrigatório é substituir o catálogo pelo mapeamento oficial antes de
retomar qualquer saneamento de RAEs.
