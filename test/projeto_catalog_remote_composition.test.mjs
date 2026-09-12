import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  createCatalogRemoteReadOnlyComposition,
  createProductionCatalogReadOnlyComposition,
  memoizeAccessTokenProvider,
} from '../tools/catalogos/projeto_catalog_remote_composition.mjs';

import {
  SEED_PROJECT_ID,
  executeDryRun,
} from '../tools/catalogos/projeto_catalog_seed.mjs';

const TOKEN =
  'test-access-token-abcdefghijklmnopqrstuvwxyz-0123456789-ABCDE';

function response(status, body = {}) {
  return {
    status,
    ok: status >= 200 && status < 300,
    async json() {
      return body;
    },
  };
}

test('composicao aceita somente projeto oficial', () => {
  assert.throws(
    () =>
      createCatalogRemoteReadOnlyComposition({
        projectId: 'outro-projeto',
        fetchFn: async () => response(404),
        accessTokenProvider: async () => TOKEN,
      }),
    /BUGRAE002E_COMPOSITION_PROJECT_CONFIRMATION_MISMATCH/u,
  );
});

test('token provider e memoizado durante a composicao', async () => {
  let calls = 0;

  const provider =
    memoizeAccessTokenProvider(async () => {
      calls += 1;
      return TOKEN;
    });

  assert.equal(await provider(), TOKEN);
  assert.equal(await provider(), TOKEN);
  assert.equal(calls, 1);
});

test('falha do token nao fica cacheada', async () => {
  let calls = 0;

  const provider =
    memoizeAccessTokenProvider(async () => {
      calls += 1;

      if (calls === 1) {
        throw new Error('TOKEN_FAIL');
      }

      return TOKEN;
    });

  await assert.rejects(
    () => provider(),
    /TOKEN_FAIL/u,
  );

  assert.equal(await provider(), TOKEN);
  assert.equal(calls, 2);
});

test('superficie publica nao expoe escrita nem adapter', () => {
  const composition =
    createCatalogRemoteReadOnlyComposition({
      projectId: SEED_PROJECT_ID,
      fetchFn: async () => response(404),
      accessTokenProvider: async () => TOKEN,
    });

  assert.equal(
    typeof composition.runReadOnlyPreflight,
    'function',
  );
  assert.equal(composition.remoteWriteEnabled, false);
  assert.equal(composition.createOnly, undefined);
  assert.equal(composition.executeWrite, undefined);
  assert.equal(composition.adapter, undefined);
});

test('preflight remoto composto faz 53 GET e zero escrita', async () => {
  const methods = [];
  let tokenCalls = 0;

  const composition =
    createCatalogRemoteReadOnlyComposition({
      projectId: SEED_PROJECT_ID,
      fetchFn: async (_url, options) => {
        methods.push(options.method);
        return response(404);
      },
      accessTokenProvider: async () => {
        tokenCalls += 1;
        return TOKEN;
      },
    });

  const result =
    await composition.runReadOnlyPreflight();

  assert.equal(result.mode, 'remote-read-only-composition');
  assert.equal(result.expected, 53);
  assert.equal(result.checked, 53);
  assert.equal(result.missing, 53);
  assert.equal(result.unchanged, 0);
  assert.equal(result.blockers.length, 0);
  assert.equal(result.ready, true);
  assert.equal(result.remoteWriteEnabled, false);
  assert.equal(result.firestoreWrites, 0);

  assert.equal(methods.length, 53);
  assert.equal(
    methods.every((method) => method === 'GET'),
    true,
  );
  assert.equal(tokenCalls, 1);
});

test('documento com mesmo hash converge para unchanged', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const hashes = new Map(
    local.plan.map((item) => [
      item.documentId,
      item.intendedContentHash,
    ]),
  );

  const methods = [];

  const composition =
    createCatalogRemoteReadOnlyComposition({
      projectId: SEED_PROJECT_ID,
      fetchFn: async (url, options) => {
        methods.push(options.method);

        const parsed = new URL(url);
        const marker = '/documents/projetos/';
        const decoded = decodeURIComponent(parsed.pathname);
        const index = decoded.indexOf(marker);
        const documentId =
          decoded.slice(index + marker.length);

        return response(200, {
          fields: {
            contentHash: {
              stringValue: hashes.get(documentId),
            },
          },
        });
      },
      accessTokenProvider: async () => TOKEN,
    });

  const result =
    await composition.runReadOnlyPreflight();

  assert.equal(result.ready, true);
  assert.equal(result.missing, 0);
  assert.equal(result.unchanged, 53);
  assert.equal(result.firestoreWrites, 0);
  assert.equal(
    methods.every((method) => method === 'GET'),
    true,
  );
});

test('hash divergente bloqueia sem qualquer escrita', async () => {
  let count = 0;
  const methods = [];

  const composition =
    createCatalogRemoteReadOnlyComposition({
      projectId: SEED_PROJECT_ID,
      fetchFn: async (_url, options) => {
        count += 1;
        methods.push(options.method);

        if (count === 4) {
          return response(200, {
            fields: {
              contentHash: {
                stringValue: 'hash-divergente',
              },
            },
          });
        }

        return response(404);
      },
      accessTokenProvider: async () => TOKEN,
    });

  const result =
    await composition.runReadOnlyPreflight();

  assert.equal(result.ready, false);
  assert.equal(result.blockers.length, 1);
  assert.equal(result.firestoreWrites, 0);
  assert.equal(methods.length, 53);
  assert.equal(
    methods.every((method) => method === 'GET'),
    true,
  );
});

test('factory de producao compoe ADC uma unica vez por preflight', async () => {
  let factoryCalls = 0;
  let tokenCalls = 0;
  const methods = [];

  const composition =
    createProductionCatalogReadOnlyComposition({
      projectId: SEED_PROJECT_ID,

      adcTokenProviderFactory: () => {
        factoryCalls += 1;

        return async () => {
          tokenCalls += 1;
          return TOKEN;
        };
      },

      fetchFn: async (_url, options) => {
        methods.push(options.method);
        return response(404);
      },
    });

  assert.equal(factoryCalls, 1);

  const result =
    await composition.runReadOnlyPreflight();

  assert.equal(result.ready, true);
  assert.equal(tokenCalls, 1);
  assert.equal(methods.length, 53);
  assert.equal(
    methods.every((method) => method === 'GET'),
    true,
  );
});

test('modulo importa ADC existente mas nao possui CLI executavel', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_remote_composition.mjs',
    'utf8',
  );

  assert.equal(
    source.includes('../migration/mig001e4_adc.mjs'),
    true,
  );
  assert.equal(
    source.includes('./projeto_catalog_executor.mjs'),
    true,
  );
  assert.equal(
    source.includes('./projeto_catalog_firestore_create_only.mjs'),
    true,
  );

  assert.equal(source.includes('process.argv'), false);
  assert.equal(source.includes('pathToFileURL'), false);
});

test('composicao nao contem verbos HTTP de escrita', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_remote_composition.mjs',
    'utf8',
  );

  const methods = [
    ...source.matchAll(
      /method:\s*['"]([A-Z]+)['"]/gu,
    ),
  ].map((match) => match[1]);

  assert.deepEqual(methods, []);

  assert.equal(source.includes("method: 'POST'"), false);
  assert.equal(source.includes('method: "POST"'), false);
  assert.equal(source.includes("method: 'PATCH'"), false);
  assert.equal(source.includes("method: 'PUT'"), false);
  assert.equal(source.includes("method: 'DELETE'"), false);
});
