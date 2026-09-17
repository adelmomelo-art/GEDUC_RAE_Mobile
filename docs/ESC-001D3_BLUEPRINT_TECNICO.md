# ESC-001D.3 — BLUEPRINT TÉCNICO
## Consulta da Escala GEDUC

**Baseline:** `4b1902fa80708ac330b11d94c85aa3f37e4112a3`
**Dependências fechadas:** ESC-001D.1 e ESC-001D.2
**Escopo:** consulta operacional, sem edição

## Objetivo

Entregar a primeira interface utilizável da Escala GEDUC, preservando a
separação entre consulta, gestão e execução.

A tela deve permitir:

- navegar por data;
- alternar entre `Escala completa` e `Minha Escala`;
- consultar somente conteúdo publicado;
- visualizar status e versão;
- visualizar jornadas 180H/240H apenas como referência informativa;
- visualizar QTR e QTH como conceitos distintos;
- visualizar coordenador e equipe;
- visualizar jornada normal, hora extra e banco de horas;
- visualizar compensações, férias e folgas;
- funcionar em celular, tablet e desktop.

## Segurança

Todos os perfis reconhecidos pela ACL específica da Escala podem consultar.
A rota `/escala` usa `EscalaAccessPolicy`, sem ampliar `Permission` global.

A tela de consulta não expõe o conteúdo de escala em rascunho. Quando existe
rascunho para o dia, apresenta apenas o estado "ainda não publicada".

## Dados

A leitura usa as coleções já fechadas na ESC-001C:

```text
escalas
escala_atividades
escala_alocacoes
escala_indisponibilidades
```

A consulta suporta o futuro ID determinístico `yyyy-MM-dd`, mas mantém fallback
por campo `data`, evitando quebrar registros anteriores.

## Minha Escala

`Minha Escala` é filtro da mesma tela, não uma segunda fonte de verdade.

Uma atividade pertence à Minha Escala quando o UID autenticado aparece como:

- coordenador;
- participante snapshot; ou
- alocação canônica da atividade.

Dentro do card, a equipe completa continua visível, porque o agente possui
direito de leitura da escala publicada inteira.

## Responsividade

```text
mobile     -> 1 card por linha
tablet     -> 2 cards por linha
desktop    -> 3 cards por linha
```

## Fora do escopo

- criar/editar/publicar escala;
- selecionar equipe;
- classificação interativa de segunda jornada;
- execução;
- RAE automático;
- PDF oficial;
- histórico consolidado.

Esses itens seguem em ESC-001D.4 em diante.
