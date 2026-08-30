import test from 'node:test';
import assert from 'node:assert/strict';

import {
  buildGcloudAdcInvocation,
  createGcloudAdcTokenProvider,
  validateAccessToken,
} from '../tools/migration/mig001e4_adc.mjs';

import {
  FirestoreReadOnlyFingerprinter,
  assertFingerprintCollection,
  assertFingerprinterReadOnlySurface,
} from '../tools/migration/mig001e4_fingerprint.mjs';

import {
  PILOT_BATCH_ID,
  PILOT_MAX_CREATES,
  PILOT_PROJECT_ID,
  PILOT_SIZE,
  assertPilotConfig,
  buildPilotWriteSet,
  executePilotCreateOnly,
  preflightPilotTargets,
  summarizePilotWriteSet,
} from '../tools/migration/mig001e4_pilot.mjs';

const TEST_TOKEN =
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

function fakeTransformedRecords() {
  return Array.from({ length: PILOT_SIZE }, (_, index) => {
    const n = String(index + 1).padStart(2, '0');
    const id = `gf_${n.padEnd(64, n)}`;
    const sourceIdentityHash = n.padEnd(64, 'a');
    const historyHash = `history-hash-${n}`;
    const stagingHash = `staging-hash-${n}`;

    return {
      id,
      sourceIdentityHash,
      contentHash: historyHash,
      stagingContentHash: stagingHash,
      document: {
        recordType: 'historico_google_forms',
        contentHash: historyHash,
      },
      stagingDocument: {
        recordType: 'migration_staging_google_forms',
        contentHash: stagingHash,
      },
    };
  });
}

test('ADC invocation Windows usa comando fixo sem dados do usuario', () => {
  const invocation = buildGcloudAdcInvocation({
    platform: 'win32',
    comSpec: 'C:\\Windows\\System32\\cmd.exe',
  });

  assert.equal(invocation.command, 'C:\\Windows\\System32\\cmd.exe');
  assert.deepEqual(invocation.args, [
    '/d',
    '/s',
    '/c',
    'gcloud.cmd',
    'auth',
    'application-default',
    'print-access-token',
    '--quiet',
  ]);
});

test('ADC provider usa runner injetado e retorna token sem log', async () => {
  const calls = [];

  const provider = createGcloudAdcTokenProvider({
    invocation: {
      command: 'fake-gcloud',
      args: ['fixed'],
    },
    runner: async (invocation) => {
      calls.push(invocation);
      return {
        code: 0,
        stdout: `${TEST_TOKEN}\n`,
        stderr: 'ignored diagnostic',
      };
    },
  });

  const token = await provider();

  assert.equal(token, TEST_TOKEN);
  assert.deepEqual(calls, [
    {
      command: 'fake-gcloud',
      args: ['fixed'],
    },
  ]);
});

test('ADC provider falha fechado sem vazar stdout em mensagem', async () => {
  const secretLike = `${TEST_TOKEN}secret`;

  const provider = createGcloudAdcTokenProvider({
    runner: async () => ({
      code: 1,
      stdout: secretLike,
      stderr: 'internal',
    }),
    invocation: {
      command: 'fake',
      args: [],
    },
  });

  await assert.rejects(
    provider,
    (error) => {
      assert.equal(error.message, 'MIG001E4_ADC_COMMAND_FAILED');
      assert.equal(error.message.includes(secretLike), false);
      return true;
    },
  );
});

test('validateAccessToken rejeita curto e multiline', () => {
  assert.throws(
    () => validateAccessToken('short'),
    /MIG001E4_ADC_TOKEN_INVALID/u,
  );

  assert.throws(
    () => validateAccessToken(`${TEST_TOKEN}\nsecond`),
    /MIG001E4_ADC_TOKEN_INVALID/u,
  );
});

test('fingerprinter aceita somente acoes e contadores', () => {
  assert.equal(assertFingerprintCollection('acoes'), 'acoes');
  assert.equal(assertFingerprintCollection('contadores'), 'contadores');

  assert.throws(
    () => assertFingerprintCollection('usuarios'),
    /MIG001E4_FINGERPRINT_COLLECTION_DENIED:usuarios/u,
  );
});

test('fingerprinter nao expoe superficie de escrita', () => {
  const fingerprinter = new FirestoreReadOnlyFingerprinter({
    projectId: PILOT_PROJECT_ID,
    fetchFn: async () => response(200, {}),
    accessTokenProvider: async () => TEST_TOKEN,
  });

  assert.equal(typeof fingerprinter.fingerprintCollection, 'function');
  assert.equal(typeof fingerprinter.listCollectionDocuments, 'function');
  assert.equal(typeof fingerprinter.createOnly, 'undefined');
  assert.equal(typeof fingerprinter.patch, 'undefined');
  assert.equal(typeof fingerprinter.update, 'undefined');
  assert.equal(typeof fingerprinter.delete, 'undefined');
  assert.equal(assertFingerprinterReadOnlySurface(fingerprinter), true);
});

