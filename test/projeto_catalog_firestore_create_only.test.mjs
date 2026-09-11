import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  FirestoreProjectCatalogCreateOnlyAdapter,
  assertRemoteAdapterSurface,
  encodeFirestoreFields,
} from '../tools/catalogos/projeto_catalog_firestore_create_only.mjs';

import {
  executeCatalogCreateOnly,
} from '../tools/catalogos/projeto_catalog_executor.mjs';

import {
  SEED_PROJECT_ID,
} from '../tools/catalogos/projeto_catalog_seed.mjs';

const TOKEN =
  'test-access-token-abcdefghijklmnopqrstuvwxyz-0123456789-ABCDE';

function response(status, jsonBody = {}) {
  return {
    status,
    ok: status >= 200 && status < 300,
    async json() {
      return jsonBody;
    },
  };
}

function makeAdapter(queue) {
  const calls = [];

  const adapter =
    new FirestoreProjectCatalogCreateOnlyAdapter({
      projectId: SEED_PROJECT_ID,
      fetchFn: async (url, options) => {
        calls.push({ url, options });
        const next = queue.shift();

        if (!next) {
          throw new Error('TEST_QUEUE_EMPTY');
        }

        return next;
      },
      accessTokenProvider: async () => TOKEN,
    });

  return {
    adapter,
    calls,
  };
}

test('adapter aceita somente projeto oficial', () => {
  assert.throws(
    () =>
      new FirestoreProjectCatalogCreateOnlyAdapter({
        projectId: 'outro-projeto',
        fetchFn: async () => response(200),
        accessTokenProvider: async () => TOKEN,
      }),
    /BUGRAE002E_REMOTE_PROJECT_CONFIRMATION_MISMATCH/u,
  );
});

test('superficie publica e somente GET hash + createOnly', () => {
  const { adapter } = makeAdapter([]);

  assert.equal(assertRemoteAdapterSurface(adapter), true);
  assert.equal(typeof adapter.getExistingContentHash, 'function');
  assert.equal(typeof adapter.createOnly, 'function');
  assert.equal(typeof adapter.createDocument, 'undefined');
  assert.equal(typeof adapter.update, 'undefined');
  assert.equal(typeof adapter.patch, 'undefined');
  assert.equal(typeof adapter.delete, 'undefined');
});

test('colecao diferente de projetos e bloqueada antes de fetch', async () => {
  const { adapter, calls } = makeAdapter([]);

  await assert.rejects(
    () =>
      adapter.getExistingContentHash(
        'acoes',
        'x',
      ),
    /BUGRAE002E_REMOTE_COLLECTION_DENIED/u,
  );

  assert.equal(calls.length, 0);
});

test('encoder cobre contrato institucional do projeto', () => {
  const encoded = encodeFirestoreFields({
    nome: 'Projeto',
    codigo: 'AE-001',
    categoria: 'Ação Educativa',
    descricao: '',
    objetivo: '',
    publicoAlvo: '',
    palavrasChave: ['a', 'b'],
    aliases: [],
    regionalIds: [],
    equipeIds: [],
    ordem: 1,
    ativo: true,
    contentHash: 'hash-1',
  });

  assert.equal(encoded.nome.stringValue, 'Projeto');
  assert.equal(encoded.ordem.integerValue, '1');
  assert.equal(encoded.ativo.booleanValue, true);
  assert.equal(
    encoded.palavrasChave.arrayValue.values[0].stringValue,
    'a',
  );
});

test('GET 404 retorna missing', async () => {
  const { adapter, calls } = makeAdapter([
    response(404),
  ]);

  const result =
    await adapter.getExistingContentHash(
      'projetos',
      'ae_001',
    );

  assert.deepEqual(result, {
    exists: false,
    contentHash: null,
  });

  assert.equal(calls.length, 1);
  assert.equal(calls[0].options.method, 'GET');
  assert.match(
    calls[0].url,
    /projetos\/ae_001\?mask\.fieldPaths=contentHash$/u,
  );
});

test('mesmo hash retorna unchanged sem POST', async () => {
  const { adapter, calls } = makeAdapter([
    response(200, {
      fields: {
        contentHash: {
          stringValue: 'hash-1',
        },
      },
    }),
  ]);

  const result =
    await adapter.createOnly({
      collectionPath: 'projetos',
      documentId: 'ae_001',
      payload: {
        nome: 'Projeto',
        contentHash: 'hash-1',
      },
      intendedContentHash: 'hash-1',
    });

  assert.deepEqual(result, {
    outcome: 'unchanged',
    wrote: false,
  });

  assert.deepEqual(
    calls.map((call) => call.options.method),
    ['GET'],
  );
});

