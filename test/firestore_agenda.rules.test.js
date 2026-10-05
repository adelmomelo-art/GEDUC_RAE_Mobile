const { before, beforeEach, after, test } = require('node:test');
const fs = require('node:fs');
const firebase = require('firebase/compat/app');
require('firebase/compat/firestore');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
let ambiente;
const data = new Date('2026-10-05T03:00:00.000Z');
const timestamp = () => firebase.firestore.FieldValue.serverTimestamp();
const banco = uid => uid ? ambiente.authenticatedContext(uid).firestore() : ambiente.unauthenticatedContext().firestore();
function compromisso(overrides = {}) {
  return { data, titulo: 'AMC nas Escolas', turno: 'manha', instituicao: 'Escola', projetoId: '',
    natureza: 'educativa', secaoId: 'comandos_tematicos', horaInicio: '', horaFim: '', local: '',
    endereco: '', bairro: '', regionalId: '', referencia: '', contatoNome: 'Contato privado',
    contatoTelefone: 'Contato privado', descricao: '', publico: '', quantidadePublico: null,
    integrantesNecessarios: null, materiais: '', observacoesInternas: 'Interno', orientacaoEquipe: '',
    origem: 'contato_direto', processo: '', situacao: 'planejamento', motivo: '', revisao: 1,
    escalaId: '', atividadeId: '', dataVinculada: null, criadoPor: 'responsavel', criadoEm: timestamp(),
    atualizadoPor: 'responsavel', atualizadoEm: timestamp(), ...overrides };
}
function evento(revisao, overrides = {}) {
  return { acao: revisao === 1 ? 'cadastro' : 'edicao', usuarioId: 'responsavel', motivo: '',
    revisao, em: timestamp(), dataAnterior: null, dataNova: data, ...overrides };
}
function escala(overrides = {}) {
  return { data, status: 'rascunho', versao: 1, observacaoGeral: '', motivoRevisao: '',
    revisaoDeEscalaId: '', revisaoPreparada: true, criadoPor: 'responsavel', criadoEm: data,
    atualizadoPor: 'responsavel', atualizadoEm: data, publicadoPor: '', publicadoEm: null, ...overrides };
}
function atividade(overrides = {}) {
  return { escalaId: '2026-10-05', data, secaoId: 'comandos_tematicos', tipoAtividadeId: 'palestra',
    naturezaAtividade: 'educativa', titulo: 'AMC nas Escolas', descricao: '', turnoId: 'manha',
    qtrHorario: '08:00', horaInicio: '08:00', horaFim: '10:00', qthLocal: 'Escola', qthEndereco: 'Rua Escola',
    qthRegionalId: '', qthPontoReferencia: '', orientacaoOperacional: 'Levar material',
    coordenadorMembroEquipeId: '', coordenadorUsuarioId: '', coordenadorNomeSnapshot: '',
    participanteUsuarioIds: [], geraRae: true, contabilizaProdutividade: true, raeId: '', execucaoMissaoId: '',
    status: 'planejada', criadoPor: 'responsavel', criadoEm: data, atualizadoPor: 'responsavel', atualizadoEm: timestamp(),
    agendaCompromissoId: 'a', agendaRevisao: 2, agendaOrigemAtividadeId: '', ...overrides };
}
async function cadastro(db, overrides = {}) {
  const ref = db.collection('agenda_operacional').doc('a');
  const batch = db.batch(); batch.set(ref, compromisso(overrides));
  batch.set(ref.collection('historico').doc('1'), evento(1)); return batch.commit();
}
async function seed() {
  await ambiente.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    for (const [uid, perfil] of Object.entries({ responsavel: 'agente', agente: 'agente', gerente: 'gerente',
      admin: 'administrador', gestor: 'gestor', coordenador: 'coordenador', inativo: 'agente' })) {
      await db.collection('usuarios').doc(uid).set({perfilAcesso: perfil, ativo: uid !== 'inativo'});
    }
    await db.collection('escala_configuracoes').doc('principal').set({
      responsavelEscalaUsuarioId: 'responsavel', responsavelEscalaMembroEquipeId: 'membro', ativo: true,
      designadoPor: 'admin', designadoEm: data });
  });
}
before(async () => { ambiente = await initializeTestEnvironment({projectId: 'geduc-rae-agenda-test',
  firestore: { rules: fs.readFileSync('firestore.rules', 'utf8') }}); });
beforeEach(async () => { await ambiente.clearFirestore(); await seed(); });
after(async () => { if (ambiente) await ambiente.cleanup(); });

