# PV-007B-R2 - Responsividade Multidispositivo

## Estado

Intervencao corretiva autorizada em 04/08/2026 apos homologacao da Home
Operacional Compacta em dois dispositivos fisicos.

| Campo | Valor |
| --- | --- |
| Baseline Git | `2155ea8` |
| Branch | `feature/pv-007b-home-operacional-compacta` |
| Worktree | `C:\Projetos\GEDUC_RAE_Mobile_PV007B` |
| Checkpoint | `checkpoint/pv-007b-pre-implementacao-2155ea8` |
| Origem | PV-007B - Home Operacional Compacta |
| Dispositivo aprovado | Samsung Tab S6 |
| Dispositivo com nao conformidade | Samsung Galaxy A05 |
| Estado | Implementacao R2 preparada; validacao local e homologacao pendentes |

## Objetivo

Corrigir a adaptacao do cabecalho institucional da Home para telefones, sem
reduzir artificialmente a fonte, sem remover conteudo e sem alterar a
composicao homologada para tablets.

## Evidencia

No Galaxy A05, o cabecalho apresentou:

- `Centro de O...` no lugar de `Centro de Operacoes Educativas`;
- `Platafo...` no lugar de `Plataforma Fenix - GEDUC`;
- concorrencia de largura entre identidade, `Spacer` e botoes fixos;
- ausencia de teste automatizado do cabecalho em largura de telefone.

Os atalhos principais e secundarios, o card da Faixita e a estrutura vertical
nao apresentaram evidencia de overflow horizontal na captura recebida.

## Escopo

- adaptar `CentroOperacoesHeader` por largura util;
- criar breakpoint exclusivo do cabecalho;
- preservar alvos de toque de 48 x 48 px;
- permitir reflow vertical em telefone;
- adicionar testes em 320, 360, 412 e 800 px;
- validar escala de texto 1,0 e 1,3;
- homologar novamente no Galaxy A05 e no Tab S6.

## Fora do escopo

- adequacao cromatica PMF 2025;
- migracao para Aribau Grotesk;
- alteracao global de `AppTheme` ou `AppColors`;
- mudanca de controllers, services, models, rotas ou permissoes;
- alteracao dos demais componentes sem evidencia reproduzida;
- commit, push ou Pull Request antes da homologacao fisica.

## Criterio de saida

A R2 somente podera ser aprovada quando:

1. todos os textos institucionais forem apresentados sem truncamento no A05;
2. o Tab S6 preservar a composicao horizontal homologada;
3. os botoes permanecerem acessiveis e funcionais;
4. os testes especificos forem aprovados;
5. `flutter analyze` retornar `No issues found!`;
6. o APK de teste for homologado nos dois dispositivos.
