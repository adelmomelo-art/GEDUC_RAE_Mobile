# Plano de implementação SEC-001C — Supply chain npm

## 1. Entrada obrigatória

- `main` sincronizada com `origin/main` em `3400563`;
- working tree limpa;
- Node `24.18.0` e npm `11.16.0`;
- branch `security/sec-001c-hardening-supply-chain` criada somente após a
  confirmação da baseline.

## 2. Fase 1 — HAT-1 concluída

Foram executados sem alteração do projeto:

- inventário das versões Git e Node.js;
- `npm audit` padrão;
- `npm audit --audit-level=high`;
- `npm outdated`;
- `npm approve-scripts --allow-scripts-pending`;
- confirmação final da working tree limpa.

Resultado: seis ocorrências moderadas, zero alta/crítica, uma correção
compatível para `re2` e três scripts pendentes de política.

## 3. Fase 2 — implementação

### 3.1 Lockfile

Aplicar a atualização segura gerada sem `--force`:

- `re2`: `1.24.1` → `1.26.1`;
- dependências auxiliares do módulo nativo ajustadas pelo resolvedor npm;
- nenhuma mudança nas dependências diretas.

### 3.2 Política npm

Adicionar ao `package.json`:

- `audit:security`;
- `audit:scripts`;
- `allowScripts` com versões fixadas para `@firebase/util`, `protobufjs` e
  `re2`, além da negação explícita de `fsevents`.

Adicionar `.npmrc` com política estrita de scripts.

### 3.3 CI

No job obrigatório de Firestore Rules, executar o audit de severidade depois da
configuração da toolchain e antes do `npm ci`.

## 4. Fase 3 — HAT-2 local

Executar, nesta ordem:

```powershell
npm ci
npm run audit:scripts
npm audit
npm run audit:security
npm run test:rules
flutter analyze
git diff --check
git status --short
```

Resultados esperados:

- `npm ci`: sucesso, sem script pendente;
- `audit:scripts`: nenhuma pendência;
- `npm audit`: apenas moderadas remanescentes e saída `1`;
- `audit:security`: saída `0`;
- Firestore Rules: 15 testes aprovados e zero falhas;
- Flutter: `No issues found!`;
- nenhuma alteração fora do manifesto.

## 5. Fase 4 — Git e CPB

1. revisar `git diff --check`, `--stat` e `--name-only`;
2. adicionar somente os arquivos do manifesto;
3. gerar CPB completo com o manifesto da SEC-001C;
4. analisar o ZIP antes do commit;
5. registrar o commit sugerido:

```text
ci(security): endurece cadeia de dependências npm
```

6. push da branch e abertura de Pull Request para `main`.

## 6. Fase 5 — HAT-3 remota

O Pull Request deve apresentar:

- `Quality Gate - Flutter Analyze`: sucesso e `Required`;
- `Quality Gate - Firestore Rules`: sucesso e `Required`;
- log do passo `Audit Node.js dependencies` com somente severidade moderada;
- ausência de bypass e conflitos.

## 7. Fase 6 — HAT-4 pós-merge

Após o merge:

- sincronizar a `main`;
- confirmar o novo merge commit;
- verificar execução automática do workflow em verde;
- executar `flutter analyze` local;
- confirmar working tree limpa;
- somente então remover a branch local e remota.

## 8. Rollback

Se `npm ci`, os testes ou o workflow falharem:

- não executar `--force`;
- não integrar o Pull Request;
- preservar os logs;
- corrigir somente na branch da SEC-001C;
- retornar ao lockfile anterior por novo patch revisado, sem comando destrutivo.

## 9. Encerramento documental

Após a HAT-4, atualizar Arquitetura, Engineering Log, README, Blueprint, Plano e
referências com commits, Pull Request, tempos e baseline final.
