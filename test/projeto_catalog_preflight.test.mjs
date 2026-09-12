import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  FirestoreProjectCatalogReadOnlyReader,
  assertReadOnlyReaderSurface,
  classifyCatalogPreflight,
  executeCatalogRemotePreflight,
  parseArgs,
} from '../tools/catalogos/projeto_catalog_preflight.mjs';

import {
  SEED_PROJECT_ID,
  executeDryRun,
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

function firestoreDoc(id, contentHash = null) {
  const fields = {};

  if (contentHash !== null) {
    fields.contentHash = {
      stringValue: contentHash,
    };
  }

  return {
    name:
      `projects/${SEED_PROJECT_ID}/databases/(default)` +
      `/documents/projetos/${id}`,
    fields,
  };
}

test('CLI exige modo remoto read-only e project-id explicito', () => {
  assert.throws(
    () => parseArgs(['--project-id', SEED_PROJECT_ID]),
    /BUGRAE002E_PREFLIGHT_EXPLICIT_REMOTE_MODE_REQUIRED/u,
  );

  assert.throws(
    () =>
      parseArgs([
        '--remote-read-only',
        '--project-id',
        'outro-projeto',
      ]),
    /BUGRAE002E_PREFLIGHT_PROJECT_CONFIRMATION_MISMATCH/u,
  );

  const parsed = parseArgs([
    '--remote-read-only',
    '--project-id',
    SEED_PROJECT_ID,
  ]);

  assert.equal(parsed.mode, 'remote-read-only');
  assert.equal(parsed.projectId, SEED_PROJECT_ID);
});

test('--apply e sempre proibido', () => {
  assert.throws(
    () =>
      parseArgs([
        '--remote-read-only',
        '--project-id',
        SEED_PROJECT_ID,
        '--apply',
      ]),
    /BUGRAE002E_PREFLIGHT_APPLY_FORBIDDEN/u,
  );
});

test('reader expoe somente superficie read-only', () => {
  const reader = new FirestoreProjectCatalogReadOnlyReader({
    projectId: SEED_PROJECT_ID,
    fetchFn: async () => response(200, {}),
    accessTokenProvider: async () => TOKEN,
  });

  assert.equal(assertReadOnlyReaderSurface(reader), true);
  assert.equal(typeof reader.listCatalogDocuments, 'function');
  assert.equal(typeof reader.createOnly, 'undefined');
  assert.equal(typeof reader.createDocument, 'undefined');
  assert.equal(typeof reader.update, 'undefined');
  assert.equal(typeof reader.patch, 'undefined');
  assert.equal(typeof reader.delete, 'undefined');
});

test('reader usa somente GET, mascara contentHash e pagina', async () => {
  const calls = [];
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const a = local.plan[0];
  const b = local.plan[1];

  const queue = [
    response(200, {
      documents: [
        firestoreDoc(b.documentId, b.intendedContentHash),
      ],
      nextPageToken: 'next-page',
    }),
    response(200, {
      documents: [
        firestoreDoc(a.documentId, a.intendedContentHash),
      ],
    }),
  ];

  const reader = new FirestoreProjectCatalogReadOnlyReader({
    projectId: SEED_PROJECT_ID,
    pageSize: 1,
    fetchFn: async (url, options) => {
      calls.push({ url, options });
      return queue.shift();
    },
    accessTokenProvider: async () => TOKEN,
  });

  const result = await reader.listCatalogDocuments();

  assert.equal(result.pages, 2);
  assert.equal(result.documents.length, 2);
  assert.deepEqual(
    calls.map((call) => call.options.method),
    ['GET', 'GET'],
  );
  assert.equal(
    calls.every((call) =>
      call.url.includes('mask.fieldPaths=contentHash'),
    ),
    true,
  );
  assert.equal(
    calls.some((call) =>
      ['POST', 'PUT', 'PATCH', 'DELETE'].includes(
        call.options.method,
      ),
    ),
    false,
  );
});

test('colecao vazia classifica 53 missing e fica pronta', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const result = classifyCatalogPreflight({
    plan: local.plan,
    remoteDocuments: [],
  });

  assert.equal(result.ready, true);
  assert.equal(result.expected, 53);
  assert.equal(result.remote, 0);
  assert.equal(result.missing, 53);
  assert.equal(result.unchanged, 0);
  assert.equal(result.blockers.length, 0);
});

test('mesmo contentHash classifica unchanged', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const first = local.plan[0];

  const result = classifyCatalogPreflight({
    plan: local.plan,
    remoteDocuments: [
      {
        documentId: first.documentId,
        contentHash: first.intendedContentHash,
      },
    ],
  });

  assert.equal(result.ready, true);
  assert.equal(result.remote, 1);
  assert.equal(result.missing, 52);
  assert.equal(result.unchanged, 1);
  assert.equal(result.blockers.length, 0);
});

test('hash divergente bloqueia preflight', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const first = local.plan[0];

  const result = classifyCatalogPreflight({
    plan: local.plan,
    remoteDocuments: [
      {
        documentId: first.documentId,
        contentHash: 'hash-divergente',
      },
    ],
  });

  assert.equal(result.ready, false);
  assert.equal(result.changedPendingReview, 1);
  assert.equal(result.blockers.length, 1);
});

test('documento sem contentHash bloqueia preflight', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const first = local.plan[0];

  const result = classifyCatalogPreflight({
    plan: local.plan,
    remoteDocuments: [
      {
        documentId: first.documentId,
        contentHash: null,
      },
    ],
  });

  assert.equal(result.ready, false);
  assert.equal(result.existsWithoutComparableHash, 1);
});

test('documento remoto inesperado bloqueia preflight', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const result = classifyCatalogPreflight({
    plan: local.plan,
    remoteDocuments: [
      {
        documentId: 'documento-fora-do-manifesto',
        contentHash: 'abc',
      },
    ],
  });

  assert.equal(result.ready, false);
  assert.equal(result.unexpectedRemoteDocuments, 1);
  assert.equal(
    result.blockers[0].classification,
    'unexpected_remote_document',
  );
});

test('executor remoto usa reader injetado e nunca escreve', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  const first = local.plan[0];
  let listCalls = 0;

  const reader = {
    async listCatalogDocuments() {
      listCalls += 1;
      return {
        pages: 1,
        documents: [
          {
            documentId: first.documentId,
            contentHash: first.intendedContentHash,
          },
        ],
      };
    },
  };

  assert.equal(assertReadOnlyReaderSurface(reader), true);

  const result = await executeCatalogRemotePreflight({
    projectId: SEED_PROJECT_ID,
    reader,
  });

  assert.equal(listCalls, 1);
  assert.equal(result.mode, 'remote-read-only-preflight');
  assert.equal(result.firestoreReads, 1);
  assert.equal(result.firestoreWrites, 0);
  assert.equal(result.unchanged, 1);
  assert.equal(result.missing, 52);
});

test('modulo nao contem verbos HTTP de escrita', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_preflight.mjs',
    'utf8',
  );

  assert.equal(/method:\s*['"]POST['"]/u.test(source), false);
  assert.equal(/method:\s*['"]PUT['"]/u.test(source), false);
  assert.equal(/method:\s*['"]PATCH['"]/u.test(source), false);
  assert.equal(/method:\s*['"]DELETE['"]/u.test(source), false);
});