test('fingerprinter bloqueia colecao negada antes de fetch', async () => {
  const calls = [];

  const fingerprinter = new FirestoreReadOnlyFingerprinter({
    projectId: PILOT_PROJECT_ID,
    fetchFn: async (...args) => {
      calls.push(args);
      return response(200, {});
    },
    accessTokenProvider: async () => TEST_TOKEN,
  });

  await assert.rejects(
    () => fingerprinter.fingerprintCollection('usuarios'),
    /MIG001E4_FINGERPRINT_COLLECTION_DENIED:usuarios/u,
  );

  assert.equal(calls.length, 0);
});

test('fingerprint e deterministico apesar de ordem/paginacao', async () => {
  const docA = {
    name: 'projects/x/databases/(default)/documents/acoes/a',
    fields: { value: { integerValue: '1' } },
    createTime: '2026-01-01T00:00:00Z',
    updateTime: '2026-01-02T00:00:00Z',
  };

  const docB = {
    name: 'projects/x/databases/(default)/documents/acoes/b',
    fields: { value: { integerValue: '2' } },
    createTime: '2026-01-01T00:00:00Z',
    updateTime: '2026-01-02T00:00:00Z',
  };

  const queue1 = [
    response(200, {
      documents: [docB],
      nextPageToken: 'page2',
    }),
    response(200, {
      documents: [docA],
    }),
  ];

  const queue2 = [
    response(200, {
      documents: [docA, docB],
    }),
  ];

  const makeFingerprinter = (queue) =>
    new FirestoreReadOnlyFingerprinter({
      projectId: PILOT_PROJECT_ID,
      pageSize: 1,
      fetchFn: async (url, options) => {
        assert.equal(options.method, 'GET');
        assert.match(url, /\/acoes\?/u);
        const next = queue.shift();
        if (!next) throw new Error('TEST_QUEUE_EMPTY');
        return next;
      },
      accessTokenProvider: async () => TEST_TOKEN,
    });

  const fp1 = await makeFingerprinter(queue1).fingerprintCollection('acoes');
  const fp2 = await makeFingerprinter(queue2).fingerprintCollection('acoes');

  assert.equal(fp1.count, 2);
  assert.equal(fp1.pages, 2);
  assert.equal(fp2.count, 2);
  assert.equal(fp1.sha256, fp2.sha256);
  assert.equal(fp1.namesSha256, fp2.namesSha256);
});

test('pilot config exige projeto, batch, tamanho e modo controlados', () => {
  assert.equal(
    assertPilotConfig({
      projectId: PILOT_PROJECT_ID,
      batchId: PILOT_BATCH_ID,
      pilotSize: PILOT_SIZE,
      mode: 'pilot-preflight',
    }),
    true,
  );

  assert.throws(
    () =>
      assertPilotConfig({
        projectId: 'outro-projeto',
        batchId: PILOT_BATCH_ID,
        pilotSize: PILOT_SIZE,
        mode: 'pilot-preflight',
      }),
    /MIG001E4_PROJECT_CONFIRMATION_MISMATCH/u,
  );

  assert.throws(
    () =>
      assertPilotConfig({
        projectId: PILOT_PROJECT_ID,
        batchId: PILOT_BATCH_ID,
        pilotSize: 9,
        mode: 'pilot-preflight',
      }),
    /MIG001E4_PILOT_SIZE_MUST_BE_10/u,
  );

  assert.throws(
    () =>
      assertPilotConfig({
        projectId: PILOT_PROJECT_ID,
        batchId: PILOT_BATCH_ID,
        pilotSize: PILOT_SIZE,
        mode: 'apply',
      }),
    /MIG001E4_GENERIC_APPLY_FORBIDDEN/u,
  );
});

test('write set do piloto tem 31 creates e batch marker por ultimo', () => {
  const writes = buildPilotWriteSet(fakeTransformedRecords());
  const summary = summarizePilotWriteSet(writes);

  assert.equal(writes.length, PILOT_MAX_CREATES);
  assert.deepEqual(summary, {
    batch: 1,
    staging: 10,
    history: 10,
    journal: 10,
    total: 31,
  });

  assert.equal(writes.at(-1).collectionPath, 'migration_batches');
  assert.equal(writes.at(-1).documentId, PILOT_BATCH_ID);
  assert.equal(
    writes.every((write) => write.operation === 'CREATE_ONLY'),
    true,
  );

  assert.equal(
    writes.some((write) =>
      ['acoes', 'contadores'].includes(write.collectionPath.split('/')[0]),
    ),
    false,
  );
});

