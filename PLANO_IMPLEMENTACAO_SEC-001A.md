# PLANO DE IMPLEMENTAÇÃO SEC-001A

## 1. Finalidade

Definir o procedimento operacional para preparar, autorizar, publicar e validar
as regras do Firestore da Plataforma Fênix, com separação inequívoca entre
ações locais e mutações remotas.

## 2. Estado inicial confirmado

- `main` sincronizada com `origin/main` em `6a6794d`;
- working tree limpa;
- projeto visível: `geduc-rae-mobile`;
- nenhum alias ou projeto Firebase ativo;
- regra remota preservada e comparada;
- regra local candidata testada;
- 15/15 testes aprovados;
- publicação ainda não realizada.

## 3. Fase A — Preparação versionada

### A.1 Criar a branch

```powershell
git switch -c security/sec-001a-publicacao-controlada-firestore
```

### A.2 Aplicar o pacote documental

Extrair o ZIP da SEC-001A na raiz do repositório e confirmar somente os cinco
arquivos novos previstos no README.

### A.3 Validar a integridade inicial

```powershell
git status --short
git diff --check
git diff --stat
```

Critério: nenhuma alteração em `firestore.rules`, `firebase.json`, código
Flutter ou dependências.

## 4. Fase B — Revalidação pré-publicação

Executar somente depois da revisão do Blueprint:

```powershell
npm ci
npm ls firebase-tools --depth=0
.\node_modules\.bin\firebase.cmd --version
npm run test:rules
flutter analyze
Get-FileHash .\firestore.rules -Algorithm SHA256
git status --short
```

Critérios obrigatórios:

- `firebase-tools@15.25.1`;
- 15 testes aprovados;
- zero testes falhos;
- `flutter analyze`: `No issues found!`;
- SHA-256 candidato:
  `8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD`;
- nenhuma alteração inesperada.

## 5. Fase C — CPB e HAT-2

Gerar o pacote:

```powershell
.\tools\gerar_pacote_chatgpt.ps1 `
  SEC-001A-PREPARACAO-PUBLICACAO-FIRESTORE `
  -Full
```

O CPB deverá conter todos os arquivos do manifesto, registrar a baseline Git e
executar o `flutter analyze` sem falha.

A HAT-2 avaliará:

1. integridade do snapshot remoto;
2. integridade da regra candidata;
3. matriz de acesso;
4. testes positivos e negativos;
5. conta e projeto selecionados;
6. plano de smoke test;
7. gatilhos de interrupção;
8. rollback condicionado.

## 6. Ponto obrigatório de parada

Ao concluir a HAT-2, interromper o procedimento.

É proibido executar comando remoto até existir autorização textual e expressa
para a publicação da SEC-001A.

## 7. Fase D — Publicação futura

> **NÃO EXECUTAR DURANTE A PREPARAÇÃO DA SEC-001A.**

Comando previsto, somente após autorização:

```powershell
.\node_modules\.bin\firebase.cmd deploy `
  --only firestore:rules `
  --project geduc-rae-mobile
```

Controles imediatamente anteriores:

```powershell
git branch --show-current
git status --short
.\node_modules\.bin\firebase.cmd --version
Get-FileHash .\firestore.rules -Algorithm SHA256
```

Resultados esperados:

- branch correta;
- working tree no estado aprovado;
- CLI `15.25.1`;
- hash candidato aprovado;
- projeto exibido explicitamente no comando.

## 8. Fase E — Verificação pós-publicação

### E.1 Confirmar a versão remota

1. abrir o Console Firebase no projeto `geduc-rae-mobile`;
2. acessar Firestore Database → Regras;
3. confirmar nova data/hora de publicação;
4. copiar integralmente a regra publicada para:
   `tools/output/SEC-001A/firestore.remote-after-sec-001a.rules`;
5. calcular o SHA-256;
6. comparar com `firestore.rules`.

```powershell
$afterRules = `
  ".\tools\output\SEC-001A\firestore.remote-after-sec-001a.rules"

Get-FileHash $afterRules -Algorithm SHA256

git diff --no-index --ignore-space-at-eol -- `
  $afterRules `
  .\firestore.rules
```

Critério: nenhuma diferença lógica ou textual, exceto eventual normalização de
fim de linha devidamente registrada.

### E.2 Smoke test não destrutivo

| Cenário | Resultado esperado |
|---|---|
| Não autenticado acessa dados protegidos | negado |
| Autenticado sem `usuarios/{uid}` | próprio estado identificável; operação negada |
| Usuário inativo | próprio estado identificável; operação negada |
| Perfil desconhecido | operação negada |
| Administrador ativo | lê catálogos e acessa operações administrativas permitidas |
| Gestor ativo | lê catálogos, lista usuários e gerencia domains/tipos |
| Coordenador ativo | lê catálogos e opera ações; administração restrita |
| Agente ativo | lê catálogos e opera ações; administração restrita |

Durante o smoke inicial, usar navegação e leituras existentes. Não criar,
alterar ou excluir dados reais apenas para demonstrar permissão.

Os testes de escrita e negação continuam cobertos pela suíte de 15 testes do
Emulador. Uma escrita remota descartável somente será executada se houver
documento de teste dedicado, ausência de efeito em contador e autorização
específica.

## 9. Critérios de interrupção

Interromper a homologação e preservar evidências quando ocorrer:

- projeto remoto diferente de `geduc-rae-mobile`;
- hash candidato divergente;
- qualquer teste local falho;
- `flutter analyze` com issue;
- Console não confirmar nova versão;
- conta ativa e corretamente cadastrada perder acesso essencial;
- liberação indevida de operação prevista como negada;
- erro sistêmico reproduzível em dois perfis válidos.

Uma falha isolada causada por documento de usuário ausente, inativo ou com
perfil inválido deve ser diagnosticada como dado de identidade antes de se
considerar rollback.

## 10. Plano de rollback condicionado

### 10.1 Princípio

A regra anterior não é uma baseline segura: concede leitura e escrita total a
qualquer autenticado. Sua restauração aumenta imediatamente a exposição dos
dados.

### 10.2 Ordem de resposta

1. suspender novos testes;
2. confirmar versão publicada e propagação;
3. identificar se a causa é regra ou documento de identidade;
4. corrigir dado de identidade quando aplicável;
5. preferir correção progressiva da regra;
6. considerar restauração anterior somente diante de indisponibilidade crítica
   generalizada e autorização expressa.

### 10.3 Fonte preservada

- arquivo: `docs/SEC-001A_BASELINE_REMOTA_FIRESTORE.rules`;
- publicação original exibida: `29/07/2026 às 22:31`;
- SHA-256 original:
  `9537678D49AD35DB5D8F85F7D976FEF36104D7C9C52546E1EF9F3195F65D6805`.

### 10.4 Execução excepcional

Se o responsável autorizar rollback, restaurar a versão anterior pelo histórico
do Console Firebase ou publicar o snapshot preservado, sempre confirmando o
projeto `geduc-rae-mobile`.

O rollback deverá gerar registro de incidente, nova captura remota, hash,
smoke test mínimo e plano imediato de correção. Este documento não autoriza a
execução desse rollback.

## 11. Encerramento

A SEC-001A somente será concluída após:

- publicação expressamente autorizada;
- regra remota confirmada;
- smoke tests aprovados;
- ausência de regressão crítica;
- atualização do Engineering Log e da Arquitetura;
- commit, push, Pull Request, Code Review e merge;
- validação pós-merge com working tree limpa.
