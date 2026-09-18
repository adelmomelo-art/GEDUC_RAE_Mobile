# ESC-001E.2 — BLUEPRINT TÉCNICO
## Repositório e Controller da Execução Administrativa

**Baseline:** `d536c42f0fe4170c49a8ff71bfcd39d4f780e2b8`
**Dependência:** ESC-001E.1 fechada
**UI:** fora do escopo desta subetapa

## 1. Objetivo

Transformar os contratos de segurança da E.1 em uma camada operacional
consumível pela futura tela E.3.

Fluxo:

```text
atividadeId + auth.uid
        ↓
FirestoreEscalaExecucaoRepository
        ↓
atividade administrativa
escala publicada
equipe planejada
executor canônico
execução do próprio usuário
        ↓
EscalaExecucaoController
```

## 2. Contexto de execução

`EscalaExecucaoContexto` reúne:

```text
EscalaAtividadeModel
EscalaModel
List<EscalaAlocacaoModel> equipe
MembroEquipeModel executor
ExecucaoMissaoModel? execução
```

Nenhum dado de pessoa é duplicado.

## 3. Identidade do executor

A camada Firestore consulta `equipe_operacional` pelo `usuarioId` autenticado e
exige exatamente um membro ativo e canônico.

Falha fechada:

```text
0 vínculos ativos = DENY
mais de 1 vínculo ativo = DENY
```

## 4. ID determinístico da execução

Formato lógico:

```text
exec-<SHA256(atividadeId::usuarioId)>
```

Objetivos:

- uma execução administrativa por atividade + usuário;
- retry idempotente;
- nenhum ID dependente de nome;
- evitar problema com caracteres de IDs externos.

## 5. Carregamento

O repositório valida antes de devolver contexto:

```text
atividade existe
escala existe
escala.status = publicada
naturezaAtividade = administrativa
geraRae = false
executor canônico único/ativo
```

Também carrega a equipe da atividade por `escala_alocacoes.atividadeId`.

## 6. Início idempotente

`iniciarExecucao()` usa transação.

Se o documento determinístico já existir e pertencer ao mesmo
atividade/usuário, ele é devolvido em vez de criar duplicidade.

## 7. Atualização

Somente campos mutáveis da E.1 são enviados ao Firestore:

```text
status
resultadoResumo
observacao
evidencias
concluidoEm
atualizadoEm
```

A identidade e o planejamento não são regravados.

A atualização também é transacional e valida a transição pelo
`EscalaExecucaoService`.

## 8. Controller

Responsabilidades:

```text
carregar contexto
iniciar/continuar
salvar resultado e observação
concluir
cancelar
anexar metadado de evidência
remover metadado de evidência
```

O Controller reutiliza `EscalaAccessPolicy`, não cria uma segunda política de
autorização.

## 9. Evidências

E.2 manipula somente metadados embutidos em `ExecucaoMissaoModel`.

Nenhum upload físico é realizado nesta etapa.

## 10. Fora do escopo

- rota `/escala/execucao/:atividadeId`;
- widgets/tela de execução;
- UX de horas realizadas;
- upload físico;
- Escala → RAE;
- financeiro;
- alterações em Storage/R2/App Check.
