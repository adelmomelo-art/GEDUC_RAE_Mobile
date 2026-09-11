import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  SEED_EXECUTION_CONFIRMATION_PHRASE,
  executeDoubleLockedCatalogSeed,
} from '../tools/catalogos/projeto_catalog_seed_execution_guard.mjs';

import {
  SEED_AUTHORIZATION_PHRASE,
  SEED_READINESS_COLLECTION,
  SEED_READINESS_EXPECTED_BRANCH,
  SEED_READINESS_MANIFEST_SHA256,
  SEED_READINESS_PROJECT_ID,
  SEED_READINESS_RULES_SHA256,
} from '../tools/catalogos/projeto_catalog_seed_readiness_runner.mjs';

import {
  createInMemoryCreateOnlyWriter,
} from '../tools/catalogos/projeto_catalog_executor.mjs';

const HEAD = 'c4cda5e';

function rulesetOk() {
  return {
    projectId: SEED_READINESS_PROJECT_ID,
    rulesetName:
      'projects/geduc-rae-mobile/rulesets/test-double-lock',
    normalizedSha256:
      SEED_READINESS_RULES_SHA256,
  };
}

function preflightOk() {
  return {
    mode: 'remote-read-only-composition',
    projectId: SEED_READINESS_PROJECT_ID,
    collection: SEED_READINESS_COLLECTION,
    expected: 53,
    checked: 53,
    ready: true,
    missing: 53,
    unchanged: 0,
    blockers: [],
    remoteWriteEnabled: false,
    firestoreWrites: 0,
  };
}

function readinessArgs(overrides = {}) {
  return {
    projectId: SEED_READINESS_PROJECT_ID,
    collection: SEED_READINESS_COLLECTION,
    branch: SEED_READINESS_EXPECTED_BRANCH,
    head: HEAD,
    expectedHead: HEAD,
    workingTreeClean: true,
    manifestSha256: SEED_READINESS_MANIFEST_SHA256,
    readActiveRuleset: async () => rulesetOk(),
    readOnlyComposition: {
      remoteWriteEnabled: false,
      async runReadOnlyPreflight() {
        return preflightOk();
      },
    },
    ...overrides,
  };
}

test('sem autorizacao primaria falha antes de qualquer gate remoto', async () => {
  let rulesReads = 0;

  await assert.rejects(
    () =>
      executeDoubleLockedCatalogSeed({
        readinessArgs: readinessArgs({
          readActiveRuleset: async () => {
            rulesReads += 1;
            return rulesetOk();
          },
        }),
        writeWriter: createInMemoryCreateOnlyWriter(),
        explicitAuthorization: null,
        executionConfirmation:
          SEED_EXECUTION_CONFIRMATION_PHRASE,
      }),
    /BUGRAE002E_EXECUTION_PRIMARY_AUTHORIZATION_REQUIRED/u,
  );

  assert.equal(rulesReads, 0);
});

test('sem segunda confirmacao falha antes de qualquer gate remoto', async () => {
  let rulesReads = 0;

  await assert.rejects(
    () =>
      executeDoubleLockedCatalogSeed({
        readinessArgs: readinessArgs({
          readActiveRuleset: async () => {
            rulesReads += 1;
            return rulesetOk();
          },
        }),
        writeWriter: createInMemoryCreateOnlyWriter(),
        explicitAuthorization:
          SEED_AUTHORIZATION_PHRASE,
        executionConfirmation: null,
      }),
    /BUGRAE002E_EXECUTION_SECOND_CONFIRMATION_REQUIRED/u,
  );

  assert.equal(rulesReads, 0);
});

test('ruleset divergente bloqueia antes do writer de execucao', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  await assert.rejects(
    () =>
      executeDoubleLockedCatalogSeed({
        readinessArgs: readinessArgs({
          readActiveRuleset: async () => ({
            ...rulesetOk(),
            normalizedSha256: 'HASH-DIVERGENTE',
          }),
        }),
        writeWriter: writer,
        explicitAuthorization:
          SEED_AUTHORIZATION_PHRASE,
        executionConfirmation:
          SEED_EXECUTION_CONFIRMATION_PHRASE,
      }),
    /BUGRAE002E_EXECUTION_READINESS_BLOCKED/u,
  );

  assert.equal(writer.createOnlyCalls, 0);
  assert.equal(writer.simulatedCreates, 0);
});

