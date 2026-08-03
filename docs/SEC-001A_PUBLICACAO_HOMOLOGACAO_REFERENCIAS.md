# SEC-001A — Publicação, Homologação e Referências de Segurança

## 1. Controle do registro

| Item | Valor |
|---|---|
| Projeto | Plataforma Fênix / GEDUC RAE Mobile |
| Projeto Firebase | `geduc-rae-mobile` |
| Número do projeto | `906308539006` |
| Banco | Cloud Firestore `(default)` |
| Data da publicação | 02/08/2026 |
| Início do procedimento | 21:04:30, UTC-03:00 |
| Nova versão confirmada no Console | 21:05, horário local exibido |
| Branch | `security/sec-001a-publicacao-controlada-firestore` |
| Commit preparatório | `9da5c94` |
| Estado | Publicação e homologação remota concluídas |

## 2. Baselines preservadas

### 2.1 Regra remota anterior

- versão exibida no Console: `29/07/2026 às 22:31`;
- snapshot: `docs/SEC-001A_BASELINE_REMOTA_FIRESTORE.rules`;
- SHA-256:
  `9537678D49AD35DB5D8F85F7D976FEF36104D7C9C52546E1EF9F3195F65D6805`;
- diagnóstico: qualquer conta autenticada possuía leitura e escrita genéricas
  em todos os documentos.

### 2.2 Regra candidata publicada

- fonte versionada: `firestore.rules`;
- SHA-256:
  `8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD`;
- Firebase CLI local: `15.25.1`;
- Firebase Emulator Suite: 15 testes aprovados e 0 falhas;
- `flutter analyze`: `No issues found!`.

## 3. Autorização e janela operacional

O responsável pelo projeto registrou autorização textual e expressa:

```text
AUTORIZO A PUBLICAÇÃO DAS REGRAS DA SEC-001A
NO PROJETO geduc-rae-mobile
```

Antes do comando remoto foram confirmados:

- branch correta e sincronizada com a origem;
- working tree limpa;
- ausência de diferença em `firestore.rules` e `firebase.json` contra `HEAD`;
- conta Firebase autenticada com acesso ao projeto correto;
- projeto informado explicitamente no comando;
- hashes anterior e candidato preservados;
- janela sem cadastros concorrentes declarada pelo responsável.

## 4. Publicação executada

Comando autorizado e executado uma única vez:

```powershell
.\node_modules\.bin\firebase.cmd deploy `
  --only firestore:rules `
  --project geduc-rae-mobile
```

Resultado registrado pelo Firebase CLI:

- API `firestore.googleapis.com` habilitada;
- compilação de `firestore.rules` concluída sem erro;
- upload concluído;
- regras liberadas para `cloud.firestore`;
- `Deploy complete!`.

Não houve publicação de código, índices, funções, hosting ou dados.

## 5. Verificação remota

O Console Firebase confirmou uma nova versão às 21:05 no projeto
`geduc-rae-mobile`, banco `(default)`, preservando no histórico a versão de
29/07/2026 às 22:31.

A regra remota foi copiada integralmente para o artefato operacional
`tools/output/SEC-001A/firestore.remote-after-sec-001a.rules` e comparada com
`firestore.rules`:

```text
git diff --no-index --ignore-space-at-eol: exit code 0
```

Resultado: nenhuma divergência lógica ou textual, desconsiderando apenas a
normalização permitida de fim de linha. A árvore Git permaneceu limpa.

## 6. Homologação pós-deploy

| Cenário | Resultado |
|---|---|
| Administrador ativo | Acesso aprovado |
| Módulos administrativos | Visíveis |
| Consultas aos dados existentes | Aprovadas |
| Lista de usuários | Aprovada |
| Gestor inativo | Bloqueado |
| Coordenador inativo | Bloqueado |
| Agente inativo | Bloqueado |
| Conta inativa acessou dados | Não |
| Tela branca ou exceção | Não |
| Mensagem de conta inativa | Correta e orientativa |

Mensagem homologada:

```text
Conta inativa — seu cadastro está inativo. Procure a administração da
Plataforma Fênix para verificar a situação de acesso.
```

O smoke test remoto foi intencionalmente não destrutivo. As operações de
criação, atualização, exclusão e respectivas negações continuam cobertas pela
suíte de 15 testes do Emulador.

## 7. Pesquisa de referência de segurança

### 7.1 Referências oficiais

