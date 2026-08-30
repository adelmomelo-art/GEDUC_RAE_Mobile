import test from 'node:test';
import assert from 'node:assert/strict';

import {
  PROBE_BATCH_ID,
  PROBE_DOCUMENT_ID,
  PROBE_JOURNAL_ID,
  PROBE_TARGET_COUNT,
  RECOVERY_PROJECT_ID,
  FirestoreProbeRecoveryController,
  assertProbeConfig,
  assertProbeDeleteTarget,
  assertRecoveryControllerSurface,
  buildProbeRecoveryPlan,
  buildProbeRollbackPlan,
  buildProbeWriteSet,
  executeProbeRecovery,
  executeProbeRollback,
} from '../tools/migration/mig001e5_recovery.mjs';

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

function firestoreStringDocument(contentHash) {
  return {
    fields: {
      contentHash: {
        stringValue: contentHash,
      },
    },
  };
}

test('config E5 aceita apenas projeto/batch/doc reservados', () => {
  assert.equal(assertProbeConfig(), true);

  assert.throws(
    () =>
      assertProbeConfig({
        projectId: 'outro-projeto',
        batchId: PROBE_BATCH_ID,
        documentId: PROBE_DOCUMENT_ID,
      }),
    /MIG001E5_PROJECT_MISMATCH/u,
  );

  assert.throws(
    () =>
      assertProbeConfig({
        projectId: RECOVERY_PROJECT_ID,
        batchId: 'mig001e4_pilot_v1',
        documentId: PROBE_DOCUMENT_ID,
      }),
    /MIG001E5_BATCH_MISMATCH/u,
  );
});

test('probe write set possui exatamente 4 targets e batch por ultimo', () => {
  const writes = buildProbeWriteSet();

  assert.equal(writes.length, PROBE_TARGET_COUNT);
  assert.deepEqual(
    writes.map((row) => row.probeRole),
    ['staging', 'history', 'journal', 'batch'],
  );

  assert.equal(
    writes.at(-1).collectionPath,
    'migration_batches',
  );
  assert.equal(
    writes.at(-1).documentId,
    PROBE_BATCH_ID,
  );

  for (const write of writes) {
    assert.equal(write.operation, 'CREATE_ONLY');
    assert.equal(typeof write.payload.contentHash, 'string');
    assert.equal(write.payload.containsPersonalData, false);
  }
});

test('IDs e paths do probe sao fechados e deterministas', () => {
  const writes = buildProbeWriteSet();

  assert.deepEqual(
    writes.map((row) => [
      row.collectionPath,
      row.documentId,
    ]),
    [
      [
        'migration_google_forms_staging',
        PROBE_DOCUMENT_ID,
      ],
      [
        'acoes_historicas',
        PROBE_DOCUMENT_ID,
      ],
      [
        `migration_batches/${PROBE_BATCH_ID}/changes`,
        PROBE_JOURNAL_ID,
      ],
      [
        'migration_batches',
        PROBE_BATCH_ID,
      ],
    ],
  );
});

test('rollback order: batch primeiro, journal ultimo', () => {
  const rollback = buildProbeRollbackPlan();

  assert.deepEqual(
    rollback.map((row) => row.probeRole),
    ['batch', 'history', 'staging', 'journal'],
  );
});

test('recovery order: staging, history, journal, batch', () => {
  const recovery = buildProbeRecoveryPlan();

  assert.deepEqual(
    recovery.map((row) => row.probeRole),
    ['staging', 'history', 'journal', 'batch'],
  );
});

test('delete target exige target exato e hash esperado exato', () => {
  const target = buildProbeRollbackPlan()[0];

  assert.deepEqual(
    assertProbeDeleteTarget(target),
    target,
  );

  assert.throws(
    () =>
      assertProbeDeleteTarget({
        ...target,
        expectedContentHash: 'different',
      }),
    /MIG001E5_DELETE_EXPECTED_HASH_MISMATCH/u,
  );
});

test('target do piloto E4 e bloqueado antes de rede', () => {
  assert.throws(
    () =>
      assertProbeDeleteTarget({
        collectionPath: 'migration_batches',
        documentId: 'mig001e4_pilot_v1',
        expectedContentHash: 'x',
      }),
    /MIG001E5_DELETE_TARGET_NOT_PROBE/u,
  );

  assert.throws(
    () =>
      assertProbeDeleteTarget({
        collectionPath: 'acoes_historicas',
        documentId: `gf_${'a'.repeat(64)}`,
        expectedContentHash: 'x',
      }),
    /MIG001E5_DELETE_TARGET_NOT_PROBE/u,
  );
});

test('acoes e contadores nunca sao targets de delete E5', () => {
  for (const collectionPath of ['acoes', 'contadores']) {
    assert.throws(
      () =>
        assertProbeDeleteTarget({
          collectionPath,
          documentId: 'probe',
          expectedContentHash: 'x',
        }),
      /MIG001E5_DELETE_TARGET_NOT_PROBE/u,
    );
  }
});

test('controller nao expoe delete generico, patch, update ou recursive delete', () => {
  const controller = new FirestoreProbeRecoveryController({
    projectId: RECOVERY_PROJECT_ID,
    fetchFn: async () => response(404),
    accessTokenProvider: async () => TEST_TOKEN,
  });

  assert.equal(
    typeof controller.deleteProbeIfHashMatches,
    'function',
  );
  assert.equal(typeof controller.delete, 'undefined');
  assert.equal(typeof controller.deleteDocument, 'undefined');
  assert.equal(typeof controller.deleteAll, 'undefined');
  assert.equal(typeof controller.recursiveDelete, 'undefined');
  assert.equal(typeof controller.patch, 'undefined');
  assert.equal(typeof controller.update, 'undefined');
  assert.equal(
    assertRecoveryControllerSurface(controller),
    true,
  );
});

