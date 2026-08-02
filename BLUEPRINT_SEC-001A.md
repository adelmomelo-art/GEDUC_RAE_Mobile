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
| Estado | HAT-1 diagnóstica concluída; publicação bloqueada |

## 2. Objetivo arquitetural

Substituir, em procedimento futuro e expressamente autorizado, a regra remota
genérica por uma política versionada, testada, negada por padrão e alinhada à
identidade operacional da Plataforma Fênix.

A SEC-001A prepara a publicação. Ela não publica regras e não modifica dados
remotos.

## 3. Baseline remota identificada

O Console Firebase registrou a regra vigente como publicada em
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

A regra remota trata autenticação como autorização total. Qualquer conta que
consiga autenticar pode ler, criar, alterar e excluir qualquer documento.

### 4.1 Impactos

| Superfície | Exposição remota vigente |
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

**CRÍTICA.** Uma conta válida, inativa, sem cadastro operacional ou com cliente
adulterado permanece capaz de alcançar todos os documentos enquanto estiver
autenticada.

## 5. Baseline candidata

A regra local candidata possui SHA-256:

```text
8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD
```

Ela estabelece:

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

Não existe `.firebaserc` nem projeto ativo no diretório. Essa condição será
preservada durante a preparação. Qualquer comando remoto futuro deverá indicar
explicitamente `--project geduc-rae-mobile`.

### 7.2 Ferramenta reprodutível

O executável global está em `15.22.3`, enquanto `package-lock.json` fixa
`firebase-tools` em `15.25.1`. O procedimento futuro utilizará exclusivamente
o executável local do projeto.

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

O smoke test remoto somente começará depois que o Console indicar a nova
versão publicada e a propagação estiver estabilizada. Falha imediatamente após
o envio não será classificada como regressão sem confirmar o estado publicado.

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
- manifesto CPB.

### Fora do escopo

- alteração de `firestore.rules`;
- mudança no modelo de dados;
- criação de `criadoPorUid` em `acoes`;
- matriz dinâmica de permissões;
- criação ou correção de usuários remotos;
- publicação no Firebase;
- exclusão de dados;
- alteração de `.firebaserc`.

## 10. Portões de autorização

### HAT-1 — Arquitetura e diagnóstico

**APROVADA** para preparação documental. Não autoriza publicação.

### HAT-2 — Pacote de publicação

Exigirá:

- CPB completo e sem arquivos ausentes;
- hash candidato confirmado;
- 15/15 testes aprovados novamente;
- `flutter analyze` com zero issues;
- contas de smoke test confirmadas;
- janela e responsável definidos;
- revisão do procedimento de rollback;
- working tree controlada.

### Autorização de publicação

Mesmo após HAT-2, o comando remoto permanecerá bloqueado até manifestação
expressa do responsável pelo projeto.

## 11. Parecer da SEC-001A

A publicação controlada é tecnicamente necessária e prioritária, porque a
regra remota atual concede acesso total a qualquer autenticado. A urgência não
elimina os controles: o candidato deverá permanecer imutável, o projeto será
informado explicitamente e a publicação será seguida de verificação remota e
smoke tests.