test('hash divergente retorna review sem POST', async () => {
  const { adapter, calls } = makeAdapter([
    response(200, {
      fields: {
        contentHash: {
          stringValue: 'hash-antigo',
        },
      },
    }),
  ]);

  const result =
    await adapter.createOnly({
      collectionPath: 'projetos',
      documentId: 'ae_001',
      payload: {
        nome: 'Projeto',
        contentHash: 'hash-novo',
      },
      intendedContentHash: 'hash-novo',
    });

  assert.equal(
    result.outcome,
    'changed_pending_review',
  );
  assert.equal(result.wrote, false);
  assert.equal(calls.length, 1);
});

test('documento sem hash comparavel bloqueia sem POST', async () => {
  const { adapter, calls } = makeAdapter([
    response(200, {
      fields: {
        nome: {
          stringValue: 'Legado',
        },
      },
    }),
  ]);

  const result =
    await adapter.createOnly({
      collectionPath: 'projetos',
      documentId: 'ae_001',
      payload: {
        nome: 'Projeto',
        contentHash: 'hash-novo',
      },
      intendedContentHash: 'hash-novo',
    });

  assert.equal(
    result.outcome,
    'exists_without_comparable_hash',
  );
  assert.equal(result.wrote, false);
  assert.equal(calls.length, 1);
});

test('missing executa GET seguido de POST create-only', async () => {
  const { adapter, calls } = makeAdapter([
    response(404),
    response(200, {
      name: 'created',
    }),
  ]);

  const result =
    await adapter.createOnly({
      collectionPath: 'projetos',
      documentId: 'ae_001',
      payload: {
        nome: 'Projeto',
        ordem: 1,
        ativo: true,
        contentHash: 'hash-1',
      },
      intendedContentHash: 'hash-1',
    });

  assert.deepEqual(result, {
    outcome: 'created',
    wrote: true,
  });

  assert.deepEqual(
    calls.map((call) => call.options.method),
    ['GET', 'POST'],
  );

  assert.match(
    calls[1].url,
    /\/projetos\?documentId=ae_001$/u,
  );

  const body = JSON.parse(calls[1].options.body);

  assert.equal(
    body.fields.contentHash.stringValue,
    'hash-1',
  );
  assert.equal(
    body.fields.ordem.integerValue,
    '1',
  );
});

test('conflito 409 revalida hash e converge para unchanged', async () => {
  const { adapter, calls } = makeAdapter([
    response(404),
    response(409),
    response(200, {
      fields: {
        contentHash: {
          stringValue: 'hash-1',
        },
      },
    }),
  ]);

  const result =
    await adapter.createOnly({
      collectionPath: 'projetos',
      documentId: 'ae_001',
      payload: {
        nome: 'Projeto',
        contentHash: 'hash-1',
      },
      intendedContentHash: 'hash-1',
    });

  assert.deepEqual(result, {
    outcome: 'unchanged_after_race',
    wrote: false,
  });

  assert.deepEqual(
    calls.map((call) => call.options.method),
    ['GET', 'POST', 'GET'],
  );
});

test('conflito 409 com hash divergente nunca atualiza', async () => {
  const { adapter, calls } = makeAdapter([
    response(404),
    response(409),
    response(200, {
      fields: {
        contentHash: {
          stringValue: 'outro-hash',
        },
      },
    }),
  ]);

  const result =
    await adapter.createOnly({
      collectionPath: 'projetos',
      documentId: 'ae_001',
      payload: {
        nome: 'Projeto',
        contentHash: 'hash-1',
      },
      intendedContentHash: 'hash-1',
    });

  assert.equal(
    result.outcome,
    'changed_pending_review_after_race',
  );

  assert.equal(
    calls.some((call) =>
      ['PUT', 'PATCH', 'DELETE'].includes(
        call.options.method,
      ),
    ),
    false,
  );
});

test('erro HTTP inesperado falha fechado', async () => {
  const { adapter } = makeAdapter([
    response(403),
  ]);

  await assert.rejects(
    () =>
      adapter.getExistingContentHash(
        'projetos',
        'ae_001',
      ),
    /BUGRAE002E_REMOTE_GET_FAILED/u,
  );
});

