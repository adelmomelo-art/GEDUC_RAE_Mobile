const { before, beforeEach, after, test } = require('node:test');
const fs = require('node:fs');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

let ambiente;

function banco(uid) {
  return ambiente.authenticatedContext(uid).firestore();
}

function rae(overrides = {}) {
  return {
    aclClassificacaoCompleta: true,
    aclScopeKey: 'r:regional-1|e:equipe-1|p:projeto-1',
    responsavelUserId: 'agente-1',
    coordenadorUserId: 'coordenador-1',
    regionalId: 'regional-1',
    equipeId: 'equipe-1',
    projetoId: 'projeto-1',
    status: 'rascunho',
    conteudoOperacional: 'inicial',
    ...overrides,
  };
}

before(async () => {
  ambiente = await initializeTestEnvironment({
    projectId: 'geduc-rae-acl001-stage4a-test',
    firestore: {
      rules: fs.readFileSync(
        'test/fixtures/firestore_acl001_stage4a.rules',
        'utf8',
      ),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

beforeEach(async () => {
  await ambiente.clearFirestore();
  await ambiente.withSecurityRulesDisabled(async (contexto) => {
    const db = contexto.firestore();
    const usuarios = {
      admin: { perfilAcesso: 'administrador', ativo: true },
      gestor: { perfilAcesso: 'gestor', ativo: true },
      'gerente-1': {
        perfilAcesso: 'gerente',
        ativo: true,
        escopoAcesso: {
          regionalIds: ['regional-1'],
          equipeIds: ['equipe-1'],
          projetoIds: ['projeto-1'],
        },
        aclScopeKeys: ['r:regional-1|e:equipe-1|p:projeto-1'],
      },
      'gerente-2': {
        perfilAcesso: 'gerente',
        ativo: true,
        escopoAcesso: {
          regionalIds: ['regional-2'],
          equipeIds: ['equipe-2'],
          projetoIds: ['projeto-2'],
        },
        aclScopeKeys: ['r:regional-2|e:equipe-2|p:projeto-2'],
      },
      'coordenador-1': { perfilAcesso: 'coordenador', ativo: true },
      'coordenador-2': { perfilAcesso: 'coordenador', ativo: true },
      'agente-1': { perfilAcesso: 'agente', ativo: true },
      'agente-2': { perfilAcesso: 'agente', ativo: true },
    };
    for (const [id, dados] of Object.entries(usuarios)) {
      await db.collection('usuarios').doc(id).set(dados);
    }
    await db.collection('acoes').doc('completo').set(rae());
    await db.collection('acoes').doc('q1').set(rae({
      aclClassificacaoCompleta: false,
      aclScopeKey: '',
      responsavelUserId: '',
      coordenadorUserId: '',
      equipeId: '',
      projetoId: '',
    }));
  });
});

after(async () => ambiente.cleanup());

test('Q1 fica visível somente ao Administrador', async () => {
  await assertSucceeds(banco('admin').collection('acoes').doc('q1').get());
  for (const uid of ['gestor', 'gerente-1', 'coordenador-1', 'agente-1']) {
    await assertFails(banco(uid).collection('acoes').doc('q1').get());
  }
});

test('Gestor lê RAE completo, mas não altera', async () => {
  const ref = banco('gestor').collection('acoes').doc('completo');
  await assertSucceeds(ref.get());
  await assertFails(ref.update({ status: 'concluido' }));
});

test('Gerente exige a interseção das três dimensões', async () => {
  await assertSucceeds(
    banco('gerente-1').collection('acoes').doc('completo').get(),
  );
  await assertFails(
    banco('gerente-2').collection('acoes').doc('completo').get(),
  );
  await assertFails(
    banco('gerente-1').collection('acoes').doc('completo').update({
      status: 'concluido',
    }),
  );
});

test('Coordenador altera somente RAE sob sua coordenação', async () => {
  await assertSucceeds(
    banco('coordenador-1').collection('acoes').doc('completo').update({
      status: 'revisado',
      revisadoPor: 'coordenador-1',
    }),
  );
  await assertFails(
    banco('coordenador-2').collection('acoes').doc('completo').update({
      status: 'revisado',
      revisadoPor: 'coordenador-2',
    }),
  );
});

test('Agente altera somente o próprio RAE', async () => {
  await assertSucceeds(
    banco('agente-1').collection('acoes').doc('completo').update({
      conteudoOperacional: 'editado pelo responsável',
    }),
  );
  await assertFails(
    banco('agente-2').collection('acoes').doc('completo').update({
      conteudoOperacional: 'tentativa externa',
    }),
  );
  await assertFails(
    banco('agente-1').collection('acoes').doc('completo').update({
      status: 'finalizado',
    }),
  );
});

test('Gestor e Gerente não criam RAE', async () => {
  await assertFails(banco('gestor').collection('acoes').doc('novo-g').set(rae()));
  await assertFails(
    banco('gerente-1').collection('acoes').doc('novo-r').set(rae()),
  );
  await assertSucceeds(
    banco('agente-1').collection('acoes').doc('novo-a').set(rae()),
  );
});

test('consultas de coleção repetem as restrições das regras', async () => {
  await assertFails(banco('gerente-1').collection('acoes').get());
  await assertSucceeds(
    banco('gestor')
      .collection('acoes')
      .where('aclClassificacaoCompleta', '==', true)
      .get(),
  );
  await assertSucceeds(
    banco('gerente-1')
      .collection('acoes')
      .where('aclClassificacaoCompleta', '==', true)
      .where('aclScopeKey', 'in', [
        'r:regional-1|e:equipe-1|p:projeto-1',
      ])
      .get(),
  );
  await assertSucceeds(
    banco('coordenador-1')
      .collection('acoes')
      .where('aclClassificacaoCompleta', '==', true)
      .where('coordenadorUserId', '==', 'coordenador-1')
      .get(),
  );
  await assertSucceeds(
    banco('agente-1')
      .collection('acoes')
      .where('aclClassificacaoCompleta', '==', true)
      .where('responsavelUserId', '==', 'agente-1')
      .get(),
  );
});