| Referência | Controle aplicável | Aderência na SEC-001A |
|---|---|---|
| [Firebase — Get started with Cloud Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started) | Cada requisição mobile/web deve ser avaliada pelas regras; autenticação e autorização baseada em função trabalham em conjunto | Firebase Auth identifica a sessão e `firestore.rules` decide o acesso |
| [Firebase — Writing conditions](https://firebase.google.com/docs/firestore/security/rules-conditions) | Condições podem validar autenticação e consultar documentos relacionados com `exists()` e `get()` | `usuarioExiste()` e `usuarioAtual()` validam `usuarios/{uid}` |
| [Firebase — Control access to specific fields](https://firebase.google.com/docs/firestore/security/rules-fields) | `hasAll()`, comparação entre recurso atual e futuro e validação por tipo protegem a estrutura dos documentos | `domainValido()` exige campos e tipos; `createdAt` é imutável |
| [Firebase — Structuring Security Rules](https://firebase.google.com/docs/firestore/security/rules-structure) | Matches sobrepostos são combinados por concessão; qualquer `allow` verdadeiro autoriza a operação | As permissões positivas ficam limitadas às oito coleções e o wildcard final não concede acesso |
| [Firebase — Build unit tests](https://firebase.google.com/docs/rules/unit-tests) | A suíte no Emulator permite validar regras sem tocar dados de produção | 15 cenários positivos e negativos foram aprovados |
| [Firebase — Security checklist](https://firebase.google.com/support/guides/security-checklist) | Recomenda regras restritivas, monitoramento, alertas e App Check | Regras restritivas concluídas; monitoramento e App Check seguem como defesa em profundidade |
| [OWASP — Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) | Menor privilégio, negação por padrão, validação em toda requisição e revisão periódica | Perfis reconhecidos, usuário ativo, matriz por coleção e negação final |
| [OWASP Top 10:2025 — A01 Broken Access Control](https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/) | Controle de acesso deve impedir escalada vertical/horizontal e acesso genérico autenticado | A regra genérica anterior foi removida e a identidade não pode ser alterada pelo cliente |
| [NIST SP 800-207 — Zero Trust Architecture](https://csrc.nist.gov/pubs/sp/800/207/final) | Não conceder confiança implícita apenas por existência de conta ou localização; autenticação e autorização são funções distintas | Conta autenticada somente opera quando possui identidade ativa e perfil autorizado |
| [Google Cloud — Firestore audit logging](https://docs.cloud.google.com/firestore/native/docs/audit-logging) | Registros de auditoria apoiam rastreabilidade de atividades administrativas e de acesso | Avaliação de Cloud Audit Logs registrada como evolução futura |
| [Firebase — App Check](https://firebase.google.com/docs/app-check) | Atestação ajuda a rejeitar clientes não autorizados ou adulterados | Avaliação e implantação gradual registradas como evolução futura |

### 7.2 Conclusão da pesquisa

A SEC-001A implementa corretamente o núcleo de controle de acesso exigido
para clientes Flutter: decisão no backend, identidade operacional válida,
menor privilégio, negação por padrão, validação estrutural e teste automatizado.

App Check, Cloud Audit Logs, alertas e revisão periódica de privilégios são
controles complementares. Eles reduzem abuso, melhoram a detecção e aumentam a
rastreabilidade, mas não substituem as regras publicadas.

## 8. Evoluções de defesa em profundidade

As seguintes ações devem ser avaliadas em pacotes próprios, com Blueprint,
plano, testes, homologação e autorização específicos:

1. observar métricas antes de habilitar enforcement do Firebase App Check;
2. avaliar custos, escopo e retenção dos Cloud Audit Logs de Data Access;
3. configurar alertas de uso, orçamento e comportamento anômalo;
4. automatizar os testes de regras em workflow de CI e exigir status check;
5. revisar periodicamente usuários ativos, perfis e privilégios acumulados;
6. evoluir `acoes` com autoria imutável por UID antes de aplicar propriedade
   individual de registros.

Essas evoluções não constituem ressalva à publicação homologada.

## 9. Parecer final

**PUBLICAÇÃO E HOMOLOGAÇÃO REMOTA APROVADAS SEM RESSALVAS TÉCNICAS.**

A regra permissiva anterior foi substituída pela baseline segura e testada. A
fonte remota coincide com a fonte versionada, o administrador ativo manteve o
acesso esperado, as contas inativas foram bloqueadas e não ocorreu regressão
crítica. Não há indicação de rollback nem autorização para nova publicação.
