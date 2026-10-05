# AGO-001 R3 — correção das dependências npm

Data: 04/10/2026. Base Git: `7c52323896c89e6bec2fbfcc61846c060b4c48ab`.
Status: validações locais aprovadas; homologação funcional e CI remoto pendentes.

## Problema e decisão

O `npm ci` da AGO-001 R2 indicou 27 vulnerabilidades: 13 moderadas e
14 altas. O gate existente `npm run audit:security` retornava erro.
A árvore afetada pertence às ferramentas Node usadas para testes e CLI;
não foi alterado código Dart nem o lockfile Flutter nesta revisão.

Foi mantido `@firebase/rules-unit-testing` em 4.0.1 e atualizado
`firebase-tools` para 15.32.1. As versões diretas ficam fixadas e a árvore
é reproduzida por `package-lock.json`. Não foi usado `npm audit fix --force`.

| Dependência/ajuste | Versão final | Motivo |
| --- | --- | --- |
| `fast-uri` | 3.1.8 | Correção de normalização do host |
| `@grpc/grpc-js` | 1.14.5 | Correções de autenticação/certificados e mensagens |
| `firebase-tools → chokidar` | 4.0.3 | Retira `braces`, sem versão corrigida publicada |
| `firebase-tools → @google-cloud/pubsub` | 6.1.0 | Usa a árvore OpenTelemetry corrigida |
| `get-uri → basic-ftp` | 6.2.2 | Correção do processamento de listagens FTP |
| `gaxios → uuid` | 11.1.1 | Correção de limites de buffers; mantém CommonJS |

Os overrides de CLI, FTP e UUID são restritos aos pais indicados. O override
gRPC cobre as cópias usadas pelo Firebase SDK de teste e pelo CLI.
As demais atualizações transitivas compatíveis estão registradas no lockfile.

## Validação executada

- `npm ci`: PASS.
- `npm run audit:security`: PASS, zero vulnerabilidades.
- Auditoria JSON da árvore/lockfile: zero em todas as severidades.
- `npm run test:rules`: 82 testes PASS, nenhuma falha/skip.
- `npm run test:security:compat`: 3 testes PASS: multipart Gaxios/UUID,
  obtenção de arquivo por FTP local e APIs PubSub usadas pelo CLI.
- `npm run test:rules:watch`: PASS; emulador inicialmente nega leitura,
  recarrega uma regra que permite, depois recarrega a negativa novamente.
- Suítes MIG-001E3/E4/E5/E6: 68 testes PASS.
- `git diff --check`: PASS.
- Código Dart da R2: hashes preservados. Analyze sem apontamentos,
  1.145 testes Flutter e build web aprovados na R2 continuam referentes
  ao mesmo código Dart; a R3 não modifica essas fontes.

O workflow inclui os novos testes de compatibilidade e de recarga após a
regressão Firestore. Não foram desativados o audit nem os limites de severidade.
Alertas de pacotes descontinuados podem continuar aparecendo no npm;
o resultado da auditoria de vulnerabilidades é uma verificação distinta.

## Aplicação e homologação

O pacote integral R3 aceita a base limpa ou exatamente a AGO-001 R2 aplicada.
No estado R2, exige a lista original de 30 arquivos e seus hashes normalizados
somente para LF/CRLF. Alterações locais adicionais são rejeitadas.
O instalador faz backup dos arquivos que substituirá e restaura a situação
anterior se houver falha. Não executa commit, push ou deploy.

Depois da aplicação:

```powershell
npm ci
npm run audit:security
npm run test:security:compat
npm run test:rules
npm run test:rules:watch
npm run test:migration:mig001e3
npm run test:migration:mig001e4
npm run test:migration:mig001e5
npm run test:migration:mig001e6
git diff --check
git status --short --untracked-files=all
```

O teste de recarga usa somente `demo-geduc-ago001-watch` no emulador local,
com configuração e regras temporárias. Execute após o teste de regras,
para já ter o binário do emulador disponível, com Java 21 e porta 8080 livre.
O processo de teste não herda proxy HTTP/HTTPS: o CLI aplica proxy até a
requisições de loopback e este teste precisa comunicar com o emulador diretamente.
Não são alteradas configurações permanentes de proxy do usuário.

Overrides que atravessam versão principal exigem acompanhamento das próximas
versões do Firebase CLI. Validamos a suíte Firestore usada no projeto e as
interfaces substituídas. Deploy de Functions, Storage e outros serviços do CLI
não foi homologado nesta revisão; remova overrides quando os pais incorporarem
as versões corrigidas e repita os testes.

Após as validações, seguir o roteiro funcional de
`AGO-001_AGENDA_OPERACIONAL.md` em ambiente isolado. O `main.dart` atual
inicializa o Firebase pelas opções normais do aplicativo; a preparação de
emulador/login para homologação interativa é etapa própria antes de cadastrar
dados de teste. Nenhum deploy ou mudança em dados produtivos foi realizado.

## Fontes primárias consultadas

- https://github.com/grpc/grpc-node/security/advisories/GHSA-m9gg-hp2v-232j
- https://github.com/fastify/fast-uri/security/advisories/GHSA-hrr3-gc8f-f4qj
- https://github.com/advisories/GHSA-vfj7-8cjw-p6xm
- https://github.com/paulmillr/chokidar
- https://github.com/advisories/GHSA-c475-qrg2-pj4r
- https://github.com/open-telemetry/opentelemetry-js/security/advisories/GHSA-8988-4f7v-96qf
- https://github.com/uuidjs/uuid/security/advisories/GHSA-w5hq-g745-h8pq

A versão de cada pacote foi conferida no registro npm. As evidências completas
estão no pacote, incluindo o relatório anterior e o posterior.

## R4 — aprovações de scripts sincronizadas com o lockfile

A homologação Windows da R3 detectou `ESTRICTALLOWSCRIPTS`: o lockfile
resolve protobufjs 7.6.6 e re2 1.27.0, mas allowScripts ainda aprovava
7.6.5 e 1.26.1. `approve-scripts` retornou Nothing to approve nesse ambiente.
A R4 substitui somente esses dois pins de aprovação no package.json.
Mantém a política estrita, a negativa de fsevents e todas as dependências
e hashes do package-lock.json. Não libera scripts globalmente.

Validar `npm ci --strict-allow-scripts`, auditoria e compatibilidade.
As regras e o código Dart não mudaram da R3. Os 82 testes de regras e
a recarga pelo CLI foram aprovados no Windows na R3; repetir após npm ci.

O instalador R4 aceita a R3 integral já aplicada (35 arquivos) ou a base
limpa original; rejeita arquivos extras e modificações não reconhecidas.