test('hash mismatch bloqueia DELETE e faz somente GET', async () => {
  const calls = [];
  const target = buildProbeRollbackPlan()[0];

  const controller = new FirestoreProbeRecoveryController({
    projectId: RECOVERY_PROJECT_ID,
    accessTokenProvider: async () => TEST_TOKEN,
    fetchFn: async (url, options) => {
      calls.push({
        url,
        method: options?.method,
      });

      return response(
        200,
        firestoreStringDocument('hash-divergente'),
      );
    },
  });

  await assert.rejects(
    controller.deleteProbeIfHashMatches(target),
    /MIG001E5_PROBE_EXISTING_HASH_MISMATCH/u,
  );

  assert.equal(calls.length, 1);
  assert.equal(calls[0].method, 'GET');
});

test('delete hash-guarded executa GET seguido de DELETE no target exato', async () => {
  const calls = [];
  const target = buildProbeRollbackPlan()[1];

  const controller = new FirestoreProbeRecoveryController({
    projectId: RECOVERY_PROJECT_ID,
    accessTokenProvider: async () => TEST_TOKEN,
    fetchFn: async (url, options) => {
      calls.push({
        url,
        method: options?.method,
      });

      if (options?.method === 'GET') {
        return response(
          200,
          firestoreStringDocument(
            target.expectedContentHash,
          ),
        );
      }

      if (options?.method === 'DELETE') {
        return response(200, {});
      }

      return response(500, {});
    },
  });

  const result =
    await controller.deleteProbeIfHashMatches(target);

  assert.deepEqual(result, {
    outcome: 'deleted',
    deleted: true,
  });

  assert.deepEqual(
    calls.map((row) => row.method),
    ['GET', 'DELETE'],
  );

  assert.equal(
    calls[0].url.includes(PROBE_DOCUMENT_ID),
    true,
  );
  assert.equal(
    calls[1].url.includes(PROBE_DOCUMENT_ID),
    true,
  );
});

test('target fora do probe bloqueia antes de fetch', async () => {
  let fetchCalls = 0;

  const controller = new FirestoreProbeRecoveryController({
    projectId: RECOVERY_PROJECT_ID,
    accessTokenProvider: async () => TEST_TOKEN,
    fetchFn: async () => {
      fetchCalls += 1;
      return response(200, {});
    },
  });

  await assert.rejects(
    controller.deleteProbeIfHashMatches({
      collectionPath: 'migration_batches',
      documentId: 'mig001e4_pilot_v1',
      expectedContentHash: 'x',
    }),
    /MIG001E5_DELETE_TARGET_NOT_PROBE/u,
  );

  assert.equal(fetchCalls, 0);
});

test('executeProbeRollback respeita ordem batch-history-staging-journal', async () => {
  const calls = [];

  const controller = {
    async deleteProbeIfHashMatches(target) {
      calls.push(target.probeRole);
      return {
        outcome: 'deleted',
        deleted: true,
      };
    },
  };

  const result = await executeProbeRollback({
    controller,
  });

  assert.deepEqual(
    calls,
    ['batch', 'history', 'staging', 'journal'],
  );
  assert.equal(result.completed, 4);
  assert.equal(result.deleted, 4);
  assert.equal(result.batchDeletedFirst, true);
  assert.equal(result.journalDeletedLast, true);
});

test('rollback para na primeira falha sem cleanup generico', async () => {
  const calls = [];

  const controller = {
    async deleteProbeIfHashMatches(target) {
      calls.push(target.probeRole);

      if (target.probeRole === 'history') {
        throw new Error('simulated');
      }

      return {
        outcome: 'deleted',
        deleted: true,
      };
    },
  };

  await assert.rejects(
    executeProbeRollback({ controller }),
    (error) => {
      assert.equal(
        error.message,
        'MIG001E5_ROLLBACK_STOPPED',
      );
      assert.equal(error.details.completed, 1);
      assert.equal(error.details.probeRole, 'history');
      return true;
    },
  );

  assert.deepEqual(calls, ['batch', 'history']);
});

test('executeProbeRecovery usa createOnly e batch fica por ultimo', async () => {
  const calls = [];

  const writer = {
    async createOnly(write) {
      calls.push([
        write.collectionPath,
        write.documentId,
      ]);

      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  const result = await executeProbeRecovery({ writer });

  assert.equal(result.completed, 4);
  assert.equal(result.created, 4);
  assert.equal(result.unchanged, 0);
  assert.equal(result.batchCreatedLast, true);

  assert.deepEqual(
    calls.at(-1),
    ['migration_batches', PROBE_BATCH_ID],
  );
});

test('recovery para na falha e nao tenta writes posteriores', async () => {
  const roles = [];
  const plan = buildProbeRecoveryPlan();
  const roleByKey = new Map(
    plan.map((row) => [
      `${row.collectionPath}/${row.documentId}`,
      row.probeRole,
    ]),
  );

  const writer = {
    async createOnly(write) {
      const role = roleByKey.get(
        `${write.collectionPath}/${write.documentId}`,
      );
      roles.push(role);

      if (role === 'history') {
        throw new Error('simulated');
      }

      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  await assert.rejects(
    executeProbeRecovery({ writer }),
    (error) => {
      assert.equal(
        error.message,
        'MIG001E5_RECOVERY_STOPPED',
      );
      assert.equal(error.details.completed, 1);
      assert.equal(error.details.probeRole, 'history');
      return true;
    },
  );

  assert.deepEqual(roles, ['staging', 'history']);
});