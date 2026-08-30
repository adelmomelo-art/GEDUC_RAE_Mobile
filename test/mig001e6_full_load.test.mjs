import test from 'node:test';
import assert from 'node:assert/strict';

import * as e6 from '../tools/migration/mig001e6_full_load.mjs';

const HASH_A = 'a'.repeat(64);
const HASH_B = 'b'.repeat(64);
const HASH_C = 'c'.repeat(64);

function makeTransformedRecords() {
  return Array.from(
    { length: e6.FULL_LOAD_EXPECTED_RECORDS },
    (_, index) => {
      const hex = index.toString(16).padStart(64, '0');
      const id = `gf_${hex}`;
      const sourceIdentityHash = hex;
      const contentHash = `${index % 10}`.repeat(64);
      const stagingContentHash =
        `${(index + 1) % 10}`.repeat(64);

      return {
        id,
        sourceIdentityHash,
        contentHash,
        stagingContentHash,
        document: {
          schemaVersion: 1,
          recordType: 'historico_google_forms',
          contentHash,
        },
        stagingDocument: {
          schemaVersion: 1,
          recordType: 'migration_staging_google_forms',
          contentHash: stagingContentHash,
        },
      };
    },
  );
}

function key(collectionPath, documentId) {
  return `${collectionPath}\u001f${documentId}`;
}

function makeStateForExpectedInitial(plan) {
  const state = new Map();
  const pilotIds = new Set(
    plan.records.slice(0, 10).map(
      (record) => record.historicalId,
    ),
  );

  for (const write of plan.writes) {
    const k = key(
      write.collectionPath,
      write.documentId,
    );

    if (
      pilotIds.has(write.documentId) &&
      (write.role === 'staging' ||
        write.role === 'history')
    ) {
      state.set(k, write.payload.contentHash);
    }
  }

  return state;
}

function makeMockWriter(initialState = new Map()) {
  const state = new Map(initialState);
  const calls = [];

  return {
    state,
    calls,

    async getExistingContentHash(
      collectionPath,
      documentId,
    ) {
      calls.push({
        method: 'GET',
        collectionPath,
        documentId,
      });

      const k = key(collectionPath, documentId);

      if (!state.has(k)) {
        return {
          exists: false,
          contentHash: null,
        };
      }

      return {
        exists: true,
        contentHash: state.get(k),
      };
    },

    async createOnly({
      collectionPath,
      documentId,
      payload,
    }) {
      calls.push({
        method: 'CREATE_ONLY',
        collectionPath,
        documentId,
      });

      const k = key(collectionPath, documentId);

      if (state.has(k)) {
        return {
          outcome:
            state.get(k) === payload.contentHash
              ? 'unchanged'
              : 'changed_pending_review',
          wrote: false,
        };
      }

      state.set(k, payload.contentHash);

      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };
}

test('config E6 e constantes de carga integral sao fechados', () => {
  assert.equal(e6.assertFullLoadConfig(), true);
  assert.equal(e6.FULL_LOAD_EXPECTED_RECORDS, 1051);
  assert.equal(e6.FULL_LOAD_LOGICAL_TARGETS, 3154);
  assert.equal(
    e6.FULL_LOAD_EXPECTED_INITIAL_MISSING,
    3134,
  );
  assert.equal(
    e6.FULL_LOAD_EXPECTED_INITIAL_UNCHANGED,
    20,
  );
  assert.equal(e6.FULL_LOAD_CHUNK_SIZE, 100);
  assert.equal(
    e6.FULL_LOAD_RECOVERY_MODE,
    'resume_forward',
  );

  assert.throws(
    () =>
      e6.assertFullLoadConfig({
        projectId: 'outro-projeto',
      }),
    /MIG001E6_PROJECT_MISMATCH/u,
  );

  assert.throws(
    () =>
      e6.assertFullLoadConfig({
        batchId: 'outro-batch',
      }),
    /MIG001E6_BATCH_MISMATCH/u,
  );
});

test('plano E6 possui 3154 targets e batch marker por ultimo', () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );
  const summary = e6.summarizeFullLoadPlan(plan);

  assert.deepEqual(summary, {
    staging: 1051,
    history: 1051,
    journal: 1051,
    batch: 1,
    total: 3154,
  });

  assert.equal(plan.writes.at(-1).role, 'batch');
  assert.equal(
    plan.writes.at(-1).documentId,
    e6.FULL_LOAD_BATCH_ID,
  );

  for (const write of plan.writes) {
    assert.equal(write.operation, 'CREATE_ONLY');
    assert.equal(
      typeof write.payload.contentHash,
      'string',
    );
    assert.equal(write.payload.contentHash.length, 64);
  }
});

