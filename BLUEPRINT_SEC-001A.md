# BLUEPRINT SEC-001A — Publicação Controlada das Regras do Firestore

## 1. Controle do documento

| Item | Valor |
|---|---|
| Projeto | Plataforma Fênix / GEDUC RAE Mobile |
| Pacote | SEC-001A |
| Data | 02/08/2026 |
| Baseline Git | `main` em `6a6794d` |
| Projeto Firebase | `geduc-rae-mobile` |
| Número do projeto | `906308539006` |
| Regra candidata | `firestore.rules` |
| Estado | Publicação e homologação remota concluídas |

## 2. Objetivo arquitetural

Substituir a regra remota genérica por uma política versionada, testada, negada
por padrão e alinhada à identidade operacional da Plataforma Fênix, mediante
procedimento controlado, autorização expressa e homologação pós-deploy.

A SEC-001A publicou exclusivamente `firestore:rules`. Nenhum dado remoto,
índice, função, hosting ou código da aplicação foi modificado pelo deploy.

## 3. Baseline remota anterior preservada

O Console Firebase registrou a regra anterior como publicada em
`29/07/2026 às 22:31`, no horário apresentado pelo navegador.

```text
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

SHA-256 do snapshot preservado:

```text
9537678D49AD35DB5D8F85F7D976FEF36104D7C9C52546E1EF9F3195F65D6805
```

## 4. Diagnóstico de segurança

A regra remota anterior tratava autenticação como autorização total. Qualquer
conta que conseguisse autenticar podia ler, criar, alterar e excluir qualquer
documento.

### 4.1 Impactos

| Superfície | Exposição da regra anterior |
|---|---|
| `usuarios` | leitura e alteração de perfis, estado ativo e identidades |
| `domains` | criação, alteração e exclusão sem matriz de perfis |
| `tipos_acoes` | escrita e exclusão por qualquer autenticado |
| `coordenadores` | escrita e exclusão por qualquer autenticado |
| `regionais` | escrita e exclusão por qualquer autenticado |
| `materiais` | escrita e exclusão por qualquer autenticado |
| `acoes` | leitura, alteração e exclusão irrestritas entre autenticados |
| `contadores` | alteração, listagem e exclusão por qualquer autenticado |
| Outras coleções | leitura e escrita liberadas por wildcard recursivo |

### 4.2 Severidade

**CRÍTICA.** Sob a regra anterior, uma conta válida, inativa, sem cadastro
operacional ou com cliente adulterado permanecia capaz de alcançar todos os
documentos enquanto estivesse autenticada.

## 5. Baseline candidata e publicada

A regra local candidata possui SHA-256:

```text
8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD
```

Ela foi publicada sem alteração e estabelece:

1. autenticação obrigatória;
2. existência de `usuarios/{uid}` para uso operacional;
3. `ativo == true`;
4. campo oficial `perfilAcesso`;
5. perfis reconhecidos: administrador, gestor, coordenador e agente;
6. matriz específica para oito coleções inventariadas;
7. escrita de identidade negada ao cliente;
8. validação estrutural de `domains` e preservação de `createdAt`;
9. exclusões administrativas negadas;
10. negação final para toda coleção não inventariada.

## 6. Evidência de validação

| Controle | Resultado |
|---|---|
| Firebase Emulator Suite | 15/15 testes aprovados |
| Testes negativos | `PERMISSION_DENIED` confirmado |
| Firebase CLI local | `15.25.1` |
| Java | `21.0.12` |
| Working tree de entrada | limpa |
| Projeto acessível pela conta autenticada | `geduc-rae-mobile` |

As mensagens `PERMISSION_DENIED` emitidas durante a suíte correspondem às
negações esperadas e não representam falhas de execução.

## 7. Decisões arquiteturais

### 7.1 Projeto sempre explícito

Não existe `.firebaserc` nem projeto ativo no diretório. Essa condição foi
preservada durante o procedimento, e o projeto foi indicado explicitamente.
Qualquer novo comando remoto deverá manter `--project geduc-rae-mobile`.

### 7.2 Ferramenta reprodutível

O executável global estava em `15.22.3`, enquanto `package-lock.json` fixa
`firebase-tools` em `15.25.1`. O procedimento utilizou exclusivamente o
executável local do projeto.

### 7.3 Candidato imutável

O hash da regra candidata é uma pré-condição. Qualquer alteração em
`firestore.rules` invalida a aprovação existente e exige nova execução dos 15
testes, nova comparação e nova HAT-2.

### 7.4 Rollback não automático

O snapshot anterior foi preservado tecnicamente, mas restaura uma regra de
severidade crítica. Portanto, rollback não é resposta padrão.

A ordem de tratamento será:

1. confirmar se o problema é regra, dados de identidade ou propagação;
2. corrigir configuração de usuário quando a regra estiver correta;
3. aplicar correção progressiva da regra, se possível;
4. restaurar a regra anterior somente sob declaração de incidente e autorização
   expressa, com janela curta de contenção.

### 7.5 Propagação observável

O smoke test remoto começou somente depois que o Console indicou a nova versão
publicada. A fonte remota foi confirmada antes da classificação funcional, e
nenhuma regressão foi identificada.

## 8. Modelo de ameaça da publicação

| Ameaça | Controle |
|---|---|
| Publicar no projeto errado | `--project geduc-rae-mobile` obrigatório |
| Usar CLI diferente da validada | executável local `15.25.1` |
| Sobrescrever regra remota desconhecida | snapshot e hash anteriores preservados |
| Publicar arquivo alterado após os testes | hash candidato obrigatório |
| Bloquear usuários legítimos por dados inconsistentes | smoke test por estado e perfil |
| Restaurar regra crítica por reação prematura | rollback condicionado e decisão humana |
| Confundir falha esperada com regressão | matriz explícita de resultados permitidos e negados |

## 9. Escopo

### Incluído

- diagnóstico remoto;
- preservação da baseline anterior;
- comparação remota versus local;
- confirmação de ambiente;
- plano de publicação;
- plano de rollback;
- smoke tests;
- manifesto CPB;
- autorização expressa;
- publicação exclusiva de `firestore:rules`;
- verificação integral da regra remota;
- homologação pós-deploy;
- pesquisa de referências de segurança.

### Fora do escopo

- alteração de `firestore.rules`;
- mudança no modelo de dados;
- criação de `criadoPorUid` em `acoes`;
- matriz dinâmica de permissões;
- criação ou correção de usuários remotos;
- exclusão de dados;
- alteração de `.firebaserc`;
- enforcement de Firebase App Check;
- configuração de Cloud Audit Logs e alertas.

## 10. Portões de autorização

### HAT-1 — Arquitetura e diagnóstico

**APROVADA** para preparação documental.

### HAT-2 — Pacote de publicação

**APROVADA**, após confirmação de:

- CPB completo e sem arquivos ausentes;
- hash candidato confirmado;
- 15/15 testes aprovados novamente;
- `flutter analyze` com zero issues;
- contas de smoke test confirmadas;
- janela e responsável definidos;
- revisão do procedimento de rollback;
- working tree controlada.

### Autorização de publicação

A manifestação expressa do responsável foi registrada para o projeto
`geduc-rae-mobile`. O comando permaneceu bloqueado até essa autorização e foi
executado uma única vez no escopo `firestore:rules`.

## 11. Parecer da SEC-001A

A publicação controlada era tecnicamente necessária e prioritária porque a
regra remota anterior concedia acesso total a qualquer autenticado. O
candidato permaneceu imutável, o projeto foi informado explicitamente e a
publicação foi seguida de verificação remota e smoke tests aprovados.

## 12. Resultado da execução

| Controle | Resultado |
|---|---|
| Autorização expressa | Registrada |
| Projeto explícito | `geduc-rae-mobile` |
| Horário de início | 02/08/2026 às 21:04:30, UTC-03:00 |
| Compilação das regras | Aprovada |
| Release para Cloud Firestore | Concluído |
| Nova versão no Console | Confirmada às 21:05 |
| Comparação remoto versus local | Exit code `0` |
| Administrador ativo | Aprovado |
| Contas inativas | Bloqueadas |
| Acesso indevido | Não identificado |
| Tela branca ou exceção | Não identificada |
| Rollback | Não indicado |

O registro completo está em
`docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md`.

## 13. Referências e defesa em profundidade

A pesquisa foi concluída com documentação oficial do Firebase e Google Cloud,
OWASP e NIST SP 800-207. A SEC-001A adere aos princípios de separação entre
autenticação e autorização, menor privilégio, decisão no backend, negação por
padrão, validação por requisição e teste automatizado.

As próximas camadas recomendadas são avaliação gradual do Firebase App Check,
Cloud Audit Logs, alertas de uso, CI para as regras e revisão periódica de
privilégios. Esses controles complementam as regras; não as substituem e não
constituem ressalva à homologação atual.
