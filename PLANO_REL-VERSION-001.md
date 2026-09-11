# PLANO REL-VERSION-001

## Etapas

1. Confirmar baseline e branch.
2. Auditar versao e ambiente hardcoded.
3. Atualizar versao para 1.0.0+2.
4. Promover package_info_plus para dependencia direta.
5. Criar contrato AppEnvironmentConfig.
6. Criar AppBuildInfo.
7. Integrar versao, build e ambiente dinamicos na LoginPage.
8. Criar testes focados.
9. Executar regressao Flutter completa.
10. Executar flutter analyze com zero issues.
11. Auditar escopo Git.
12. Gerar CPB.
13. Homologar visualmente APK identificado como homologacao.
14. Gerar candidato produtivo somente apos validacoes previstas.
15. Commit, push, PR, Quality Gates, merge e pos-merge.

## Contrato de build

Homologacao:

flutter build apk --release --dart-define=APP_ENV=homologacao

Producao:

flutter build apk --release --dart-define=APP_ENV=production

## Criterios

- version 1.0.0+2
- APP_ENV centralizado
- fallback NAO DEFINIDO
- ausencia de 0.30.0 e CE-030 no runtime
- package_info_plus como dependencia direta
- testes focados aprovados
- regressao Flutter aprovada
- flutter analyze com 0 issues
- git diff --check aprovado
- registrants fora do escopo
