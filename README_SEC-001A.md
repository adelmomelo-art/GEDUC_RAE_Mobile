# SEC-001A — Publicação Controlada das Regras do Firestore

## Estado

Publicação e homologação remota concluídas e aprovadas sem ressalvas técnicas.
O encerramento documental foi versionado, revisado e integrado à `main` pelo
Pull Request nº 6. A validação pós-merge confirmou a baseline `c8d2d95`, a
sincronização com `origin/main` e a working tree limpa.

## Objetivo

Registrar a preparação, autorização, publicação e homologação da baseline de
segurança do Firestore, preservando a regra remota anterior e consolidando os
controles de interrupção, rollback condicionado e smoke test pós-deploy.

## Baseline e integração

- repositório: `adelmomelo-art/GEDUC_RAE_Mobile`;
- branch de entrada: `main`;
- commit de entrada: `6a6794d`;
- branch da SEC-001A: `security/sec-001a-publicacao-controlada-firestore`;
- commit preparatório: `9da5c94`;
- commit documental de encerramento: `1ba5ba3`;
- Pull Request de encerramento: nº 6;
- merge na `main`: `c8d2d95`;
- branch final: `main`;
- branch da SEC-001A: removida local e remotamente após o merge;
- projeto Firebase: `geduc-rae-mobile`;
- número do projeto: `906308539006`;
- regra candidata: `firestore.rules`;
- Firebase CLI local do projeto: `15.25.1`;
- Firebase CLI global identificado: `15.22.3`;
- Java: `21.0.12`;
- Node.js: `24.18.0`;
- npm: `11.16.0`.

## Evidências

- regra remota publicada em `29/07/2026 às 22:31`, conforme horário exibido
  pelo Console Firebase;
- snapshot remoto: SHA-256
  `9537678D49AD35DB5D8F85F7D976FEF36104D7C9C52546E1EF9F3195F65D6805`;
- regra local candidata: SHA-256
  `8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD`;
- Firebase Emulator Suite: 15 testes, 15 aprovados e 0 falhas;
- CPB da HAT-1: 14/14 arquivos incluídos, zero ausentes e zero comandos com
  falha;
- `flutter analyze` local e no CPB: `No issues found!`;
- autorização expressa registrada para o projeto `geduc-rae-mobile`;
- deploy iniciado em `02/08/2026 às 21:04:30`, UTC-03:00;
- Firebase CLI: compilação, upload e release concluídos com `Deploy complete!`;
- Console Firebase: nova versão confirmada às 21:05;
- comparação remota versus local: `git diff` com exit code `0`;
- smoke test pós-deploy: aprovado sem acesso indevido, tela branca ou exceção;
- `git status`: working tree limpa após a verificação remota.

## Resultado das HATs

### HAT-1

**APROVADA SEM RESSALVAS TÉCNICAS** para a preparação controlada.

A análise confirmou que Blueprint, plano, snapshot, manifesto e evidências
eram consistentes e autorizou o versionamento do pacote preparatório.

### HAT-2

**APROVADA SEM RESSALVAS TÉCNICAS** após revalidação do hash candidato, 15/15
testes, `flutter analyze`, projeto explícito, contas de smoke e procedimento de
rollback. A publicação somente ocorreu após autorização textual do responsável.

## Achado crítico

A regra remota anterior permitia leitura e escrita em qualquer documento para
qualquer conta autenticada. Isso incluía documentos de identidade, perfis,
ações, contadores e coleções não inventariadas.

A baseline publicada substitui a autorização genérica por identidade ativa,
perfil reconhecido, matriz de permissões por coleção e negação por padrão.

## Resultado da publicação

- projeto: `geduc-rae-mobile`;
- escopo remoto: somente `firestore:rules`;
- regra compilada e liberada para `cloud.firestore`;
- fonte remota integralmente comparada com `firestore.rules`;
- administrador ativo com consultas e módulos aprovados;
- gestor, coordenador e agente inativos corretamente bloqueados;
- nenhuma conta inativa acessou dados;
- nenhuma tela branca, exceção ou regressão crítica;
- rollback não indicado.

## Arquivos de encerramento

- `README_SEC-001A.md` atualizado;
- `BLUEPRINT_SEC-001A.md` atualizado;
- `PLANO_IMPLEMENTACAO_SEC-001A.md` atualizado;
- `docs/01_PLATFORM_ARCHITECTURE.md` atualizado;
- `docs/06_ENGINEERING_LOG.md` atualizado;
- `docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md` criado;
- `tools/manifestos/SEC-001A-ENCERRAMENTO-PUBLICACAO-FIRESTORE.txt` criado.

## Limite de segurança

Este pacote registra uma publicação já autorizada e concluída. Ele não
autoriza nem executa:

- nova execução de `firebase deploy`;
- republicação de `firestore.rules`;
- alteração de alias Firebase;
- edição de dados remotos;
- exclusão de documentos;
- restauração da regra anterior;
- habilitação de App Check ou Cloud Audit Logs.

Qualquer nova mutação remota dependerá de escopo próprio, revalidação, nova
autorização expressa e execução controlada.

## Referências de segurança

A pesquisa técnica e o mapeamento de aderência estão consolidados em
`docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md`. As referências incluem
documentação oficial do Firebase e Google Cloud, OWASP e NIST SP 800-207.

App Check, Cloud Audit Logs, alertas, CI e revisão periódica de privilégios
foram classificados como evoluções de defesa em profundidade. Eles não
constituem ressalva à SEC-001A homologada.

## Encerramento Git

- commit preparatório: `9da5c94`;
- commit de publicação e homologação: `1ba5ba3`;
- Pull Request nº 6: aprovado e integrado;
- merge commit: `c8d2d95`;
- `main`: sincronizada com `origin/main`;
- working tree pós-merge: limpa;
- branch `security/sec-001a-publicacao-controlada-firestore`: removida local e
  remotamente.

## Sincronização documental pós-merge

Em 03/08/2026, a SEC-001A-R1 sincronizou este README com o estado efetivo do
Git e do GitHub. O commit `6a6794d` permanece registrado como baseline de
entrada da SEC-001A, enquanto `c8d2d95` passa a representar sua baseline final
integrada. A correção é exclusivamente documental e não autoriza nova
publicação no Firebase.
