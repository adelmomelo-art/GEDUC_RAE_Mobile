# BUG-ADMIN-ESCOPO-R1 - Blueprint

Baseline: 14047a4fccaa5e2cad0b175e76fb56f024aa85a8

## Fluxo

1. O administrador lista usuarios.
2. UsuarioService.atualizarEscopo inicia uma transacao.
3. A transacao faz get no usuario alvo.
4. A Rule anterior negava o get quando alvo e administrador eram distintos.
5. O update nunca era avaliado.

## Invariantes

- leitura propria permanece permitida inclusive para conta inativa;
- somente administrador lista e le individualmente outro usuario;
- gestor e demais perfis nao ganham leitura individual;
- update permanece restrito a escopoAcesso, scopeUpdatedAt e scopeUpdatedBy;
- identidade, perfil e estado ativo permanecem imutaveis;
- financeiro permanece fora do escopo.

## Aceite

- transacao administrativa completa no emulador;
- gestor nao le usuario alheio;
- regressao integral das Rules passa;
- Flutter test e analyze passam;
- producao nao e acessada.