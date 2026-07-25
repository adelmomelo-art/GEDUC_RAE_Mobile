# PV-001B / AF-BUG-005 — Persistência da Nova Ação

## Diagnóstico
O `AcaoController` já mantém `acaoAtual` e salva o rascunho. O defeito estava na
`NovaAcaoPage`, que recriava suas variáveis locais sem restaurar os valores do
controlador após retornar da tela de Localização.

## Correção
A tela passa a restaurar:
- data da ação;
- turno;
- nome/tipo da ação;
- ação previamente planejada;
- coordenador responsável;
- resumo e estado da Faxita.

## Substituição
Substituir:
`lib/modules/acoes/nova_acao_page.dart`

## Validação
1. Execute `flutter analyze`.
2. Preencha Nova Ação.
3. Avance para Localização.
4. Volte para Nova Ação.
5. Confirme que todos os dados permanecem preenchidos.
6. Altere um dado, avance novamente e confirme que a alteração foi preservada.
