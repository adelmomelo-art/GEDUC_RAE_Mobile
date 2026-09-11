import { pathToFileURL } from 'node:url';

import {
  EXPECTED_RECORDS,
  SEED_COLLECTION,
  SEED_PROJECT_ID,
  executeDryRun,
} from './projeto_catalog_seed.mjs';

export const EXECUTOR_MODE = 'local-simulation';
export const EXECUTOR_EXPECTED_RECORDS = EXPECTED_RECORDS;

const ACCEPTED_OUTCOMES = new Set([
  'created',
  'unchanged',
  'unchanged_after_race',
]);

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

export function assertExecutorProjectId(projectId) {
  if (normalize(projectId) !== SEED_PROJECT_ID) {
    fail('BUGRAE002E_EXECUTOR_PROJECT_CONFIRMATION_MISMATCH');
  }

  return SEED_PROJECT_ID;
}

export function assertCreateOnlyWriterSurface(writer) {
  if (typeof writer?.getExistingContentHash !== 'function') {
    fail('BUGRAE002E_EXECUTOR_PREFLIGHT_READER_REQUIRED');
  }

  if (typeof writer?.createOnly !== 'function') {
    fail('BUGRAE002E_EXECUTOR_CREATE_ONLY_REQUIRED');
  }

  const forbidden = [
    'create',
    'createDocument',
    'write',
    'set',
    'update',
    'patch',
    'put',
    'delete',
    'deleteDocument',
  ];

  for (const name of forbidden) {
    if (typeof writer?.[name] === 'function') {
      fail('BUGRAE002E_EXECUTOR_FORBIDDEN_WRITER_METHOD', { name });
    }
  }

  return true;
}

function assertPlan(plan) {
  if (!Array.isArray(plan) || plan.length !== EXECUTOR_EXPECTED_RECORDS) {
    fail('BUGRAE002E_EXECUTOR_PLAN_SIZE_INVALID');
  }

  const ids = new Set();

  for (const item of plan) {
    if (
      !item ||
      item.operation !== 'CREATE_ONLY' ||
      item.collectionPath !== SEED_COLLECTION ||
      typeof item.documentId !== 'string' ||
      item.documentId.trim() === '' ||
      typeof item.intendedContentHash !== 'string' ||
      item.intendedContentHash.trim() === '' ||
      item.payload?.contentHash !== item.intendedContentHash
    ) {
      fail('BUGRAE002E_EXECUTOR_PLAN_ITEM_INVALID');
    }

    if (ids.has(item.documentId)) {
      fail('BUGRAE002E_EXECUTOR_DUPLICATE_DOCUMENT_ID', {
        documentId: item.documentId,
      });
    }

    ids.add(item.documentId);
  }

  return true;
}

export async function preflightCreateOnlyTargets({
  writer,
  plan,
}) {
  assertCreateOnlyWriterSurface(writer);
  assertPlan(plan);

  const results = [];
  const blockers = [];

  for (const item of plan) {
    const existing = await writer.getExistingContentHash(
      item.collectionPath,
      item.documentId,
    );

    let classification;

    if (!existing?.exists) {
      classification = 'missing';
    } else if (
      existing.contentHash === item.intendedContentHash
    ) {
      classification = 'unchanged';
    } else if (
      existing.contentHash === null ||
      existing.contentHash === undefined
    ) {
      classification = 'exists_without_comparable_hash';
    } else {
      classification = 'changed_pending_review';
    }

    const row = {
      documentId: item.documentId,
      classification,
    };

    results.push(row);

    if (
      classification === 'exists_without_comparable_hash' ||
      classification === 'changed_pending_review'
    ) {
      blockers.push(row);
    }
  }

  return {
    ready: blockers.length === 0,
    checked: results.length,
    missing: results.filter(
      (row) => row.classification === 'missing',
    ).length,
    unchanged: results.filter(
      (row) => row.classification === 'unchanged',
    ).length,
    blockers,
    results,
  };
}

