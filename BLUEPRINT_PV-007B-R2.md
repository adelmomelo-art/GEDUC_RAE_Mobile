# Blueprint PV-007B-R2 - Responsividade Multidispositivo

| Campo | Valor |
| --- | --- |
| Data | 04/08/2026 |
| Baseline | `2155ea8` |
| Branch | `feature/pv-007b-home-operacional-compacta` |
| Modulo | `lib/modules/home` |
| Alvos | telefone Android e tablet Android em retrato |
| Estado | arquitetura aplicada no pacote R2; homologacao pendente |

## 1. Problema

A PV-007B foi aprovada visualmente no Samsung Tab S6. A homologacao posterior
no Samsung Galaxy A05 revelou truncamento da identidade institucional no
cabecalho.

O comportamento nao caracteriza overflow de renderizacao: o codigo encerra os
textos antecipadamente por meio de `maxLines` e `TextOverflow.ellipsis`. O
resultado e tecnicamente renderizavel, mas funcionalmente incorreto porque o
nome institucional deixa de ser legivel.

## 2. Causa raiz

A linha superior atual contem:

1. `_IdentidadeInstitucional`, que devolve um `Expanded`;
2. um `Spacer`, tambem com flexao;
3. botao Atualizar de 48 px;
4. espacamento de 8 px;
5. botao Sair de 48 px.

O `Expanded` e o `Spacer` dividem igualmente o espaco restante. Em telefone, a
identidade recebe largura insuficiente e os limites de linha produzem
reticencias.

O teste atual cobre indicadores e RAEs em 360 px, mas nao instancia
`CentroOperacoesHeader`. Assim, a regressao visual nao estava protegida.

## 3. Decisao arquitetural

O cabecalho tera duas composicoes internas selecionadas por `LayoutBuilder`.

### 3.1 Composicao compacta

Aplicada abaixo de 520 px de largura util:

1. primeira linha com avatar institucional a esquerda;
2. botoes Atualizar e Sair alinhados a direita;
3. titulo institucional abaixo, usando a largura completa;
4. subtitulo institucional abaixo do titulo;
5. saudacao e mensagem operacional em seguida;
6. crescimento vertical natural conforme escala de texto.

### 3.2 Composicao ampla

Aplicada a partir de 520 px:

1. identidade institucional a esquerda;
2. botoes Atualizar e Sair a direita;
3. ausencia do `Spacer` concorrente;
4. saudacao curta abaixo, como na versao homologada em tablet.

## 4. Breakpoint

Sera criado o token:

```dart
static const double headerCompactBreakpoint = 520;
```

Esse limite e independente de `compactBreakpoint = 420`, utilizado pela grade
de atalhos. A separacao evita alterar componentes que ja responderam
corretamente no A05.

## 5. Regras de tipografia responsiva

- nao utilizar `FittedBox` para comprimir textos institucionais;
- nao reduzir o tamanho da fonte em funcao do aparelho;
- nao desativar a escala de texto do sistema;
- permitir crescimento natural do titulo no modo compacto;
- nao impor `maxLines` que possa ocultar conteudo institucional;
- permitir quebra natural da saudacao compacta quando necessario;
- manter subtitulo integral sem reticencias nas larguras suportadas.

## 6. Acessibilidade

- botoes com dimensao minima de 48 x 48 px;
- tooltips e labels semanticos preservados;
- ordem visual equivalente a ordem de leitura;
- nenhum controle posicionado por coordenada absoluta;
- suporte obrigatorio a escala de texto 1,3;
- escala 1,5 utilizada como teste exploratorio, sem bloquear a entrega se a
  leitura continuar acessivel por reflow e rolagem.

## 7. Matriz de responsividade

| Largura | Referencia | Cabecalho | Acoes primarias | Atalhos |
| ---: | --- | --- | --- | --- |
| 320 px | telefone estreito | compacto vertical | uma coluna | duas colunas |
| 360 px | Galaxy A05 aproximado | compacto vertical | uma coluna | duas colunas |
| 412 px | telefone amplo | compacto vertical | uma coluna | duas colunas |
| 520-719 px | intermediario | horizontal | duas colunas | duas colunas |
| 720 px ou mais | tablet | horizontal | duas colunas | quatro colunas |

## 8. Arquivos da intervencao

### Modificados

- `lib/modules/home/theme/home_visual_tokens.dart`;
- `lib/modules/home/widgets/centro_operacoes_header.dart`;
- `test/modules/home/widgets/home_operacional_compacta_test.dart`.

### Novos

- `README_PV-007B-R2.md`;
- `BLUEPRINT_PV-007B-R2.md`;
- `PLANO_IMPLEMENTACAO_PV-007B-R2.md`;
- `tools/manifestos/PV-007B-R2-RESPONSIVIDADE-MULTIDISPOSITIVO.txt`.

### Preservados

- cores atuais da PV-007B;
- fonte atual do aplicativo;
- `HomePage` e demais widgets da Home;
- controllers, services, models e regras operacionais;
- navegacao dos RAEs e politica de autorizacao.

## 9. Riscos e controles

| Risco | Controle |
| --- | --- |
| aumentar excessivamente a altura do cabecalho | composicao vertical somente abaixo de 520 px |
| regressao no tablet | teste de 800 px e HAT no Tab S6 |
| teste passar apesar de texto truncado | verificar `RenderParagraph.didExceedMaxLines` e textos integrais |
| perda de acessibilidade | manter escala do sistema e alvo de 48 px |
| mudanca acidental de cores | manifesto fechado e revisao por `git diff --name-only` |

## 10. Criterios de aceite

1. titulo e subtitulo institucionais integrais em 320, 360, 412 e 800 px;
2. nenhuma excecao de layout nas escalas 1,0 e 1,3;
3. botoes Atualizar e Sair com 48 px e callbacks preservados;
4. composicao compacta abaixo de 520 px;
5. composicao horizontal a partir de 520 px;
6. nenhuma alteracao cromatica ou tipografica;
7. testes aprovados e `flutter analyze` sem issues;
8. homologacao fisica aprovada no Galaxy A05 e no Tab S6.