test('journal E6 e deterministico, resume-forward e nao rollback', () => {
  const records = makeTransformedRecords();
  const planA = e6.buildFullLoadPlan(records);
  const planB = e6.buildFullLoadPlan(records);

  const journalA = planA.records[0].writes[2];
  const journalB = planB.records[0].writes[2];

  assert.equal(journalA.role, 'journal');
  assert.equal(
    journalA.payload.rollbackEligible,
    false,
  );
  assert.equal(
    journalA.payload.recoveryMode,
    'resume_forward',
  );
  assert.equal(
    journalA.payload.writePolicy,
    'CREATE_ONLY',
  );
  assert.equal(
    journalA.payload.transientAttemptOutcomePersisted,
    false,
  );
  assert.equal(
    Object.hasOwn(journalA.payload, 'outcome'),
    false,
  );
  assert.equal(
    journalA.payload.contentHash,
    journalB.payload.contentHash,
  );
});

test('acoes e contadores nunca aparecem como target E6', () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );

  const roots = new Set(
    plan.writes.map(
      (write) => write.collectionPath.split('/')[0],
    ),
  );

  assert.equal(roots.has('acoes'), false);
  assert.equal(roots.has('contadores'), false);
  assert.deepEqual(
    [...roots].sort(),
    [
      'acoes_historicas',
      'migration_batches',
      'migration_google_forms_staging',
    ],
  );
});

test('preflight inicial esperado classifica 3134 missing e 20 unchanged', async () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );
  const writer = makeMockWriter(
    makeStateForExpectedInitial(plan),
  );

  const preflight =
    await e6.preflightFullLoadTargets({
      reader: writer,
      plan,
    });

  assert.equal(preflight.ready, true);
  assert.deepEqual(preflight.summary, {
    checked: 3154,
    missing: 3134,
    unchanged: 20,
    changedPendingReview: 0,
    existsWithoutComparableHash: 0,
  });

  assert.equal(
    e6.assertExpectedInitialPreflight(preflight),
    true,
  );
});

test('hash divergente bloqueia preflight e nao e promovido', async () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );
  const first = plan.writes[0];
  const state = new Map([
    [
      key(first.collectionPath, first.documentId),
      HASH_A,
    ],
  ]);

  assert.notEqual(
    first.payload.contentHash,
    HASH_A,
  );

  const preflight =
    await e6.preflightFullLoadTargets({
      reader: makeMockWriter(state),
      plan,
    });

  assert.equal(preflight.ready, false);
  assert.equal(
    preflight.summary.changedPendingReview,
    1,
  );
});

