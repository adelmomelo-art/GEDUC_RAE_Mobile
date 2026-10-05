# AGO-001 — Agenda Operacional

Status: homologação funcional web local H01–H14 concluída em 05/10/2026.
Commit/push, CI, publicação controlada e homologação A05 pendentes.
Base: `7c52323896c89e6bec2fbfcc61846c060b4c48ab`.

## Fluxo implementado

O agente designado como responsável ativo pela escala abre a Agenda
Operacional na Home ou na Gestão da Escala. Registra o compromisso na data
e no turno; título, data e turno bastam para começar. Horário, estimativa
de público e tamanho da equipe podem ficar indefinidos.

O calendário mensal permite selecionar o dia e pesquisar por título ou
instituição, turno e situação. Cada compromisso aparece separadamente na
manhã, tarde ou noite. O planejamento reúne instituição, projeto ativo do
Catálogo Institucional, local, endereço, bairro, regional, referência,
contato, público, materiais, origem e processo.

Após completar horário, local, endereço e projeto educativo, o responsável
marca o planejamento como pronto e usa **Montar escala**. A ação passa a
integrar a escala diária existente; quando necessário, um rascunho diário
é criado na mesma transação. A Gestão da Escala continua responsável por
equipe, coordenador, jornada, conferência e publicação.

Depois da publicação, a equipe consulta as informações pelo fluxo de Escala
já existente no app. A AGO-001 não acrescenta notificações push.

## Privacidade e dados

Somente o agente ativo explicitamente designado em
`escala_configuracoes/principal` pode acessar a coleção
`agenda_operacional` e seu histórico. Gerente, gestor, administrador,
coordenador e outros agentes não ganham acesso à agenda por seu perfil.
A proteção existe na rota, no controller e nas regras Firestore.

O compromisso tem revisão crescente, autoria, datas de criação e alteração,
e situação persistida `planejamento`, `pronta` ou `cancelada`. As situações
de escala em elaboração/publicada são derivadas da versão diária atual.

O snapshot em `escala_atividades` contém somente título, descrição destinada
à equipe, seção, natureza, projeto, turno, horário, local, endereço,
regional, referência e orientação explícita para a equipe. Contatos,
materiais, observações internas, processo e estimativas permanecem privados.
O formulário identifica os campos destinados à equipe.

Metadados opcionais adicionados à atividade: `agendaCompromissoId`,
`agendaRevisao`, `agendaOrigemAtividadeId` e `projetoId`. Atividades antigas
continuam válidas sem esses campos. O projeto acompanha a criação do RAE.

## Consistência e histórico

Cadastro/edição, revisão e histórico são gravados juntos. O histórico usa
`agenda_operacional/{id}/historico/{revisao}` e não admite edição ou exclusão.
Os eventos registram ação, autor, motivo, revisão e datas anterior/nova.

Montar/aplicar planejamento lê a revisão esperada e grava vínculo, atividade
e histórico em uma transação. Reenvio não cria outra atividade. Concorrência
obsoleta exige atualização. As versões da escala preservam a origem da agenda.

Editar um compromisso vinculado deixa o snapshot pendente. O responsável
completa o planejamento, marca pronto e aplica à versão em rascunho. Uma
escala publicada exige preparar revisão pelo fluxo existente. A publicação
confere a revisão privada e a atividade na mesma transação e bloqueia
planejamento pendente; a conferência estrutural exige endereço e coordenador
incluído na equipe. Alteração de horário exige conferir os horários da equipe.

Cancelamento/remarcação exige motivo. Com vínculo, a versão de origem precisa
ser rascunho preparado; a operação cancela sua atividade e remove apenas
alocações planejadas. RAE, execução ou horas realizadas bloqueiam a retirada.
As versões publicadas anteriores são preservadas. Uma remarcação a outra
data exige publicar a retirada da origem antes de montar a nova escala.
Atividades canceladas não podem iniciar novo RAE nem execução administrativa.

## Referência e escopo

O fluxo usa a planilha oficial OPERAÇÃO_2026 como referência de trabalho,
mantendo calendário mensal, múltiplos compromissos e os três turnos.
Não há importação automática de Sheets/PDF nesta implementação. Não foram
criadas estimativas fictícias, projeto paralelo nem alteração do fluxo GPS.

## Verificação e aplicação

Executar na raiz do repositório:

```powershell
flutter pub get
flutter analyze
flutter test --no-pub
npm ci
npm run test:rules
npm run audit:security
npm run test:security:compat
npm run test:rules:watch
flutter build web --no-pub
git diff --check
```

As regras exigem Node compatível com o lockfile e Java 21, como no CI.
O emulador usa projeto de teste; não depende de dados produtivos.
`analysis_options.yaml` exclui templates Dart de `node_modules` da análise.
Nenhuma dependência Flutter nova foi adicionada.

A revisão R3 corrige a auditoria das ferramentas npm. Ver
`AGO-001_R3_SEGURANCA_NPM.md` para versões, testes e limites de homologação.

A consulta mensal usa um intervalo no campo `data`; não adiciona índice
composto. Aplicação do código e atualização das regras devem ser coordenadas
no ambiente de homologação. As regras precisam estar atualizadas para
habilitar cadastro, histórico e vínculo. Deploy produtivo não faz parte da
execução deste pacote.

## Roteiro de homologação funcional

- [ ] Responsável ativo vê o atalho; outros perfis não veem nem acessam a rota.
- [ ] Verificar no A05 e na web mês anterior/seguinte e seleção de um dia.
- [ ] Criar manhã/tarde/noite com só título; confirmar horário a combinar e
      estimativas vazias. Verificar pesquisa, turno e situação.
- [ ] Completar projeto oficial, horário e endereço; marcar pronto e montar.
      Confirmar uma escala diária com várias ações distintas.
- [ ] Repetir montagem/atualizar página; confirmar ausência de duplicação.
- [ ] Definir equipe e coordenador na Gestão da Escala e publicar. Conferir
      que a equipe vê orientação/local, sem contato e observação interna.
- [ ] Editar agenda após vínculo; confirmar aviso pendente e bloqueio de
      publicação até aplicar. Preparar revisão se já estiver publicada.
- [ ] Aplicar novo horário; conferir e salvar os horários da equipe.
- [ ] Cancelar com motivo em revisão preparada; publicar retirada e conferir
      preservação da versão anterior e do histórico privado.
- [ ] Remarcar com motivo; publicar retirada da origem, montar a nova data
      e conferir que não há duas ações publicadas ativas.
- [ ] Confirmar bloqueio da retirada após resultado/horas realizadas.
- [ ] Em duas sessões, editar o mesmo compromisso; confirmar rejeição da
      gravação obsoleta. Revogar designação e verificar novo acesso negado.
- [ ] Criar RAE de ação educativa e conferir o projeto institucional.
- [ ] Responsável pelo produto registra o aceite funcional.

Os testes automatizados não substituem o aceite no A05 e no ambiente real.

## Aceite funcional web local

R8 homologada: remarcação com retirada v3 publicada, montagem na nova data
sem duplicação e planejamento preservado. R9 consolida a documentação,
sem alteração de código ou regras. Evidências e evolução do calendário
registradas em `AGO-001_HOMOLOGACAO_LOCAL.md`.
