# Plano de Implementacao PV-007B-R2 - Responsividade Multidispositivo

## 1. Condicoes de entrada

- worktree `C:\Projetos\GEDUC_RAE_Mobile_PV007B` existente;
- branch `feature/pv-007b-home-operacional-compacta` ativa;
- checkpoint CP-007B confirmado;
- implementacao PV-007B-R1 presente e ainda nao integrada a `main`;
- testes R1 aprovados: 8 testes;
- `flutter analyze` R1: zero issues;
- APK R1 aprovado no Tab S6;
- evidencia do truncamento recebida do Galaxy A05;
- cores PMF 2025 reservadas para intervencao posterior;
- Aribau Grotesk pausada ate recebimento oficial da fonte.

## 2. Fase 1 - confirmacao do worktree

Executar:

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile_PV007B
git branch --show-current
git rev-parse --short HEAD
git status --short
```

Confirmar a branch e preservar todas as alteracoes da R1. Nao executar
`git restore` sobre arquivos funcionais da Home.

## 3. Fase 2 - token de responsividade

Modificar `home_visual_tokens.dart` para acrescentar:

```dart
static const double headerCompactBreakpoint = 520;
```

Nao modificar cores, espacamentos ou breakpoints existentes.

## 4. Fase 3 - refatoracao do cabecalho

Modificar `centro_operacoes_header.dart`.

### 4.1 Container externo

Preservar:

- gradiente atual;
- raios, sombra e padding;
- callbacks Atualizar e Sair;
- saudacao e mensagem operacional;
- semantica e tooltips.

### 4.2 Selecao de layout

Adicionar `LayoutBuilder` dentro do cabecalho:

```dart
final compact =
    constraints.maxWidth < HomeVisualTokens.headerCompactBreakpoint;
```

### 4.3 Layout compacto

- linha superior: avatar, `Spacer`, Atualizar e Sair;
- titulo institucional em bloco de largura total;
- subtitulo institucional integral;
- saudacao com quebra natural quando necessaria;
- nenhuma reticencia para titulo e subtitulo nas larguras suportadas.

### 4.4 Layout amplo

- identidade envolvida por um unico `Expanded` no ponto de composicao;
- botoes a direita;
- remover o `Spacer` que concorre com a identidade;
- permitir quebra natural sem reticencias em escalas ampliadas;
- manter o comportamento visual aprovado no Tab S6.

### 4.5 Responsabilidade interna

Refatorar `_IdentidadeInstitucional` para nao devolver `Expanded`. O widget
devera representar somente seu conteudo; a decisao de flexao pertencera ao
layout pai.

## 5. Fase 4 - testes automatizados

Ampliar `home_operacional_compacta_test.dart`.

Adicionar importacao de:

```dart
import 'package:flutter/rendering.dart';
```

Adicionar cenarios:

1. cabecalho integral em 320 px e escala 1,0;
2. cabecalho integral em 360 px e escala 1,3;
3. cabecalho integral em 412 px e escala 1,3;
4. tablet de 800 px preserva layout horizontal;
5. Atualizar executa exatamente um callback;
6. Sair executa exatamente um callback;
7. `RenderParagraph.didExceedMaxLines` falso para titulo e subtitulo;
8. nenhuma excecao de renderizacao.
9. reflow vertical abaixo de 520 px e composicao horizontal em 800 px.

Os testes existentes da R1 permanecerao ativos.

## 6. Fase 5 - validacao tecnica

Executar no worktree:

```powershell
dart format `
  .\lib\modules\home\theme\home_visual_tokens.dart `
  .\lib\modules\home\widgets\centro_operacoes_header.dart `
  .\test\modules\home\widgets\home_operacional_compacta_test.dart

flutter test `
  .\test\modules\home\widgets\home_operacional_compacta_test.dart

flutter analyze
git diff --check
git status --short
```

Resultados obrigatorios:

- testes R1 e R2 aprovados;
- nenhum overflow ou truncamento nos cenarios automatizados;
- `flutter analyze`: `No issues found!`;
- somente arquivos do manifesto presentes no escopo R2.

## 7. Fase 6 - APK de homologacao

Gerar novo APK debug no worktree e copiar para:

```text
%USERPROFILE%\Downloads\FENIX_HOMOLOGACAO\PV-007B-R2
```

O nome devera conter data e hora. Registrar SHA-256 antes da instalacao.

## 8. Fase 7 - homologacao fisica

### HAT-R2.1 - Galaxy A05

- titulo completo;
- subtitulo completo;
- saudacao legivel;
- botoes Atualizar e Sair funcionais;
- Nova Acao e Consultar RAE em uma coluna;
- atalhos secundarios em duas colunas;
- ausencia de corte horizontal;
- rolagem vertical funcional.

### HAT-R2.2 - Samsung Tab S6

- cabecalho permanece horizontal;
- identidade completa;
- botoes alinhados a direita;
- duas acoes primarias lado a lado;
- quatro atalhos secundarios na mesma linha;
- quatro indicadores na mesma linha;
- nenhuma regressao visual.

### HAT-R2.3 - acessibilidade

- repetir A05 com escala de fonte ampliada quando disponivel;
- confirmar ordem de leitura;
- confirmar areas de toque;
- confirmar ausencia de texto institucional truncado.

## 9. Fase 8 - controle Git

Nao executar commit antes da aprovacao dos dois dispositivos.

Apos homologacao:

```powershell
git diff --check
git diff --stat
git diff --name-only
git status --short
```

O commit da R2 podera ser combinado ao commit principal da PV-007B, pois a
branch ainda nao foi integrada. Se for exigido commit separado, usar:

```text
fix(home): adapta cabecalho para telefones e tablets
```

## 10. Rollback

Em caso de regressao:

- manter `main` e checkpoint intocados;
- nao integrar a branch;
- preservar o APK R1 ja homologado no Tab S6;
- restaurar somente os tres arquivos da R2 a partir do pacote anterior;
- nunca utilizar `git reset --hard` ou `git clean -fd`;
- repetir testes e homologacao apos qualquer ajuste.

## 11. Sequencia posterior

Somente depois da homologacao da responsividade:

1. retomar a adequacao cromatica PMF 2025 como PV-007B-R3;
2. produzir nova imagem de aprovacao;
3. aplicar cores apenas no worktree de testes;
4. manter a migracao para Aribau Grotesk pausada.