test('preflight com blocker impede qualquer createOnly', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  await assert.rejects(
    () =>
      executeDoubleLockedCatalogSeed({
        readinessArgs: readinessArgs({
          readOnlyComposition: {
            remoteWriteEnabled: false,
            async runReadOnlyPreflight() {
              return {
                ...preflightOk(),
                ready: false,
                missing: 52,
                blockers: [
                  {
                    documentId: 'ae_001',
                    classification:
                      'changed_pending_review',
                  },
                ],
              };
            },
          },
        }),
        writeWriter: writer,
        explicitAuthorization:
          SEED_AUTHORIZATION_PHRASE,
        executionConfirmation:
          SEED_EXECUTION_CONFIRMATION_PHRASE,
      }),
    /BUGRAE002E_EXECUTION_READINESS_BLOCKED/u,
  );

  assert.equal(writer.createOnlyCalls, 0);
  assert.equal(writer.simulatedCreates, 0);
});

test('dupla trava + readiness valido executa 53 creates simulados', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  const result =
    await executeDoubleLockedCatalogSeed({
      readinessArgs: readinessArgs(),
      writeWriter: writer,
      explicitAuthorization:
        SEED_AUTHORIZATION_PHRASE,
      executionConfirmation:
        SEED_EXECUTION_CONFIRMATION_PHRASE,
    });

  assert.equal(
    result.mode,
    'double-locked-create-only-seed',
  );
  assert.equal(result.primaryAuthorization, true);
  assert.equal(result.secondConfirmation, true);
  assert.equal(result.execution.expected, 53);
  assert.equal(result.execution.completed, 53);
  assert.equal(result.execution.created, 53);
  assert.equal(result.execution.unchanged, 0);
  assert.equal(result.execution.writerWrites, 53);
  assert.equal(result.seedExecuted, true);
  assert.equal(writer.simulatedCreates, 53);
});

test('executor faz novo preflight completo antes da primeira escrita', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  let firstWriteReadCount = null;

  const guardedWriter = {
    get reads() {
      return writer.reads;
    },

    async getExistingContentHash(...args) {
      return writer.getExistingContentHash(...args);
    },

    async createOnly(...args) {
      if (firstWriteReadCount === null) {
        firstWriteReadCount = writer.reads;
      }

      return writer.createOnly(...args);
    },
  };

  await executeDoubleLockedCatalogSeed({
    readinessArgs: readinessArgs(),
    writeWriter: guardedWriter,
    explicitAuthorization:
      SEED_AUTHORIZATION_PHRASE,
    executionConfirmation:
      SEED_EXECUTION_CONFIRMATION_PHRASE,
  });

  assert.equal(firstWriteReadCount, 53);
});

test('rerun simulado converge para 53 unchanged sem novas escritas', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  const first =
    await executeDoubleLockedCatalogSeed({
      readinessArgs: readinessArgs(),
      writeWriter: writer,
      explicitAuthorization:
        SEED_AUTHORIZATION_PHRASE,
      executionConfirmation:
        SEED_EXECUTION_CONFIRMATION_PHRASE,
    });

  const second =
    await executeDoubleLockedCatalogSeed({
      readinessArgs: readinessArgs(),
      writeWriter: writer,
      explicitAuthorization:
        SEED_AUTHORIZATION_PHRASE,
      executionConfirmation:
        SEED_EXECUTION_CONFIRMATION_PHRASE,
    });

  assert.equal(first.execution.created, 53);
  assert.equal(second.execution.created, 0);
  assert.equal(second.execution.unchanged, 53);
  assert.equal(second.execution.writerWrites, 0);
  assert.equal(writer.simulatedCreates, 53);
});

test('writer com superficie proibida e rejeitado', async () => {
  const writer = {
    async getExistingContentHash() {
      return {
        exists: false,
        contentHash: null,
      };
    },

    async createOnly() {
      return {
        outcome: 'created',
        wrote: true,
      };
    },

    async update() {},
  };

  await assert.rejects(
    () =>
      executeDoubleLockedCatalogSeed({
        readinessArgs: readinessArgs(),
        writeWriter: writer,
        explicitAuthorization:
          SEED_AUTHORIZATION_PHRASE,
        executionConfirmation:
          SEED_EXECUTION_CONFIRMATION_PHRASE,
      }),
    /BUGRAE002E_EXECUTOR_FORBIDDEN_WRITER_METHOD/u,
  );
});

test('guard nao possui CLI, ADC, fetch ou adaptador remoto', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_execution_guard.mjs',
    'utf8',
  );

  for (const pattern of [
    'process.argv',
    'pathToFileURL',
    'mig001e4_adc',
    'fetch(',
    'projeto_catalog_firestore_create_only',
    "method: 'POST'",
    'method: "POST"',
    "method: 'PUT'",
    "method: 'PATCH'",
    "method: 'DELETE'",
  ]) {
    assert.equal(
      source.includes(pattern),
      false,
      pattern,
    );
  }
});
