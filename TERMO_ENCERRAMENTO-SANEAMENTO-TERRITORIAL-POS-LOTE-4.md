# Termo de encerramento — saneamento territorial pós-CIO Lote 4

## Identificação

- projeto: Projeto Fênix / GEDUC_RAE_Mobile;
- ambiente: Firestore de produção — `geduc-rae-mobile`;
- data de encerramento: 13/08/2026;
- branch documental: `ciclo/saneamento-territorial-pos-lote4`;
- baseline local: `997d9e141ceac2bc6e1f4525fb66085ee1a99014`;
- referência legal e cadastral: Lei Complementar nº 307/2021 e IPLANFOR —
  Bairros de Fortaleza.

## Objeto

Este termo consolida o encerramento do ciclo separado de reconstrução do
catálogo territorial, saneamento dos RAEs, validação geométrica, homologação
humana das divergências e correções produtivas autorizadas após o CIO Lote 4.

O encerramento deste ciclo não autoriza, por si só, a ativação do mapa no
aplicativo nem a publicação da branch.

## Execuções concluídas

### 1. Catálogo territorial

- 12 documentos de Regionais reconstruídos no Firestore;
- 121 bairros oficiais, todos únicos e vinculados à Regional correta;
- 39 territórios;
- zero bairros ausentes, duplicados, não oficiais ou na Regional errada;
- IDs e nomes documentais das Regionais preservados;
- operação atômica com backup e pré-condições de versão.

### 2. Saneamento cadastral dos RAEs

- 40 RAEs avaliados na janela consultiva;
- 33 RAEs saneados nas trilhas A, B e C;
- 33/33 verificados individualmente;
- cobertura institucional elevada de 17,5% para 100%;
- legados, divergentes, órfãos, inativos, ambíguos e não resolvidos: zero;
- fila consultiva territorial: zero.

### 3. Validação geométrica

- fonte: GeoJSON oficial “Bairros de Fortaleza”, IPLANFOR;
- 121 geometrias, CRS EPSG:4326;
- 40/40 coordenadas dentro do município;
- nenhum ponto fora de Fortaleza ou contido em múltiplos bairros;
- 11 divergências iniciais submetidas à homologação humana.

### 4. Homologação humana G1–G5

- G1: quatro documentos preservados em São Gerardo/SER 03; coordenadas não
  homologadas, pendentes de recaptura e bloqueadas para o mapa;
- G2: quatro registros de teste preservados provisoriamente em Passaré/SER 08,
  excluídos do mapa e dos indicadores territoriais oficiais;
- G3: RAE `0025/2026` homologado e corrigido para Mucuripe/SER 02;
- G4: RAE `0027/2026` homologado e corrigido para Praia do Futuro I/SER 07;
- G5: RAE `0029/2026` homologado e corrigido para Joaquim Távora/SER 02.

### 5. Correções produtivas finais

G3, G4 e G5 foram corrigidos em uma única transação atômica. Somente o campo
`bairro` foi alterado. `regional`, `regionalId`, coordenadas e todos os demais
campos foram preservados. Os três documentos foram relidos e aprovados após a
gravação.

## Portões finais

| Portão | Resultado | Estado |
|---|---:|---|
| Catálogo oficial | 121/121 bairros | Aprovado |
| Conflitos do catálogo | 0 | Aprovado |
| Cobertura institucional | 40/40 | Aprovado |
| Fila consultiva territorial | 0 | Aprovado |
| Coordenadas dentro de Fortaleza | 40/40 | Aprovado |
| RAEs cartograficamente elegíveis | 32/40 | Qualificado |
| Coerência entre os RAEs elegíveis | 32/32 | Aprovado |
| Documentos bloqueados por G1/G2 | 8 | Ressalva controlada |

## Backups e recuperação

| Etapa | Arquivo local em `work/` | SHA-256 |
|---|---|---|
| Regionais | `BACKUP_REGIONAIS_IMEDIATO_PRE_EXECUCAO_2026-08-13T21-51-16-837Z.json` | `D1416F287AAE3A9537C6F39168BC5BAF38B26F11F3D27023757D24B07E091B91` |
| 33 RAEs | `BACKUP_RAES_PRE_SANEAMENTO_LC307_2026-08-13T22-07-29-090Z.json` | `8557D25B2083303E334642593C1ECDCD56740CE99EA06C596C1DFC3945F595C3` |
| G3–G5 | `BACKUP_HOMOLOGACAO_GEOMETRICA_G3_G5_2026-08-13T23-19-53-625Z.json` | `C921C138A7460EEE2C3294BD7495B2C35E297C935C1CCF2AB8A5E9E69075D77D` |

Os backups contêm dados operacionais e permanecem fora do Git. Qualquer reversão
deve ser autorizada e usar pré-condições contra a versão vigente dos documentos.

## Ressalvas transferidas para ciclos próprios

1. recapturar as coordenadas dos quatro documentos de G1 antes de qualquer uso
   cartográfico;
2. avaliar arquivamento ou exclusão controlada dos quatro registros de teste de
   G2;
3. tratar os oito documentos sem número operacional sem criar ou inferir
   numeração automaticamente;
4. implementar no aplicativo a exclusão explícita de G1/G2 dos mapas e
   indicadores territoriais;
5. incorporar atribuição da fonte oficial e validar privacidade, desempenho,
   comportamento offline e renderização no Samsung A05 antes de ativar o mapa.

## Declaração de encerramento

O ciclo de reconstrução e saneamento territorial pós-CIO Lote 4 está
tecnicamente concluído, com os portões cadastrais e geométricos aprovados dentro
do escopo homologado. As oito exceções remanescentes estão identificadas,
justificadas e segregadas do uso cartográfico.

O mapa permanece bloqueado até que as ressalvas de integração e homologação no
aplicativo sejam tratadas em ciclo independente. Commit, push, pull request e
publicação não integram este encerramento e dependem de autorização específica.