test('montagem após retirada publicada mantém snapshots antigos e não duplica a nova data', async () => {
  const novaData = new Date('2026-10-06T03:00:00.000Z');
  const db = banco('responsavel');
  const agendaRef = db.collection('agenda_operacional').doc('a');
  await ambiente.withSecurityRulesDisabled(async context => {
    const seed = context.firestore();
    await seed.collection('escalas').doc('2026-10-05').set(escala({status: 'arquivada'}));
    await seed.collection('escalas').doc('2026-10-05-v2').set(escala({status: 'arquivada', versao: 2}));
    await seed.collection('escalas').doc('2026-10-05-v3').set(escala({status: 'publicada', versao: 3}));
    await seed.collection('escala_atividades').doc('agenda-a').set(atividade());
    await seed.collection('escala_atividades').doc('agenda-a-v2').set(atividade({escalaId: '2026-10-05-v2'}));
    await seed.collection('escala_atividades').doc('agenda-a-v3').set(atividade({escalaId: '2026-10-05-v3',
      status: 'cancelada', contabilizaProdutividade: false}));
    await seed.collection('agenda_operacional').doc('a').set(compromisso({data: novaData,
      situacao: 'pronta', revisao: 5, motivo: 'Solicitação da escola'}));
  });
  async function montar(id) {
    const batch = db.batch();
    batch.set(db.collection('escalas').doc('2026-10-06'), escala({data: novaData}));
    batch.set(db.collection('escala_atividades').doc(id), atividade({data: novaData,
      escalaId: '2026-10-06', agendaRevisao: 6}));
    batch.update(agendaRef, {escalaId: '2026-10-06', atividadeId: id,
      dataVinculada: novaData, revisao: 6, atualizadoEm: timestamp()});
    batch.set(agendaRef.collection('historico').doc('6'), evento(6, {acao: 'vinculacao', dataNova: novaData}));
    return batch.commit();
  }
  // O identificador antigo já pertence a um snapshot imutável de outra data.
  await assertFails(montar('agenda-a'));
  const id = 'agenda-2026-10-06-a';
  await assertSucceeds(montar(id));
  const batch = db.batch();
  batch.update(agendaRef, {revisao: 7, atualizadoEm: timestamp()});
  batch.update(db.collection('escala_atividades').doc(id), {agendaRevisao: 7, atualizadoEm: timestamp()});
  batch.set(agendaRef.collection('historico').doc('7'), evento(7, {acao: 'aplicacao', dataNova: novaData}));
  await assertSucceeds(batch.commit());
  const antigas = await Promise.all(['agenda-a', 'agenda-a-v2', 'agenda-a-v3']
    .map(id => db.collection('escala_atividades').doc(id).get()));
  if (antigas[0].data().escalaId !== '2026-10-05' ||
      antigas[1].data().escalaId !== '2026-10-05-v2' ||
      antigas[2].data().status !== 'cancelada') throw Error('Histórico alterado');
  const novas = await db.collection('escala_atividades').where('escalaId', '==', '2026-10-06').get();
  if (novas.size !== 1 || novas.docs[0].id !== id) throw Error('Atividade duplicada');
  await assertFails(banco('agente').collection('agenda_operacional').doc('a').get());
});

