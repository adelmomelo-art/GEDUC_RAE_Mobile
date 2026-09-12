import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  SEED_AUTHORIZATION_PHRASE,
  SEED_READINESS_COLLECTION,
  SEED_READINESS_EXPECTED_BRANCH,
  SEED_READINESS_MANIFEST_SHA256,
  SEED_READINESS_PROJECT_ID,
  SEED_READINESS_RULES_SHA256,
  runProtectedSeedReadiness,
} from '../tools/catalogos/projeto_catalog_seed_readiness_runner.mjs';

const HEAD = '7176602';

function rulesetOk() {
  return {
    projectId: SEED_READINESS_PROJECT_ID,
    rulesetName:
      'projects/geduc-rae-mobile/rulesets/test-readiness',
    normalizedSha256:
      SEED_READINESS_RULES_SHA256,
  };
}

function preflightOk({
  missing = 53,
  unchanged = 0,
} = {}) {
  return {
    mode: 'remote-read-only-composition',
    projectId: SEED_READINESS_PROJECT_ID,
    collection: SEED_READINESS_COLLECTION,
    expected: 53,
    checked: 53,
    ready: true,
    missing,
    unchanged,
    blockers: [],
    remoteWriteEnabled: false,
    firestoreWrites: 0,
  };
}

function baseArgs(overrides = {}) {
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

test('gates validos deixam pronto somente para autorizacao explicita', async () => {
  const result =
    await runProtectedSeedReadiness(
      baseArgs(),
    );

  assert.equal(
    result.readyForExplicitAuthorization,
    true,
  );

  assert.equal(
    result.authorizationProvided,
    false,
  );

  assert.equal(result.remoteWriteEnabled, false);
  assert.equal(result.seedExecutionAvailable, false);
  assert.equal(result.seedExecuted, false);

  assert.equal(
    result.reason,
    'GATES_READY_WRITE_STILL_DISABLED',
  );
});

test('mesmo com frase de autorizacao escrita continua indisponivel', async () => {
  const result =
    await runProtectedSeedReadiness(
      baseArgs({
        explicitAuthorization:
          SEED_AUTHORIZATION_PHRASE,
      }),
    );

  assert.equal(
    result.readyForExplicitAuthorization,
    true,
  );

  assert.equal(
    result.authorizationProvided,
    true,
  );

  assert.equal(result.remoteWriteEnabled, false);
  assert.equal(result.seedExecutionAvailable, false);
  assert.equal(result.seedExecuted, false);
});

test('hash do manifesto divergente bloqueia antes de leituras remotas', async () => {
  let rulesReads = 0;
  let preflightRuns = 0;

  await assert.rejects(
    () =>
      runProtectedSeedReadiness(
        baseArgs({
          manifestSha256: 'HASH-DIVERGENTE',

          readActiveRuleset: async () => {
            rulesReads += 1;
            return rulesetOk();
          },

          readOnlyComposition: {
            remoteWriteEnabled: false,
            async runReadOnlyPreflight() {
              preflightRuns += 1;
              return preflightOk();
            },
          },
        }),
      ),
    /BUGRAE002E_READINESS_MANIFEST_HASH_MISMATCH/u,
  );

  assert.equal(rulesReads, 0);
  assert.equal(preflightRuns, 0);
});

test('branch, HEAD e worktree sao fail-closed', async () => {
  await assert.rejects(
    () =>
      runProtectedSeedReadiness(
        baseArgs({
          branch: 'main',
        }),
      ),
    /BUGRAE002E_READINESS_BRANCH_MISMATCH/u,
  );

  await assert.rejects(
    () =>
      runProtectedSeedReadiness(
        baseArgs({
          head: 'outro-head',
        }),
      ),
    /BUGRAE002E_READINESS_HEAD_MISMATCH/u,
  );

  await assert.rejects(
    () =>
      runProtectedSeedReadiness(
        baseArgs({
          workingTreeClean: false,
        }),
      ),
    /BUGRAE002E_READINESS_WORKTREE_DIRTY/u,
  );
});

test('ruleset divergente bloqueia antes do preflight Firestore', async () => {
  let preflightRuns = 0;

  const result =
    await runProtectedSeedReadiness(
      baseArgs({
        readActiveRuleset: async () => ({
          ...rulesetOk(),
          normalizedSha256: 'HASH-DIVERGENTE',
        }),

        readOnlyComposition: {
          remoteWriteEnabled: false,
          async runReadOnlyPreflight() {
            preflightRuns += 1;
            return preflightOk();
          },
        },
      }),
    );

  assert.equal(
    result.readyForExplicitAuthorization,
    false,
  );

  assert.equal(
    result.reason,
    'RULESET_GATE_BLOCKED',
  );

  assert.equal(
    result.ruleset.hashMatches,
    false,
  );

  assert.equal(result.preflight, null);
  assert.equal(preflightRuns, 0);
  assert.equal(result.remoteWriteEnabled, false);
});

test('preflight com blocker nao libera readiness', async () => {
  const result =
    await runProtectedSeedReadiness(
      baseArgs({
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
    );

  assert.equal(
    result.readyForExplicitAuthorization,
    false,
  );

  assert.equal(
    result.reason,
    'PREFLIGHT_GATE_BLOCKED',
  );

  assert.equal(result.remoteWriteEnabled, false);
  assert.equal(result.seedExecutionAvailable, false);
  assert.equal(result.seedExecuted, false);
});

test('composicao que habilita write e rejeitada antes das leituras', async () => {
  let rulesReads = 0;

  await assert.rejects(
    () =>
      runProtectedSeedReadiness(
        baseArgs({
          readActiveRuleset: async () => {
            rulesReads += 1;
            return rulesetOk();
          },

          readOnlyComposition: {
            remoteWriteEnabled: true,
            async runReadOnlyPreflight() {
              return preflightOk();
            },
          },
        }),
      ),
    /BUGRAE002E_READINESS_COMPOSITION_WRITE_NOT_DISABLED/u,
  );

  assert.equal(rulesReads, 0);
});

test('runner nao possui CLI nem verbos HTTP de escrita', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_readiness_runner.mjs',
    'utf8',
  );

  assert.equal(source.includes('process.argv'), false);
  assert.equal(source.includes('pathToFileURL'), false);

  for (const pattern of [
    "method: 'POST'",
    'method: "POST"',
    "method: 'PUT'",
    "method: 'PATCH'",
    "method: 'DELETE'",
  ]) {
    assert.equal(source.includes(pattern), false);
  }
});

test('runner nao importa adaptador CREATE_ONLY', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_readiness_runner.mjs',
    'utf8',
  );

  assert.equal(
    source.includes(
      'projeto_catalog_firestore_create_only',
    ),
    false,
  );

  assert.equal(
    source.includes('executeCatalogCreateOnly'),
    false,
  );
});
