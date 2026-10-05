'use strict';
// Todos os destinos são constantes loopback; nunca aceita projeto/host externo.
const assert = require('node:assert/strict');
const { randomUUID } = require('node:crypto');
const PROJECT = 'demo-geduc-ago001-hml';
const AUTH = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';
const DOCS = `http://127.0.0.1:8080/v1/projects/${PROJECT}/databases/(default)/documents`;
const PASSWORD = 'Ago001-Hml-2026!';
const USERS = [
  ['responsavel', 'Responsável HML', 'agente', true],
  ['participante', 'Participante HML', 'agente', true],
  ['externo', 'Agente externo HML', 'agente', true],
  ['gerente', 'Gerente HML', 'gerente', true],
  ['admin', 'Administrador HML', 'administrador', true],
  ['inativo', 'Inativo HML', 'agente', false],
];
async function request(url, { method = 'GET', token = '', body } = {}) {
  const response = await fetch(url, {method, signal: AbortSignal.timeout(10000),
    headers: { 'Content-Type': 'application/json', ...(token ? {Authorization: `Bearer ${token}`} : {}) },
    ...(body === undefined ? {} : {body: JSON.stringify(body)}) });
  const text = await response.text();
  return {status: response.status, data: text ? JSON.parse(text) : {}};
}
function ok(result, action) {
  if (result.status < 200 || result.status >= 300)
    throw new Error(`${action}: HTTP ${result.status} ${result.data.error?.message || ''}`);
  return result.data;
}
async function guard() {
  const hub = ok(await request('http://127.0.0.1:4400/emulators'), 'Hub local');
  for (const [name, port] of [['auth',9099], ['firestore',8080]]) {
    assert.equal(hub[name]?.port, port, `${name}: porta divergente`);
    assert.ok(['127.0.0.1','localhost'].includes(hub[name]?.host), `${name}: host não local`);
  }
}
function email(name) { return `${name}@ago001.example.test`; }
async function login(name) {
  const account = ok(await request(`${AUTH}/accounts:signInWithPassword?key=ago001-local-only`, {
    method: 'POST', body: {email: email(name), password: PASSWORD, returnSecureToken: true}
  }), `Login local ${name}`);
  validateAccount(account);
  return account;
}
function validateAccount(account) {
  const payload=JSON.parse(Buffer.from(account.idToken.split('.')[1],'base64url').toString());
  assert.equal(payload.aud,PROJECT,'Auth deve pertencer ao projeto demo AGO-001');
}
function value(v) {
  if(v === null) return {nullValue:null};
  if(v instanceof Date) return {timestampValue:v.toISOString()};
  if(Array.isArray(v)) return {arrayValue:{values:v.map(value)}};
  if(typeof v === 'boolean') return {booleanValue:v};
  if(typeof v === 'number') return {integerValue:String(v)};
  if(typeof v === 'object') return {mapValue:{fields:fields(v)}};
  return {stringValue:v};
}
function fields(v) {return Object.fromEntries(Object.entries(v).map(([k,x])=>[k,value(x)]));}
async function ensureDoc(path, data) {
  const existing = await request(`${DOCS}/${path}`, {token:'owner'});
  if(existing.status === 200) return;
  assert.equal(existing.status,404,`Consulta bootstrap ${path}`);
  ok(await request(`${DOCS}/${path}`, {method:'PATCH',token:'owner',body:{fields:fields(data)}}),`Bootstrap ${path}`);
}
async function seed() {
  await guard();
  const now = new Date();
  const accounts = {};
  for (const [name, label, role, active] of USERS) {
    const result = await request(`${AUTH}/accounts:signUp?key=ago001-local-only`, {
      method:'POST',body:{email:email(name),password:PASSWORD,returnSecureToken:true}
    });
    if(result.status !== 200) assert.equal(result.data.error?.message,'EMAIL_EXISTS');
    const account = result.status === 200 ? result.data : await login(name);
    validateAccount(account);
    accounts[name] = account.localId;
    await ensureDoc(`usuarios/${account.localId}`, {id:account.localId,nome:label,
      email:email(name),telefone:'',cargo:'HML',setor:'GEDUC',perfilAcesso:role,
      ativo:active,dataCriacao:now,ultimoAcesso:null,
      escopoAcesso:{scopeVersion:1,regionalIds:['regional-hml'],equipeIds:['geduc-hml'],projetoIds:['projeto-hml']}});
    if(['responsavel','participante','externo'].includes(name)) {
      await ensureDoc(`equipe_operacional/hml-${name}`, {usuarioId:account.localId,
        nome:label,vinculo:'agente',podeCoordenar:name==='responsavel',ativo:true,
        origem:'usuario',createdAt:now,updatedAt:now});
      await ensureDoc(`escala_perfis_operacionais/hml-${name}`, {membroEquipeId:`hml-${name}`,
        usuarioId:account.localId,setorCodigo:'GEDUC',cargaHorariaCodigo:'180H',ativo:true,
        criadoPor:'hml-bootstrap',criadoEm:now,atualizadoPor:'hml-bootstrap',atualizadoEm:now});
    }
  }
  await ensureDoc('escala_configuracoes/principal',{responsavelEscalaUsuarioId:accounts.responsavel,
    responsavelEscalaMembroEquipeId:'hml-responsavel',ativo:true,designadoPor:accounts.admin,designadoEm:now});
  await ensureDoc('projetos/projeto-hml',{nome:'Projeto Educativo HML',codigo:'HML-001',
    categoria:'Palestra',descricao:'Projeto fictício para homologação local.',ativo:true,ordem:1,
    objetivo:'Conferir agenda e escala.',publicoAlvo:'Participantes fictícios',
    regionalIds:['regional-hml'],equipeIds:['geduc-hml'],palavrasChave:['hml'],aliases:[]});
  await ensureDoc('regionais/regional-hml',{nome:'Regional HML',codigo:'HML',tipo:'administrativa',
    ativo:true,bairrosVinculados:['Bairro HML']});
  console.log('PASS: seis contas locais, efetivo GEDUC, responsável e catálogo preparados.');
  console.log('Contas: '+USERS.map(([name])=>email(name)).join(', '));
  console.log('Senha exclusiva do emulador: '+PASSWORD);
}
async function smoke() {
  await guard();
  const account = await login('responsavel');
  const id = `hml-smoke-${randomUUID()}`;
  const path = `agenda_operacional/${id}`;
  const name = `projects/${PROJECT}/databases/(default)/documents/${path}`;
  const day = new Date('2026-10-05T03:00:00.000Z');
  const item = {data:day,titulo:'HML teste descartável',turno:'manha',instituicao:'Escola fictícia',
    projetoId:'',natureza:'educativa',secaoId:'comandos_tematicos',horaInicio:'',horaFim:'',local:'',
    endereco:'',bairro:'',regionalId:'',referencia:'',contatoNome:'Contato privado HML',contatoTelefone:'',
    descricao:'',publico:'',quantidadePublico:null,integrantesNecessarios:null,materiais:'',
    observacoesInternas:'Privado',orientacaoEquipe:'',origem:'contato_direto',processo:'',
    situacao:'planejamento',motivo:'',revisao:1,escalaId:'',atividadeId:'',dataVinculada:null,
    criadoPor:account.localId,atualizadoPor:account.localId};
  try {
    ok(await request(`${DOCS}:commit`, {method:'POST',token:account.idToken,body:{writes:[
      {update:{name,fields:fields(item)},currentDocument:{exists:false},updateTransforms:[
        {fieldPath:'criadoEm',setToServerValue:'REQUEST_TIME'},
        {fieldPath:'atualizadoEm',setToServerValue:'REQUEST_TIME'}]},
      {update:{name:`${name}/historico/1`,fields:fields({acao:'cadastro',usuarioId:account.localId,
        motivo:'',revisao:1,dataAnterior:null,dataNova:day})},
        updateTransforms:[{fieldPath:'em',setToServerValue:'REQUEST_TIME'}]}
    ]}}), 'Cadastro privado via Auth emulado');
    ok(await request(`${DOCS}/${path}`,{token:account.idToken}),'Leitura do responsável');
    console.log('PASS: login real no Auth emulado, cadastro com histórico e leitura privada.');
    for (const [user] of USERS.filter(([u])=>u!=='responsavel')) {
      const other = await login(user);
      assert.equal((await request(`${DOCS}/${path}`,{token:other.idToken})).status,403,user);
      assert.equal((await request(`${DOCS}/${path}/historico/1`,{token:other.idToken})).status,403,user+' histórico');
      console.log(`PASS: agenda e histórico negados a ${user}.`);
    }
    assert.equal((await request(`${DOCS}/${path}`)).status,403);
    console.log('PASS: anônimo sem acesso.');
    const participant = await login('participante');
    ok(await request(`${DOCS}/equipe_operacional/hml-participante`,{token:participant.idToken}),'Efetivo operacional');
    console.log('PASS: participante lê efetivo operacional.');
  } finally {
    for(const suffix of ['/historico/1','']) {
      const result=await request(`${DOCS}/${path}${suffix}`,{method:'DELETE',token:'owner'});
      assert.ok([200,404].includes(result.status),'Limpeza do documento descartável');
    }
  }
}
async function main() {
  const mode=process.argv[2];
  if(!['seed','smoke'].includes(mode)) throw Error('Uso: node tools/ago001/hml.cjs seed|smoke');
  if(mode==='seed') await seed(); else await smoke();
}
main().catch(error=>{console.error(error.message);process.exitCode=1;});
