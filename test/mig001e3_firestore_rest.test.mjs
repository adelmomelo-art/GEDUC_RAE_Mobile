import test from 'node:test';
import assert from 'node:assert/strict';

import {
  FirestoreRestWriter,
  assertWriterSurface,
  encodeFirestoreFields,
  encodeFirestoreValue,
} from '../tools/migration/mig001e3_firestore_rest.mjs';

function response(status, jsonBody = {}) {
  return {
    status,
    ok: status >= 200 && status < 300,
    async json() {
      return jsonBody;
    },
  };
}

function writerWithQueue(queue) {
  const calls = [];

  const fetchFn = async (url, options) => {
    calls.push({ url, options });

    if (queue.length === 0) {
      throw new Error('TEST_FETCH_QUEUE_EMPTY');
    }

    return queue.shift();
  };

  const writer = new FirestoreRestWriter({
    projectId: 'geduc-rae-mobile',
    fetchFn,
    accessTokenProvider: async () =>
      'test-access-token-abcdefghijklmnopqrstuvwxyz-0123456789-ABCDE',
  });

  return { writer, calls };
}

test('encoder Firestore preserva tipos suportados', () => {
  assert.deepEqual(encodeFirestoreValue(null), { nullValue: null });
  assert.deepEqual(encodeFirestoreValue(true), { booleanValue: true });
  assert.deepEqual(encodeFirestoreValue('x'), { stringValue: 'x' });
  assert.deepEqual(encodeFirestoreValue(12), { integerValue: '12' });
  assert.deepEqual(encodeFirestoreValue(1.5), { doubleValue: 1.5 });

  assert.deepEqual(
    encodeFirestoreFields({
      a: 1,
      b: ['x', false],
      c: { nested: 'ok' },
    }),
    {
      a: { integerValue: '1' },
      b: {
        arrayValue: {
          values: [
            { stringValue: 'x' },
            { booleanValue: false },
          ],
        },
      },
      c: {
        mapValue: {
          fields: {
            nested: { stringValue: 'ok' },
          },
        },
      },
    },
  );
});

test('writer nao expoe patch/update/delete', () => {
  const { writer } = writerWithQueue([]);

  assert.equal(typeof writer.createOnly, 'function');
  assert.equal(typeof writer.createDocument, 'function');
  assert.equal(typeof writer.getExistingContentHash, 'function');
  assert.equal(typeof writer.patch, 'undefined');
  assert.equal(typeof writer.update, 'undefined');
  assert.equal(typeof writer.delete, 'undefined');
  assert.equal(assertWriterSurface(writer), true);
});

test('denylist bloqueia acoes antes de qualquer fetch', async () => {
  const { writer, calls } = writerWithQueue([]);

  await assert.rejects(
    () =>
      writer.createOnly({
        collectionPath: 'acoes',
        documentId: 'x',
        payload: { contentHash: 'abc' },
      }),
    /MIG001E3_DENIED_ROOT:acoes/u,
  );

  assert.equal(calls.length, 0);
});

test('denylist bloqueia contadores antes de qualquer fetch', async () => {
  const { writer, calls } = writerWithQueue([]);

  await assert.rejects(
    () =>
      writer.createOnly({
        collectionPath: 'contadores',
        documentId: 'rae_2026',
        payload: { contentHash: 'abc' },
      }),
    /MIG001E3_DENIED_ROOT:contadores/u,
  );

  assert.equal(calls.length, 0);
});

test('documento inexistente executa GET e POST createDocument', async () => {
  const { writer, calls } = writerWithQueue([
    response(404),
    response(200, { name: 'created' }),
  ]);

  const result = await writer.createOnly({
    collectionPath: 'acoes_historicas',
    documentId: 'gf_abc',
    payload: { contentHash: 'hash-1', value: 10 },
  });

  assert.deepEqual(result, { outcome: 'created', wrote: true });
  assert.equal(calls.length, 2);
  assert.equal(calls[0].options.method, 'GET');
  assert.equal(calls[1].options.method, 'POST');
  assert.match(calls[1].url, /acoes_historicas\?documentId=gf_abc$/u);

  const body = JSON.parse(calls[1].options.body);
  assert.equal(body.fields.contentHash.stringValue, 'hash-1');
  assert.equal(body.fields.value.integerValue, '10');
});

test('mesmo hash existente retorna unchanged sem POST', async () => {
  const { writer, calls } = writerWithQueue([
    response(200, {
      fields: {
        contentHash: { stringValue: 'hash-1' },
      },
    }),
  ]);

  const result = await writer.createOnly({
    collectionPath: 'acoes_historicas',
    documentId: 'gf_abc',
    payload: { contentHash: 'hash-1' },
  });

  assert.deepEqual(result, { outcome: 'unchanged', wrote: false });
  assert.equal(calls.length, 1);
  assert.equal(calls[0].options.method, 'GET');
});

test('hash divergente existente retorna changed_pending_review sem POST', async () => {
  const { writer, calls } = writerWithQueue([
    response(200, {
      fields: {
        contentHash: { stringValue: 'hash-old' },
      },
    }),
  ]);

  const result = await writer.createOnly({
    collectionPath: 'acoes_historicas',
    documentId: 'gf_abc',
    payload: { contentHash: 'hash-new' },
  });

  assert.deepEqual(result, {
    outcome: 'changed_pending_review',
    wrote: false,
  });
  assert.equal(calls.length, 1);
});

test('conflito 409 apos GET revalida hash e nunca atualiza', async () => {
  const { writer, calls } = writerWithQueue([
    response(404),
    response(409),
    response(200, {
      fields: {
        contentHash: { stringValue: 'hash-1' },
      },
    }),
  ]);

  const result = await writer.createOnly({
    collectionPath: 'acoes_historicas',
    documentId: 'gf_abc',
    payload: { contentHash: 'hash-1' },
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

test('conflito 409 com hash divergente vira review e nunca atualiza', async () => {
  const { writer, calls } = writerWithQueue([
    response(404),
    response(409),
    response(200, {
      fields: {
        contentHash: { stringValue: 'outro-hash' },
      },
    }),
  ]);

  const result = await writer.createOnly({
    collectionPath: 'migration_google_forms_staging',
    documentId: 'gf_abc',
    payload: { contentHash: 'hash-1' },
  });

  assert.deepEqual(result, {
    outcome: 'changed_pending_review_after_race',
    wrote: false,
  });

  assert.equal(calls.length, 3);
  assert.equal(
    calls.some((call) => ['PATCH', 'PUT', 'DELETE'].includes(call.options.method)),
    false,
  );
});

test('subcolecao de journal produz URL REST correta', async () => {
  const { writer, calls } = writerWithQueue([
    response(404),
    response(200),
  ]);

  await writer.createOnly({
    collectionPath: 'migration_batches/pilot_001/changes',
    documentId: 'gf_abc_history',
    payload: {
      contentHash: 'hash-1',
      operation: 'CREATE',
    },
  });

  assert.match(
    calls[1].url,
    /migration_batches\/pilot_001\/changes\?documentId=gf_abc_history$/u,
  );
});

test('erros HTTP inesperados falham fechado', async () => {
  const { writer } = writerWithQueue([response(403)]);

  await assert.rejects(
    () =>
      writer.createOnly({
        collectionPath: 'acoes_historicas',
        documentId: 'gf_abc',
        payload: { contentHash: 'hash-1' },
      }),
    /MIG001E3_GET_FAILED:403/u,
  );
});