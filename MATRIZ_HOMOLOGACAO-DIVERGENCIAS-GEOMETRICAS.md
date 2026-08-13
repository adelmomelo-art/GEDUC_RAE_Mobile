# Matriz de homologação das divergências geométricas

## Regra

A coordenada não substitui automaticamente o bairro textual. Para cada caso, o
homologador deve decidir se a coordenada representa o local real da ação, se o
bairro textual representa a referência operacional ou se o registro exige
consulta à evidência original.

## Grupo G1 — divergência com mudança de Regional

Quatro documentos sem número informam São Gerardo/SER 03, mas suas coordenadas
caem no Centro/SER 12:

- `d7e75f1c-cddb-4663-8c74-772dccf8d9b5`;
- `0b8bb1dc-05d1-4d7b-ac04-f1b1e68fdb4c`;
- `170bc40a-9691-40c4-b3d0-a3a04874b07f`;
- `54d275ce-1512-4d71-b5de-55dfd8212012`.

**Decisão homologada com ressalva:** preservar São Gerardo/SER 03 nos quatro
documentos. A coincidência exata do ponto geográfico em ações e horários
distintos indica coordenada padrão, reaproveitada ou capturada incorretamente.
As quatro coordenadas ficam classificadas como não homologadas, pendentes de
recaptura e bloqueadas para uso cartográfico. Nenhuma latitude ou longitude deve
ser substituída sem nova evidência de campo.

**Homologação humana:** G1 aprovado com ressalva em 13/08/2026.

## Grupo G2 — Passaré versus Itaperi/Serrinha

Quatro documentos sem número permanecem na SER 08, mas o bairro geométrico não
é Passaré:

- `4366026c-b3bc-4817-bb80-7fd285830bc6`: Itaperi;
- `573231d2-1054-448c-a059-2808904d0993`: Serrinha;
- `851494d7-1a5b-4f4a-860e-64161e07814f`: Itaperi;
- `9822204e-9c4c-45ea-a833-e35c41309cc2`: Itaperi.

**Decisão homologada com ressalva:** preservar provisoriamente Passaré/SER 08.
Os quatro documentos não possuem número operacional e apresentam conteúdo de
teste, endereço ausente, incompleto ou igualmente de teste. Não há evidência
territorial suficiente para substituir o bairro textual pela posição
geométrica. Os registros ficam bloqueados para uso no mapa e nos indicadores
territoriais oficiais, devendo ser avaliados para arquivamento ou exclusão em
ciclo próprio. Nenhum campo deve ser alterado por esta homologação.

**Homologação humana:** G2 aprovado com ressalva em 13/08/2026.

## Grupo G3 — Meireles versus Mucuripe

- RAE `0025/2026`;
- Regional: SER 02 em ambos;
- bairro textual: Meireles;
- bairro geométrico: Mucuripe.

**Decisão homologada:** adotar Mucuripe/SER 02. O endereço Avenida Beira-Mar,
4400 e a posição na geometria oficial sustentam Mucuripe. A Regional permanece
SER 02. A correção produtiva do bairro e do vínculo territorial correspondente
fica reservada para operação controlada após a conclusão dos grupos.

**Homologação humana:** G3 aprovado em 13/08/2026.

## Grupo G4 — Manuel Dias Branco versus Praia do Futuro I

- RAE `0027/2026`;
- Regional: SER 07 em ambos;
- bairro textual: Manuel Dias Branco;
- bairro geométrico: Praia do Futuro I.

**Decisão homologada:** adotar Praia do Futuro I/SER 07. A Regional permanece
SER 07. A correção produtiva do bairro e do vínculo territorial correspondente
fica reservada para operação controlada após a conclusão dos grupos.

**Homologação humana:** G4 aprovado em 13/08/2026.

## Grupo G5 — Tauape versus Joaquim Távora

- RAE `0029/2026`;
- Regional: SER 02 em ambos;
- bairro textual: Tauape;
- bairro geométrico: Joaquim Távora.

**Decisão homologada:** adotar Joaquim Távora/SER 02. O endereço Avenida Pontes
Vieira, 133 e a posição na geometria oficial sustentam Joaquim Távora, enquanto
“Tauape” foi tratado como referência territorial ampla. A Regional permanece
SER 02. A correção produtiva do bairro e do vínculo territorial correspondente
fica reservada para operação controlada.

**Homologação humana:** G5 aprovado em 13/08/2026.

## Encerramento da homologação humana

Os grupos G1 a G5 foram homologados em 13/08/2026:

- G1: quatro documentos preservados em São Gerardo/SER 03, com coordenadas não
  homologadas e bloqueadas para o mapa;
- G2: quatro registros de teste preservados provisoriamente em Passaré/SER 08 e
  excluídos do mapa e dos indicadores territoriais;
- G3: RAE `0025/2026` homologado para Mucuripe/SER 02;
- G4: RAE `0027/2026` homologado para Praia do Futuro I/SER 07;
- G5: RAE `0029/2026` homologado para Joaquim Távora/SER 02.

Somente G3, G4 e G5 exigem correção cadastral produtiva. Esta matriz registra a
decisão humana, mas a execução depende de autorização específica, backup e
pré-condições de versão.

## Execução produtiva

As correções homologadas de G3, G4 e G5 foram executadas em 13/08/2026, em uma
única transação atômica, com backup e pré-condições de versão:

- RAE `0025/2026`: Meireles → Mucuripe;
- RAE `0027/2026`: Manuel Dias Branco → Praia do Futuro I;
- RAE `0029/2026`: Tauape → Joaquim Távora.

Somente o campo `bairro` foi alterado. `regional`, `regionalId`, coordenadas e
demais campos foram preservados e verificados após a gravação.

## Limite remanescente

A execução produtiva ficou limitada às três correções expressamente homologadas
em G3, G4 e G5. G1 e G2 não autorizam alteração cadastral ou de coordenadas e
permanecem sujeitos às ressalvas registradas nesta matriz.