test('responsável cadastra planejamento incompleto com histórico atômico', async () => {
  const db = banco('responsavel'); await assertSucceeds(cadastro(db));
  await assertSucceeds(db.collection('agenda_operacional').doc('a').get());
  await assertSucceeds(db.collection('agenda_operacional').get());
  await assertSucceeds(db.collection('agenda_operacional').doc('a').collection('historico').get());
});
for (const uid of [null, 'agente', 'gerente', 'admin', 'gestor', 'coordenador', 'inativo']) {
  test(`agenda e histórico negam acesso a ${uid || 'anônimo'}`, async () => {
    await cadastro(banco('responsavel'));
    const db = banco(uid), ref = db.collection('agenda_operacional').doc('a');
    await assertFails(ref.get()); await assertFails(db.collection('agenda_operacional').get());
    await assertFails(ref.collection('historico').get());
    await assertFails(cadastro(db));
  });
}
test('nega gravação sem histórico e edição com revisão obsoleta', async () => {
  const db = banco('responsavel'), ref = db.collection('agenda_operacional').doc('a');
  await assertFails(ref.set(compromisso())); await cadastro(db);
  await assertFails(ref.update({titulo: 'Alterada', atualizadoEm: timestamp()}));
});
test('edita com revisão crescente e preserva autoria inicial', async () => {
  const db = banco('responsavel'), ref = db.collection('agenda_operacional').doc('a'); await cadastro(db);
  const batch = db.batch(); batch.update(ref, {titulo: 'Outra ação', revisao: 2, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('2'), evento(2)); await assertSucceeds(batch.commit());
  await assertFails(ref.delete());
  await assertFails(ref.collection('historico').doc('1').update({motivo: 'adulterado'}));
});
test('remarcação exige motivo e evento', async () => {
  const db = banco('responsavel'), ref = db.collection('agenda_operacional').doc('a'); await cadastro(db);
  const nova = new Date('2026-10-06T03:00:00.000Z');
  let batch = db.batch(); batch.update(ref, {data: nova, revisao: 2, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('2'), evento(2, {acao: 'remarcacao', dataNova: nova}));
  await assertFails(batch.commit());
  batch = db.batch(); batch.update(ref, {data: nova, motivo: 'Solicitação da escola', revisao: 2, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('2'), evento(2, {acao: 'remarcacao', motivo: 'Solicitação da escola', dataAnterior: data, dataNova: nova}));
  await assertSucceeds(batch.commit());
});
test('cancelamento sem motivo é negado e cancelado não é reaberto', async () => {
  const db = banco('responsavel'), ref = db.collection('agenda_operacional').doc('a'); await cadastro(db);
  let batch = db.batch(); batch.update(ref, {situacao: 'cancelada', revisao: 2, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('2'), evento(2, {acao: 'cancelamento'})); await assertFails(batch.commit());
  batch = db.batch(); batch.update(ref, {situacao: 'cancelada', motivo: 'Chuva', revisao: 2, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('2'), evento(2, {acao: 'cancelamento', motivo: 'Chuva'})); await assertSucceeds(batch.commit());
  batch = db.batch(); batch.update(ref, {situacao: 'planejamento', revisao: 3, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('3'), evento(3)); await assertFails(batch.commit());
});
test('configuração desativada e mudança de responsável revogam acesso imediatamente', async () => {
  const db = banco('responsavel'); await cadastro(db);
  await ambiente.withSecurityRulesDisabled(async context => context.firestore().collection('escala_configuracoes').doc('principal').update({ativo: false}));
  await assertFails(db.collection('agenda_operacional').doc('a').get());
  await ambiente.withSecurityRulesDisabled(async context => context.firestore().collection('escala_configuracoes').doc('principal').update({ativo: true, responsavelEscalaUsuarioId: 'agente'}));
  await assertFails(db.collection('agenda_operacional').doc('a').get());
  await assertSucceeds(banco('agente').collection('agenda_operacional').doc('a').get());
});
test('vínculo, escala diária e atividade são criados juntos sem expor agenda à equipe', async () => {
  const db = banco('responsavel'), ref = db.collection('agenda_operacional').doc('a'); await cadastro(db);
  const batch = db.batch(); batch.set(db.collection('escalas').doc('2026-10-05'), escala());
  batch.set(db.collection('escala_atividades').doc('agenda-a'), atividade());
  batch.update(ref, {situacao: 'pronta', escalaId: '2026-10-05', atividadeId: 'agenda-a', dataVinculada: data, revisao: 2, atualizadoEm: timestamp()});
  batch.set(ref.collection('historico').doc('2'), evento(2, {acao: 'vinculacao'}));
  await assertSucceeds(batch.commit());
  await assertSucceeds(banco('agente').collection('escala_atividades').doc('agenda-a').get());
  await assertFails(banco('agente').collection('agenda_operacional').doc('a').get());
  const snapshot = (await db.collection('escala_atividades').doc('agenda-a').get()).data();
  if ('contatoTelefone' in snapshot || 'observacoesInternas' in snapshot) throw Error('Dados privados no snapshot');
});
test('nega vínculo inventado e vazamento de contato para escala', async () => {
  const db = banco('responsavel'); await cadastro(db);
  await ambiente.withSecurityRulesDisabled(async context => context.firestore().collection('escalas').doc('2026-10-05').set(escala()));
  await assertFails(db.collection('escala_atividades').doc('outra').set(atividade()));
  await assertFails(db.collection('escala_atividades').doc('outra').set(atividade({contatoTelefone: 'privado'})));
});

test('revisão preserva origem da agenda sem conceder leitura privada ao gerente', async () => {
  await cadastro(banco('responsavel'));
  await ambiente.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    await db.collection('escalas').doc('2026-10-05').set(escala({status: 'publicada'}));
    await db.collection('escala_atividades').doc('agenda-a').set(atividade());
    await db.collection('agenda_operacional').doc('a').update({situacao: 'pronta', revisao: 2,
      escalaId: '2026-10-05', atividadeId: 'agenda-a', dataVinculada: data});
    await db.collection('escalas').doc('2026-10-05-v2').set(escala({versao: 2,
      revisaoDeEscalaId: '2026-10-05', motivoRevisao: 'Ajustar planejamento'}));
  });
  const gerente = banco('gerente');
  await assertSucceeds(gerente.collection('escala_atividades').doc('agenda-a-v2').set(atividade({
    escalaId: '2026-10-05-v2', agendaOrigemAtividadeId: 'agenda-a', atualizadoPor: 'gerente', criadoPor: 'gerente'})));
  await assertFails(gerente.collection('agenda_operacional').doc('a').get());
  await assertFails(gerente.collection('escala_atividades').doc('agenda-a-v2').update({agendaCompromissoId: 'forjado'}));
  const db = banco('responsavel'), ref = db.collection('agenda_operacional').doc('a');
  const batch = db.batch();
  batch.update(ref, {escalaId: '2026-10-05-v2', atividadeId: 'agenda-a-v2', revisao: 3, atualizadoEm: timestamp()});
  batch.update(db.collection('escala_atividades').doc('agenda-a-v2'), {agendaRevisao: 3, atualizadoEm: timestamp(), atualizadoPor: 'responsavel'});
  batch.set(ref.collection('historico').doc('3'), evento(3, {acao: 'aplicacao'}));
  await assertSucceeds(batch.commit());
  const antiga = (await db.collection('escala_atividades').doc('agenda-a').get()).data();
  if (antiga.agendaRevisao !== 2) throw Error('Snapshot histórico foi alterado');
});

test('responsável clona snapshot com coordenador e aplica planejamento editado', async () => {
  const db = banco('responsavel');
  await cadastro(db);
  const clone = atividade({escalaId: '2026-10-05-v2', status: 'publicada',
    coordenadorMembroEquipeId: 'membro-responsavel', coordenadorUsuarioId: 'responsavel',
    coordenadorNomeSnapshot: 'Responsável HML', participanteUsuarioIds: ['agente'],
    agendaOrigemAtividadeId: 'agenda-a', atualizadoPor: 'responsavel', criadoPor: 'responsavel'});
  await ambiente.withSecurityRulesDisabled(async context => {
    const seed = context.firestore();
    await seed.collection('escalas').doc('2026-10-05').set(escala({status: 'publicada'}));
    await seed.collection('equipe_operacional').doc('membro-responsavel').set({
      usuarioId: 'responsavel', ativo: true, podeCoordenar: true});
    await seed.collection('escala_atividades').doc('agenda-a').set({
      ...clone, escalaId: '2026-10-05', agendaOrigemAtividadeId: ''});
    await seed.collection('agenda_operacional').doc('a').update({situacao: 'pronta',
      revisao: 3, orientacaoEquipe: 'Nova orientação', escalaId: '2026-10-05',
      atividadeId: 'agenda-a', dataVinculada: data});
    await seed.collection('escalas').doc('2026-10-05-v2').set(escala({versao: 2,
      revisaoDeEscalaId: '2026-10-05', motivoRevisao: 'Ajustar planejamento'}));
  });
  await assertSucceeds(db.collection('escala_atividades').doc('agenda-a-v2').set(clone));
  await assertFails(db.collection('escala_atividades').doc('clone-revisao-forjada')
    .set({...clone, agendaRevisao: 99}));
  await assertFails(db.collection('escala_atividades').doc('clone-origem-forjada')
    .set({...clone, agendaOrigemAtividadeId: 'inexistente'}));
  await assertFails(banco('agente').collection('escala_atividades').doc('clone-sem-permissao')
    .set({...clone, criadoPor: 'agente', atualizadoPor: 'agente'}));
  const batch = db.batch();
  batch.update(db.collection('agenda_operacional').doc('a'), {
    escalaId: '2026-10-05-v2', atividadeId: 'agenda-a-v2', revisao: 4,
    atualizadoEm: timestamp()});
  batch.update(db.collection('escala_atividades').doc('agenda-a-v2'), {
    agendaRevisao: 4, orientacaoOperacional: 'Nova orientação', atualizadoEm: timestamp()});
  batch.set(db.collection('agenda_operacional').doc('a').collection('historico').doc('4'),
    evento(4, {acao: 'aplicacao'}));
  await assertSucceeds(batch.commit());
  const antiga = (await db.collection('escala_atividades').doc('agenda-a').get()).data();
  const nova = (await db.collection('escala_atividades').doc('agenda-a-v2').get()).data();
  if (antiga.agendaRevisao !== 2 || nova.agendaRevisao !== 4 ||
      nova.orientacaoOperacional !== 'Nova orientação') throw Error('Versões inconsistentes');
});