test('executor inicial escreve apenas missing, preserva 20 unchanged e cria batch por ultimo', async () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );
  const writer = makeMockWriter(
    makeStateForExpectedInitial(plan),
  );

  const result =
    await e6.executeFullLoadResumeForward({
      writer,
      plan,
      requireExpectedInitialCounts: true,
    });

  assert.equal(result.preflight.missing, 3134);
  assert.equal(result.preflight.unchanged, 20);
  assert.equal(result.createCalls, 3134);
  assert.equal(result.writesPerformed, 3134);
  assert.equal(result.skippedUnchanged, 20);
  assert.equal(result.batchMarkerLast, true);
  assert.equal(result.completedBeforeRun, false);
  assert.equal(result.chunksCompleted, 11);

  const creates = writer.calls.filter(
    (call) => call.method === 'CREATE_ONLY',
  );

  assert.equal(creates.length, 3134);
  assert.deepEqual(
    creates.at(-1),
    {
      method: 'CREATE_ONLY',
      collectionPath: 'migration_batches',
      documentId: e6.FULL_LOAD_BATCH_ID,
    },
  );

  assert.equal(writer.state.size, 3154);
});

test('batch marker existente com conjunto incompleto bloqueia antes de CREATE_ONLY', async () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );
  const state = new Map([
    [
      key(
        plan.batch.collectionPath,
        plan.batch.documentId,
      ),
      plan.batch.payload.contentHash,
    ],
  ]);

  const writer = makeMockWriter(state);

  await assert.rejects(
    e6.executeFullLoadResumeForward({
      writer,
      plan,
    }),
    /MIG001E6_BATCH_MARKER_PRESENT_WITH_INCOMPLETE_SET/u,
  );

  assert.equal(
    writer.calls.filter(
      (call) => call.method === 'CREATE_ONLY',
    ).length,
    0,
  );
});

test('rerun de lote completo e idempotente com zero CREATE_ONLY', async () => {
  const plan = e6.buildFullLoadPlan(
    makeTransformedRecords(),
  );
  const state = new Map(
    plan.writes.map((write) => [
      key(write.collectionPath, write.documentId),
      write.payload.contentHash,
    ]),
  );

  const writer = makeMockWriter(state);

  const result =
    await e6.executeFullLoadResumeForward({
      writer,
      plan,
    });

  assert.equal(result.preflight.missing, 0);
  assert.equal(result.preflight.unchanged, 3154);
  assert.equal(result.createCalls, 0);
  assert.equal(result.writesPerformed, 0);
  assert.equal(result.completedBeforeRun, true);
  assert.equal(result.batchMarkerLast, true);

  assert.equal(
    writer.calls.filter(
      (call) => call.method === 'CREATE_ONLY',
    ).length,
    0,
  );
});

test('modulo E6 nao expoe superficie de delete, patch, put, force ou reset', () => {
  for (const name of Object.keys(e6)) {
    assert.equal(/delete/iu.test(name), false);
    assert.equal(/patch/iu.test(name), false);
    assert.equal(/^put/iu.test(name), false);
    assert.equal(/force/iu.test(name), false);
    assert.equal(/reset/iu.test(name), false);
  }

  assert.equal(typeof e6.executeFullLoadResumeForward, 'function');
  assert.equal(typeof e6.preflightFullLoadTargets, 'function');
});

test('plano rejeita quantidade diferente de 1051 e IDs duplicados', () => {
  assert.throws(
    () =>
      e6.buildFullLoadPlan(
        makeTransformedRecords().slice(0, 10),
      ),
    /MIG001E6_TRANSFORMED_RECORDS_MUST_BE_1051/u,
  );

  const records = makeTransformedRecords();
  records[1] = {
    ...records[1],
    id: records[0].id,
  };

  assert.throws(
    () => e6.buildFullLoadPlan(records),
    /MIG001E6_DUPLICATE_HISTORICAL_ID/u,
  );
});

test('referencias hash do payload sao validadas antes do plano', () => {
  const records = makeTransformedRecords();

  records[0] = {
    ...records[0],
    document: {
      ...records[0].document,
      contentHash: HASH_B,
    },
  };

  assert.throws(
    () => e6.buildFullLoadPlan(records),
    /MIG001E6_PAYLOAD_HASH_REFERENCE_INVALID/u,
  );

  assert.equal(HASH_C.length, 64);
});