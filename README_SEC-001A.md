# SEC-001A — Preparação para Publicação Controlada das Regras do Firestore

## Estado

HAT-1 concluída e aprovada para preparação controlada. A HAT-2 e a publicação
remota permanecem bloqueadas até nova revisão e autorização expressa.

## Objetivo

Preparar a publicação controlada da baseline de segurança do Firestore,
preservando a regra remota anterior, identificando riscos, definindo critérios
de interrupção, rollback condicionado e smoke tests posteriores.

## Baseline

- repositório: `adelmomelo-art/GEDUC_RAE_Mobile`;
- branch de entrada: `main`;
- commit de entrada: `6a6794d`;
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
- `git status`: working tree limpa antes da preparação.

## Resultado da HAT-1

**APROVADA SEM RESSALVAS TÉCNICAS**, após sincronização editorial do estado
deste README.

A análise confirmou que Blueprint, plano, snapshot, manifesto e evidências são
consistentes. A aprovação autoriza o versionamento do pacote preparatório e a
entrada posterior na HAT-2, mas não autoriza qualquer mutação no Firebase.

## Achado crítico

A regra remota vigente permite leitura e escrita em qualquer documento para
qualquer conta autenticada. Isso inclui documentos de identidade, perfis,
ações, contadores e coleções não inventariadas.

A baseline local substitui a autorização genérica por identidade ativa,
perfil reconhecido, matriz de permissões por coleção e negação por padrão.

## Arquivos novos

- `BLUEPRINT_SEC-001A.md`;
- `PLANO_IMPLEMENTACAO_SEC-001A.md`;
- `README_SEC-001A.md`;
- `docs/SEC-001A_BASELINE_REMOTA_FIRESTORE.rules`;
- `tools/manifestos/SEC-001A-PREPARACAO-PUBLICACAO-FIRESTORE.txt`.

## Limite de segurança

Este pacote não autoriza nem executa:

- `firebase deploy`;
- `firebase deploy --only firestore:rules`;
- alteração de alias Firebase;
- edição de dados remotos;
- exclusão de documentos;
- restauração da regra anterior.

Qualquer publicação dependerá de CPB, HAT-2, autorização expressa e execução
manual do runbook aprovado.
