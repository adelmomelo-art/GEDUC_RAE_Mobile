const { before, beforeEach, after, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

const projectId = 'geduc-rae-mobile-test';
let ambiente;

const perfis = {
  admin: { perfilAcesso: 'administrador', ativo: true },
  gestor: { perfilAcesso: 'gestor', ativo: true },
  coordenador: { perfilAcesso: 'coordenador', ativo: true },
  agente: { perfilAcesso: 'agente', ativo: true },
  inativo: { perfilAcesso: 'agente', ativo: false },
  desconhecido: { perfilAcesso: 'superusuario', ativo: true },
};

function dominioValido(sufixo = 'teste') {
  return {
    grupo: 'foco',
    codigo: `codigo-${sufixo}`,
    nome: `Domínio ${sufixo}`,
    ordem: 1,
    ativo: true,
    createdAt: new Date('2026-08-01T12:00:00.000Z'),
    updatedAt: new Date('2026-08-01T12:00:00.000Z'),
  };
}

function banco(uid) {
  return uid
    ? ambiente.authenticatedContext(uid).firestore()
    : ambiente.unauthenticatedContext().firestore();
}

async function semear() {
  await ambiente.withSecurityRulesDisabled(async (contexto) => {
    const db = contexto.firestore();

    for (const [uid, identidade] of Object.entries(perfis)) {
      await db.collection('usuarios').doc(uid).set({
        nome: uid,
        perfilAcesso: identidade.perfilAcesso,
        ativo: identidade.ativo,
      });
    }

    await db.collection('domains').doc('foco_teste').set(
      dominioValido('semente'),
    );
    const dominioLegado = dominioValido('legado');
    delete dominioLegado.createdAt;
    await db.collection('domains').doc('foco_legado').set(dominioLegado);
    await db.collection('tipos_acoes').doc('tipo-1').set({ nomeAcao: 'Teste' });
    await db.collection('coordenadores').doc('coord-1').set({ nome: 'Teste' });
    await db.collection('regionais').doc('regional-1').set({ nomeRegional: 'Teste' });
    await db.collection('materiais').doc('material-1').set({ nomeMaterial: 'Teste' });
    await db.collection('acoes').doc('acao-1').set({ status: 'rascunho' });
    await db.collection('contadores').doc('rae_2026').set({ ultimoNumero: 1 });
  });
}

before(async () => {
  ambiente = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

beforeEach(async () => {
  await ambiente.clearFirestore();
  await semear();
});

after(async () => {
  await ambiente.cleanup();
});

test('nega dados protegidos a usuário não autenticado', async () => {
  await assertFails(banco().collection('acoes').doc('acao-1').get());
  await assertFails(banco().collection('domains').get());
});

test('nega dados a autenticado sem documento de usuário', async () => {
  await assertFails(banco('sem-documento').collection('acoes').get());
  await assertFails(banco('sem-documento').collection('domains').get());
});

test('nega dados a usuário inativo e perfil desconhecido', async () => {
  await assertFails(banco('inativo').collection('acoes').get());
  await assertFails(banco('desconhecido').collection('acoes').get());
});

test('permite leitura do próprio documento para validar identidade', async () => {
  await assertSucceeds(banco('agente').collection('usuarios').doc('agente').get());
  await assertSucceeds(banco('inativo').collection('usuarios').doc('inativo').get());
  await assertFails(banco('agente').collection('usuarios').doc('admin').get());
});

test('somente administrador e gestor listam usuários', async () => {
  await assertSucceeds(banco('admin').collection('usuarios').get());
  await assertSucceeds(banco('gestor').collection('usuarios').get());
  await assertFails(banco('coordenador').collection('usuarios').get());
  await assertFails(banco('agente').collection('usuarios').get());
});

test('nenhum cliente altera perfil, situação ativa ou identidade', async () => {
  const proprio = banco('agente').collection('usuarios').doc('agente');
  await assertFails(proprio.update({ perfilAcesso: 'administrador' }));
  await assertFails(proprio.update({ ativo: false }));
  await assertFails(banco('admin').collection('usuarios').doc('novo').set({
    perfilAcesso: 'administrador', ativo: true,
  }));
  await assertFails(banco('admin').collection('usuarios').doc('agente').delete());
});

test('todos os perfis ativos leem catálogos operacionais', async () => {
  for (const uid of ['admin', 'gestor', 'coordenador', 'agente']) {
    await assertSucceeds(banco(uid).collection('domains').get());
    await assertSucceeds(banco(uid).collection('tipos_acoes').get());
    await assertSucceeds(banco(uid).collection('coordenadores').get());
    await assertSucceeds(banco(uid).collection('regionais').get());
    await assertSucceeds(banco(uid).collection('materiais').get());
  }
});

test('administrador e gestor gerenciam domínios e tipos de ações', async () => {
  for (const uid of ['admin', 'gestor']) {
    await assertSucceeds(
      banco(uid)
        .collection('domains')
        .doc(`novo-${uid}`)
        .set(dominioValido(uid)),
    );
    await assertSucceeds(banco(uid).collection('tipos_acoes').doc(`novo-${uid}`).set({ ativo: true }));
  }
  await assertFails(banco('coordenador').collection('domains').doc('novo').set({ ativo: true }));
  await assertFails(banco('agente').collection('tipos_acoes').doc('novo').set({ ativo: true }));
});

test('domínios exigem estrutura válida e preservam createdAt', async () => {
  const incompleto = banco('gestor').collection('domains').doc('incompleto');
  await assertFails(incompleto.set({ grupo: 'foco', ativo: true }));

  const existente = banco('admin').collection('domains').doc('foco_teste');
  await assertSucceeds(existente.update({
    nome: 'Domínio atualizado',
    updatedAt: new Date('2026-08-01T13:00:00.000Z'),
  }));
  await assertFails(existente.update({
    createdAt: new Date('2026-08-01T14:00:00.000Z'),
    updatedAt: new Date('2026-08-01T14:00:00.000Z'),
  }));
});

test('regulariza createdAt ausente em domínio legado uma única vez', async () => {
  const legado = banco('admin').collection('domains').doc('foco_legado');
  const createdAt = new Date('2026-08-08T12:00:00.000Z');

  await assertSucceeds(legado.update({
    nome: 'Domínio legado regularizado',
    createdAt,
    updatedAt: createdAt,
  }));

  await assertFails(legado.update({
    createdAt: new Date('2026-08-08T13:00:00.000Z'),
    updatedAt: new Date('2026-08-08T13:00:00.000Z'),
  }));
});

test('somente administrador gerencia coordenadores, regionais e materiais', async () => {
  for (const colecao of ['coordenadores', 'regionais', 'materiais']) {
    await assertSucceeds(banco('admin').collection(colecao).doc('novo').set({ ativo: true }));
    await assertFails(banco('gestor').collection(colecao).doc('gestor').set({ ativo: true }));
    await assertFails(banco('agente').collection(colecao).doc('agente').set({ ativo: true }));
  }
});

test('perfis ativos operam ações, mas somente administrador exclui', async () => {
  for (const uid of ['admin', 'gestor', 'coordenador', 'agente']) {
    const ref = banco(uid).collection('acoes').doc(`acao-${uid}`);
    await assertSucceeds(ref.set({ status: 'rascunho' }));
    await assertSucceeds(ref.update({ status: 'concluida' }));
    await assertSucceeds(ref.get());
  }
  await assertSucceeds(banco('admin').collection('acoes').doc('acao-admin').delete());
  await assertFails(banco('gestor').collection('acoes').doc('acao-gestor').delete());
  await assertFails(banco('agente').collection('acoes').doc('acao-agente').delete());
});

test('contador aceita transação operacional, nunca listagem ou exclusão', async () => {
  const ref = banco('agente').collection('contadores').doc('rae_2026');
  await assertSucceeds(ref.get());
  await assertSucceeds(ref.update({ ultimoNumero: 2 }));
  await assertFails(banco('agente').collection('contadores').get());
  await assertFails(ref.delete());
});

test('nega coleções não inventariadas', async () => {
  await assertFails(banco('admin').collection('nao_inventariada').doc('x').get());
  await assertFails(banco('admin').collection('nao_inventariada').doc('x').set({ valor: 1 }));
});

test('nega exclusão de cadastros administrativos', async () => {
  for (const colecao of ['domains', 'tipos_acoes', 'coordenadores', 'regionais', 'materiais']) {
    const primeiro = {
      domains: 'foco_teste', tipos_acoes: 'tipo-1', coordenadores: 'coord-1',
      regionais: 'regional-1', materiais: 'material-1',
    }[colecao];
    await assertFails(banco('admin').collection(colecao).doc(primeiro).delete());
  }
});

test('confirma pré-condições da matriz de testes', () => {
  assert.equal(perfis.admin.ativo, true);
  assert.equal(perfis.inativo.ativo, false);
  assert.equal(perfis.desconhecido.perfilAcesso, 'superusuario');
});