test('preflight de 31 missing fica pronto sem escrita', async () => {
  const writes = buildPilotWriteSet(fakeTransformedRecords());
  const calls = [];

  const writer = {
    async getExistingContentHash(collectionPath, documentId) {
      calls.push({ collectionPath, documentId });
      return { exists: false, contentHash: null };
    },
  };

  const result = await preflightPilotTargets({
    writer,
    writes,
  });

  assert.equal(result.ready, true);
  assert.equal(result.checked, 31);
  assert.equal(result.missing, 31);
  assert.equal(result.unchanged, 0);
  assert.equal(result.blockers.length, 0);
  assert.equal(calls.length, 31);
  assert.equal(typeof writer.createOnly, 'undefined');
});

test('preflight bloqueia hash divergente antes de qualquer create', async () => {
  const writes = buildPilotWriteSet(fakeTransformedRecords());

  function makeBlockingWriter() {
    let reads = 0;
    let creates = 0;

    return {
      get reads() {
        return reads;
      },
      get creates() {
        return creates;
      },
      async getExistingContentHash() {
        reads += 1;

        if (reads === 7) {
          return {
            exists: true,
            contentHash: 'different-hash',
          };
        }

        return { exists: false, contentHash: null };
      },
      async createOnly() {
        creates += 1;
        throw new Error('CREATE_MUST_NOT_RUN');
      },
    };
  }

  const preflightWriter = makeBlockingWriter();

  const preflight = await preflightPilotTargets({
    writer: preflightWriter,
    writes,
  });

  assert.equal(preflight.ready, false);
  assert.equal(preflight.checked, 31);
  assert.equal(preflight.blockers.length, 1);
  assert.equal(
    preflight.blockers[0].classification,
    'changed_pending_review',
  );
  assert.equal(preflightWriter.creates, 0);

  const executionWriter = makeBlockingWriter();

  await assert.rejects(
    () =>
      executePilotCreateOnly({
        writer: executionWriter,
        transformedRecords: fakeTransformedRecords(),
      }),
    /MIG001E4_PREFLIGHT_BLOCKED/u,
  );

  assert.equal(executionWriter.reads, 31);
  assert.equal(executionWriter.creates, 0);
});

test('executor percorre 31 CREATE_ONLY e escreve batch por ultimo', async () => {
  const createdCalls = [];

  const writer = {
    async getExistingContentHash() {
      return { exists: false, contentHash: null };
    },
    async createOnly(input) {
      createdCalls.push(input);
      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  const result = await executePilotCreateOnly({
    writer,
    transformedRecords: fakeTransformedRecords(),
  });

  assert.equal(result.created, 31);
  assert.equal(result.unchanged, 0);
  assert.equal(result.batchMarkerLast, true);
  assert.equal(createdCalls.length, 31);
  assert.equal(createdCalls.at(-1).collectionPath, 'migration_batches');
  assert.equal(createdCalls.at(-1).documentId, PILOT_BATCH_ID);
});

test('executor para na primeira falha e nao tenta batch marker', async () => {
  let writeCount = 0;
  const attempted = [];

  const writer = {
    async getExistingContentHash() {
      return { exists: false, contentHash: null };
    },
    async createOnly(input) {
      writeCount += 1;
      attempted.push(input);

      if (writeCount === 5) {
        throw new Error('SIMULATED_WRITE_FAILURE');
      }

      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  await assert.rejects(
    () =>
      executePilotCreateOnly({
        writer,
        transformedRecords: fakeTransformedRecords(),
      }),
    (error) => {
      assert.equal(error.message, 'MIG001E4_EXECUTION_STOPPED');
      assert.equal(error.details.completed, 4);
      assert.equal(error.details.batchMarkerAttempted, false);
      return true;
    },
  );

  assert.equal(writeCount, 5);
  assert.equal(
    attempted.some(
      (item) =>
        item.collectionPath === 'migration_batches' &&
        item.documentId === PILOT_BATCH_ID,
    ),
    false,
  );
});

test('rerun simulado converge para unchanged sem novos creates reais', async () => {
  let creates = 0;

  const writer = {
    async getExistingContentHash(collectionPath, documentId) {
      const writes = buildPilotWriteSet(fakeTransformedRecords());
      const match = writes.find(
        (item) =>
          item.collectionPath === collectionPath &&
          item.documentId === documentId,
      );

      return {
        exists: true,
        contentHash: match.payload.contentHash,
      };
    },
    async createOnly() {
      creates += 1;
      return {
        outcome: 'unchanged',
        wrote: false,
      };
    },
  };

  const result = await executePilotCreateOnly({
    writer,
    transformedRecords: fakeTransformedRecords(),
  });

  assert.equal(result.created, 0);
  assert.equal(result.unchanged, 31);
  assert.equal(result.batchMarkerLast, true);
  assert.equal(creates, 31);
});