export async function executeCatalogCreateOnly({
  writer,
  projectId,
}) {
  assertExecutorProjectId(projectId);
  assertCreateOnlyWriterSurface(writer);

  const local = await executeDryRun({
    projectId,
  });

  const plan = local.plan;
  assertPlan(plan);

  const preflight = await preflightCreateOnlyTargets({
    writer,
    plan,
  });

  if (!preflight.ready) {
    fail('BUGRAE002E_EXECUTOR_PREFLIGHT_BLOCKED', {
      checked: preflight.checked,
      blockers: preflight.blockers,
    });
  }

  const outcomes = [];

  for (const item of plan) {
    try {
      const result = await writer.createOnly({
        collectionPath: item.collectionPath,
        documentId: item.documentId,
        payload: item.payload,
        intendedContentHash: item.intendedContentHash,
      });

      if (!ACCEPTED_OUTCOMES.has(result?.outcome)) {
        fail('BUGRAE002E_EXECUTOR_OUTCOME_BLOCKED', {
          completed: outcomes.length,
          documentId: item.documentId,
          outcome: result?.outcome ?? null,
        });
      }

      outcomes.push({
        documentId: item.documentId,
        outcome: result.outcome,
        wrote: result.wrote === true,
      });
    } catch (error) {
      if (
        error?.message ===
        'BUGRAE002E_EXECUTOR_OUTCOME_BLOCKED'
      ) {
        throw error;
      }

      fail('BUGRAE002E_EXECUTOR_STOPPED', {
        completed: outcomes.length,
        documentId: item.documentId,
        cause: error?.message ?? 'UNKNOWN',
      });
    }
  }

  return {
    mode: 'create-only-executor',
    projectId,
    collection: SEED_COLLECTION,
    expected: EXECUTOR_EXPECTED_RECORDS,
    completed: outcomes.length,
    created: outcomes.filter(
      (row) => row.outcome === 'created',
    ).length,
    unchanged: outcomes.filter(
      (row) =>
        row.outcome === 'unchanged' ||
        row.outcome === 'unchanged_after_race',
    ).length,
    writerWrites: outcomes.filter(
      (row) => row.wrote,
    ).length,
    preflight,
    outcomes,
  };
}

export function createInMemoryCreateOnlyWriter() {
  const store = new Map();
  let reads = 0;
  let createOnlyCalls = 0;
  let simulatedCreates = 0;

  return {
    get reads() {
      return reads;
    },

    get createOnlyCalls() {
      return createOnlyCalls;
    },

    get simulatedCreates() {
      return simulatedCreates;
    },

    async getExistingContentHash(
      collectionPath,
      documentId,
    ) {
      reads += 1;

      const key = `${collectionPath}/${documentId}`;

      if (!store.has(key)) {
        return {
          exists: false,
          contentHash: null,
        };
      }

      return {
        exists: true,
        contentHash: store.get(key),
      };
    },

    async createOnly({
      collectionPath,
      documentId,
      intendedContentHash,
    }) {
      createOnlyCalls += 1;

      if (collectionPath !== SEED_COLLECTION) {
        fail('BUGRAE002E_SIMULATOR_COLLECTION_DENIED');
      }

      const key = `${collectionPath}/${documentId}`;

      if (!store.has(key)) {
        store.set(key, intendedContentHash);
        simulatedCreates += 1;

        return {
          outcome: 'created',
          wrote: true,
        };
      }

      if (store.get(key) === intendedContentHash) {
        return {
          outcome: 'unchanged',
          wrote: false,
        };
      }

      return {
        outcome: 'changed_pending_review',
        wrote: false,
      };
    },
  };
}

export function parseArgs(argv) {
  const args = {
    mode: null,
    projectId: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];

    if (token === '--simulate-empty') {
      args.mode = EXECUTOR_MODE;
      continue;
    }

    if (
      token === '--apply' ||
      token === '--remote' ||
      token === '--remote-apply'
    ) {
      fail('BUGRAE002E_EXECUTOR_REMOTE_APPLY_FORBIDDEN');
    }

    if (token === '--project-id') {
      const value = argv[index + 1];

      if (!value || value.startsWith('--')) {
        fail('BUGRAE002E_EXECUTOR_PROJECT_ID_ARGUMENT_REQUIRED');
      }

      args.projectId = value;
      index += 1;
      continue;
    }

    fail('BUGRAE002E_EXECUTOR_UNKNOWN_ARGUMENT', {
      token,
    });
  }

  if (args.mode !== EXECUTOR_MODE) {
    fail('BUGRAE002E_EXECUTOR_SIMULATION_MODE_REQUIRED');
  }

  assertExecutorProjectId(args.projectId);

  return Object.freeze(args);
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  const writer = createInMemoryCreateOnlyWriter();

  const first = await executeCatalogCreateOnly({
    writer,
    projectId: args.projectId,
  });

  const second = await executeCatalogCreateOnly({
    writer,
    projectId: args.projectId,
  });

  const summary = {
    mode: EXECUTOR_MODE,
    projectId: args.projectId,
    collection: SEED_COLLECTION,
    expected: EXECUTOR_EXPECTED_RECORDS,
    firstRun: {
      completed: first.completed,
      created: first.created,
      unchanged: first.unchanged,
      simulatedCreates: writer.simulatedCreates,
    },
    secondRun: {
      completed: second.completed,
      created: second.created,
      unchanged: second.unchanged,
    },
    totalPreflightReads: writer.reads,
    totalCreateOnlyCalls: writer.createOnlyCalls,
    remoteFirestoreReads: 0,
    remoteFirestoreWrites: 0,
    adcInvoked: false,
    gcloudInvoked: false,
    remoteApplyAvailable: false,
  };

  process.stdout.write(
    `${JSON.stringify(summary, null, 2)}\n`,
  );

  return summary;
}

const direct =
  process.argv[1] &&
  import.meta.url === pathToFileURL(process.argv[1]).href;

if (direct) {
  main().catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
