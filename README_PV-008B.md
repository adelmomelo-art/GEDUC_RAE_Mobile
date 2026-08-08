# PV-008B — Fundação visual compartilhada

## Baseline

- origem: `main`;
- commit: `08a22621af5b05af5db478afcf3355d76b1c44c1`;
- branch: `feature/pv-008b-fundacao-visual`.

## Escopo

- promover o contrato visual homologado na Home PV-007B para `core/theme`;
- manter `HomeVisualTokens` como camada de compatibilidade sem alterar valores;
- alinhar o tema global ao contrato compartilhado;
- disponibilizar shell responsivo e card de seção para migrações posteriores;
- acrescentar testes de equivalência, tema e responsividade.

## Preservado

- Providers, controllers, services, repositories e models;
- rotas, redirects, guardas e permissões;
- dependências do `pubspec.yaml`;
- composição e comportamento dos widgets da Home;
- páginas legadas, ainda aguardando decisão de ciclo de vida.

## Próximo passo

Após homologação desta fundação, iniciar a migração da jornada RAE em pacote
separado. Nenhuma tela de jornada é migrada nesta entrega.

## Homologação

Homologação concluída em 08/08/2026 com o APK debug da branch:

- Samsung Galaxy A05: Login, Home, navegação e escala ampliada aprovados;
- Samsung Tab S6: Login, Home, navegação e escala ampliada aprovados;
- 513 testes automatizados aprovados;
- `flutter analyze`: `No issues found!`;
- APK: 162,53 MB;
- SHA-256: `9AAEBBDFD1D4BD3EFB88B37E454EE0B9616679FE4AB0AAA8715530D741417859`.
