# PLATAFORMA FÊNIX
# ESC-001E — BLUEPRINT EXECUÇÃO OPERACIONAL v0.1

**Baseline de entrada:** `f1fe5fa513f42524fac64c74d824e623f9dcf2ff`
**Etapa anterior:** ESC-001D — FECHADA
**Status:** baseline funcional da ESC-001E
**Objetivo:** transformar planejamento publicado em execução auditável, sem
misturar horas programadas, horas realizadas, RAE, produtividade e financeiro.

## 1. Princípio

```text
ESC-001D = PLANEJAMENTO / PUBLICAÇÃO
ESC-001E = EXECUÇÃO / HORAS REALIZADAS
ESC-001F = ESCALA → RAE
```

A execução nunca altera QTR, QTH, equipe planejada, tipo de jornada ou demais
campos de planejamento de uma escala publicada.

## 2. Missão administrativa

Usa a coleção já existente:

```text
escala_execucoes_missao
```

Somente:

```text
naturezaAtividade = administrativa
geraRae = false
escala = publicada
```

podem gerar registro de execução administrativa.

Ação educativa não utiliza `ExecucaoMissaoModel`; sua continuidade permanece
na ESC-001F.

## 3. Quem executa missão administrativa

```text
Agente participante
Coordenador da atividade
```

Cada executor grava a própria identidade canônica.

Não é permitido forjar outro executor.

## 4. Ciclo da execução administrativa

Estados:

```text
em_execucao
concluida
cancelada
```

Transição operacional:

```text
em_execucao → em_execucao
em_execucao → concluida
em_execucao → cancelada
```

Registro criado diretamente como `concluida` ou `cancelada` é aceito para
lançamento posterior, desde que seja válido.

Depois de terminal (`concluida`/`cancelada`), o registro torna-se imutável no
cliente.

Conclusão exige:

```text
resultadoResumo não vazio
concluidoEm
```

## 5. Evidências administrativas

Tipos funcionais:

```text
foto
documento
arquivo
link
observacao
outro
```

Limite:

```text
20 metadados por execução
```

Nesta fase evidência significa **metadado auditável**.

Não habilitar Storage/R2/App Check nesta entrega. O armazenamento físico
continua dependente da infraestrutura de evidências homologada.

## 6. Horas realizadas

Cada agente participante registra somente as horas da própria alocação:

```text
horaInicioReal
horaFimReal
minutosRealizados
observacao
```

A gravação é permitida somente quando a escala da alocação está publicada.

O Coordenador não altera horas de outro agente só por coordenar a atividade.
Se ele também for participante com alocação própria, registra somente a sua.

## 7. Verdade das horas

```text
horaInicio / horaFim
minutosPrevistos
= PLANEJAMENTO

horaInicioReal / horaFimReal
minutosRealizados
= EXECUÇÃO
```

`minutosRealizados` deve ser coerente com o intervalo real no domínio Flutter.

As Rules garantem contrato estrutural:

```text
HH:mm completo
início e fim juntos
minutos inteiros entre 0 e 1440
```

## 8. Proteção do planejamento durante execução

Em alocação publicada, a atualização de execução pode afetar somente:

```text
horaInicioReal
horaFimReal
minutosRealizados
observacao
atualizadoPor
atualizadoEm
```

Não pode alterar:

```text
agente
atividade
QTR
turno
hora planejada
tipoJornada
classificação hora extra/banco
minutosPrevistos
```

Na edição de rascunho/revisão, os campos de horas reais já existentes devem
ser preservados.

## 9. Horas em revisão versionada

A ESC-001D.5 já preserva a proveniência da alocação clonada.

A ESC-001E mantém essa decisão: uma revisão pode transportar horas reais já
registradas, mas a Gestão da Escala não pode reescrevê-las.

## 10. Segurança

Matriz:

```text
Participante
- registrar própria hora realizada: ALLOW
- registrar própria execução administrativa: ALLOW
- anexar evidência à própria execução: ALLOW

Coordenador
- registrar execução da missão coordenada: ALLOW
- anexar evidência à própria execução: ALLOW
- registrar horas de outro agente: DENY

Gerente / Responsável
- continuam gestores do planejamento
- não recebem direito implícito de forjar execução alheia

Administrador
- não opera execução
```

## 11. Roadmap interno ESC-001E

```text
E.1 Contratos, horas realizadas e segurança
E.2 Repositório/controller da execução administrativa
E.3 Tela Execução da Missão + integração na Escala publicada
E.4 Registro de horas realizadas + evidências na UX
E.5 Fechamento integral ESC-001E
```

## 12. Fora do escopo

```text
Escala → RAE                  = ESC-001F
PDF oficial                   = ESC-001G
indicadores/Faixita           = ESC-001H
saldo contábil banco de horas = ESC-001H
financeiro                    = AUSENTE
Storage/R2 enforcement        = fora deste pacote
```