test('payload e intended hash precisam coincidir', async () => {
  const { adapter, calls } = makeAdapter([]);

  await assert.rejects(
    () =>
      adapter.createOnly({
        collectionPath: 'projetos',
        documentId: 'ae_001',
        payload: {
          contentHash: 'hash-a',
        },
        intendedContentHash: 'hash-b',
      }),
    /BUGRAE002E_REMOTE_PAYLOAD_HASH_MISMATCH/u,
  );

  assert.equal(calls.length, 0);
});

test('integracao executor + adapter simula 53 creates sem rede real', async () => {
  const store = new Map();
  const methods = [];

  const fakeFetch =
    async (url, options) => {
      methods.push(options.method);

      const parsed = new URL(url);
      const path = decodeURIComponent(parsed.pathname);

      if (options.method === 'GET') {
        const marker = '/documents/projetos/';
        const index = path.indexOf(marker);

        assert.notEqual(index, -1);

        const id = path.slice(index + marker.length);

        if (!store.has(id)) {
          return response(404);
        }

        return response(200, {
          fields: {
            contentHash: {
              stringValue: store.get(id),
            },
          },
        });
      }

      if (options.method === 'POST') {
        assert.equal(
          path.endsWith('/documents/projetos'),
          true,
        );

        const id = parsed.searchParams.get('documentId');
        const body = JSON.parse(options.body);
        const hash =
          body.fields.contentHash.stringValue;

        if (store.has(id)) {
          return response(409);
        }

        store.set(id, hash);

        return response(200, {
          name: id,
        });
      }

      throw new Error(
        `UNEXPECTED_METHOD:${options.method}`,
      );
    };

  const adapter =
    new FirestoreProjectCatalogCreateOnlyAdapter({
      projectId: SEED_PROJECT_ID,
      fetchFn: fakeFetch,
      accessTokenProvider: async () => TOKEN,
    });

  const result =
    await executeCatalogCreateOnly({
      writer: adapter,
      projectId: SEED_PROJECT_ID,
    });

  assert.equal(result.completed, 53);
  assert.equal(result.created, 53);
  assert.equal(result.unchanged, 0);
  assert.equal(store.size, 53);

  assert.equal(
    methods.some((method) =>
      ['PUT', 'PATCH', 'DELETE'].includes(method),
    ),
    false,
  );
});

test('rerun integrado converge para 53 unchanged', async () => {
  const store = new Map();

  const fakeFetch =
    async (url, options) => {
      const parsed = new URL(url);
      const path = decodeURIComponent(parsed.pathname);

      if (options.method === 'GET') {
        const marker = '/documents/projetos/';
        const index = path.indexOf(marker);
        const id = path.slice(index + marker.length);

        if (!store.has(id)) {
          return response(404);
        }

        return response(200, {
          fields: {
            contentHash: {
              stringValue: store.get(id),
            },
          },
        });
      }

      if (options.method === 'POST') {
        const id = parsed.searchParams.get('documentId');
        const body = JSON.parse(options.body);
        store.set(
          id,
          body.fields.contentHash.stringValue,
        );
        return response(200);
      }

      throw new Error(
        `UNEXPECTED_METHOD:${options.method}`,
      );
    };

  const adapter =
    new FirestoreProjectCatalogCreateOnlyAdapter({
      projectId: SEED_PROJECT_ID,
      fetchFn: fakeFetch,
      accessTokenProvider: async () => TOKEN,
    });

  const first =
    await executeCatalogCreateOnly({
      writer: adapter,
      projectId: SEED_PROJECT_ID,
    });

  const second =
    await executeCatalogCreateOnly({
      writer: adapter,
      projectId: SEED_PROJECT_ID,
    });

  assert.equal(first.created, 53);
  assert.equal(second.created, 0);
  assert.equal(second.unchanged, 53);
  assert.equal(store.size, 53);
});

test('modulo nao possui ADC, gcloud ou CLI autoexecutavel', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_firestore_create_only.mjs',
    'utf8',
  );

  assert.equal(
    source.includes('mig001e4_adc'),
    false,
  );
  assert.equal(
    source.includes('application-default'),
    false,
  );
  assert.equal(
    source.includes('gcloud'),
    false,
  );
  assert.equal(
    source.includes('process.argv'),
    false,
  );
  assert.equal(
    source.includes('pathToFileURL'),
    false,
  );
});

test('unicos verbos HTTP literais do modulo sao GET e POST', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_firestore_create_only.mjs',
    'utf8',
  );

  const methods = [
    ...source.matchAll(
      /method:\s*['"]([A-Z]+)['"]/gu,
    ),
  ].map((match) => match[1]);

  assert.deepEqual(
    [...new Set(methods)].sort(),
    ['GET', 'POST'],
  );
});
