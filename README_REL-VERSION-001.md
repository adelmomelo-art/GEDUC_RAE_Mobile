# REL-VERSION-001 - Versionamento Automatico

## Resultado implementado

A tela de login deixou de utilizar valores manuais de versao, build e ambiente.

Versao do produto:

- version: 1.0.0
- build: 2
- pubspec: 1.0.0+2

A versao e o build sao obtidos por package_info_plus a partir do pacote instalado.

## Ambiente

APP_ENV controla a identificacao da compilacao.

- development -> DESENVOLVIMENTO
- homologacao -> HOMOLOGACAO
- production -> PRODUCAO
- ausente ou invalido -> NAO DEFINIDO

Nao existe ambiente assumido por default.

## Hardcodes removidos

- Versao: 0.30.0
- Build: CE-030
- Ambiente de homologacao
- afirmacao de separacao de dados nao garantida pelo runtime

## Validacoes REL-VERSION-001E

- testes focados: PASS
- regressao Flutter completa: PASS
- flutter analyze: 0 issues
- git diff --check: PASS
- registrants: limpos
- escopo funcional inicial: 7 caminhos
- App Check: preservado
- Storage: preservado
- Firestore: preservado

## Estado de producao

Existe autorizacao institucional do responsavel pelo projeto para avancar na preparacao de producao.

Essa autorizacao nao substitui os bloqueadores tecnicos ainda pendentes no Release Readiness.

Continuam fora desta frente:

- SEC-NEXT-001 - Firebase Storage produtivo
- SEC-NEXT-002 - App Check / Play Integrity produtivo e enforcement
- OBS-REL-001 - validacao visual Unicode do PDF

REL-VERSION-001 nao habilita Storage, nao altera App Check e nao publica o aplicativo.
