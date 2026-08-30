import {
  buildExecutableWriteSet,
  normalizeText,
} from './mig001e3_core.mjs';

export const PILOT_PROJECT_ID = 'geduc-rae-mobile';
export const PILOT_BATCH_ID = 'mig001e4_pilot_v1';
export const PILOT_SIZE = 10;
export const PILOT_MAX_CREATES = 31;

const ACCEPTED_EXECUTION_OUTCOMES = new Set([
  'created',
  'unchanged',
  'unchanged_after_race',
]);

export function assertPilotConfig({
  projectId,
  batchId,
  pilotSize,
  mode,
}) {
  if (normalizeText(projectId) !== PILOT_PROJECT_ID) {
    throw new Error('MIG001E4_PROJECT_CONFIRMATION_MISMATCH');
  }

  if (normalizeText(batchId) !== PILOT_BATCH_ID) {
    throw new Error('MIG001E4_BATCH_ID_MISMATCH');
  }

  if (pilotSize !== PILOT_SIZE) {
    throw new Error('MIG001E4_PILOT_SIZE_MUST_BE_10');
  }

  if (!['pilot-preflight', 'pilot-apply'].includes(mode)) {
    throw new Error('MIG001E4_GENERIC_APPLY_FORBIDDEN');
  }

  return true;
}

function rootOf(collectionPath) {
  return collectionPath.split('/')[0];
}

export function summarizePilotWriteSet(writes) {
  const summary = {
    batch: 0,
    staging: 0,
    history: 0,
    journal: 0,
    total: writes.length,
  };

  for (const write of writes) {
    if (
      write.collectionPath === 'migration_batches' &&
      write.documentId === PILOT_BATCH_ID
    ) {
      summary.batch += 1;
      continue;
    }

    if (write.collectionPath === 'migration_google_forms_staging') {
      summary.staging += 1;
      continue;
    }

    if (write.collectionPath === 'acoes_historicas') {
      summary.history += 1;
      continue;
    }

    if (
      write.collectionPath ===
      `migration_batches/${PILOT_BATCH_ID}/changes`
    ) {
      summary.journal += 1;
      continue;
    }

    throw new Error(
      `MIG001E4_UNEXPECTED_WRITE_TARGET:${write.collectionPath}`,
    );
  }

  return summary;
}

export function buildPilotWriteSet(
  transformedRecords,
  {
    projectId = PILOT_PROJECT_ID,
    batchId = PILOT_BATCH_ID,
    pilotSize = PILOT_SIZE,
    mode = 'pilot-preflight',
  } = {},
) {
  assertPilotConfig({
    projectId,
    batchId,
    pilotSize,
    mode,
  });

  if (
    !Array.isArray(transformedRecords) ||
    transformedRecords.length !== PILOT_SIZE
  ) {
    throw new Error('MIG001E4_TRANSFORMED_RECORDS_MUST_BE_10');
  }

  const baseWrites = buildExecutableWriteSet(
    transformedRecords,
    batchId,
  );

  const batchWrites = baseWrites.filter(
    (write) =>
      write.collectionPath === 'migration_batches' &&
      write.documentId === batchId,
  );

  const nonBatchWrites = baseWrites.filter(
    (write) =>
      !(
        write.collectionPath === 'migration_batches' &&
        write.documentId === batchId
      ),
  );

  if (batchWrites.length !== 1) {
    throw new Error('MIG001E4_EXPECTED_ONE_BATCH_MARKER');
  }

  const writes = [...nonBatchWrites, batchWrites[0]];

  const summary = summarizePilotWriteSet(writes);

  if (
    summary.total !== PILOT_MAX_CREATES ||
    summary.batch !== 1 ||
    summary.staging !== PILOT_SIZE ||
    summary.history !== PILOT_SIZE ||
    summary.journal !== PILOT_SIZE
  ) {
    throw new Error('MIG001E4_WRITE_SET_DISTRIBUTION_INVALID');
  }

  if (
    writes.at(-1).collectionPath !== 'migration_batches' ||
    writes.at(-1).documentId !== batchId
  ) {
    throw new Error('MIG001E4_BATCH_MARKER_NOT_LAST');
  }

  const deniedRoots = new Set([
    'acoes',
    'contadores',
    'usuarios',
    'equipe_operacional',
    'coordenadores',
    'domains',
    'tipos_acoes',
    'regionais',
    'equipes',
    'projetos',
    'materiais',
  ]);

  for (const write of writes) {
    if (deniedRoots.has(rootOf(write.collectionPath))) {
      throw new Error(
        `MIG001E4_DENIED_WRITE_ROOT:${rootOf(write.collectionPath)}`,
      );
    }

    if (
      write.operation !== 'CREATE_ONLY' ||
      typeof write.payload?.contentHash !== 'string'
    ) {
      throw new Error('MIG001E4_WRITE_NOT_CREATE_ONLY_HASHED');
    }
  }

  return writes;
}

export async function preflightPilotTargets({ writer, writes }) {
  if (typeof writer?.getExistingContentHash !== 'function') {
    throw new Error('MIG001E4_PREFLIGHT_READER_REQUIRED');
  }

  if (!Array.isArray(writes) || writes.length !== PILOT_MAX_CREATES) {
    throw new Error('MIG001E4_PREFLIGHT_WRITE_SET_INVALID');
  }

  const results = [];
  const blockers = [];

  for (const write of writes) {
    const intendedHash = write.payload.contentHash;

    const existing = await writer.getExistingContentHash(
      write.collectionPath,
      write.documentId,
    );

    let classification;

    if (!existing.exists) {
      classification = 'missing';
    } else if (existing.contentHash === intendedHash) {
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
      collectionPath: write.collectionPath,
      documentId: write.documentId,
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
    missing: results.filter((row) => row.classification === 'missing').length,
    unchanged: results.filter((row) => row.classification === 'unchanged').length,
    blockers,
    results,
  };
}

export async function executePilotCreateOnly({
  writer,
  transformedRecords,
  projectId = PILOT_PROJECT_ID,
  batchId = PILOT_BATCH_ID,
  pilotSize = PILOT_SIZE,
}) {
  assertPilotConfig({
    projectId,
    batchId,
    pilotSize,
    mode: 'pilot-apply',
  });

  if (typeof writer?.createOnly !== 'function') {
    throw new Error('MIG001E4_CREATE_ONLY_WRITER_REQUIRED');
  }

  const writes = buildPilotWriteSet(transformedRecords, {
    projectId,
    batchId,
    pilotSize,
    mode: 'pilot-apply',
  });

  const preflight = await preflightPilotTargets({
    writer,
    writes,
  });

  if (!preflight.ready) {
    const error = new Error('MIG001E4_PREFLIGHT_BLOCKED');
    error.details = {
      checked: preflight.checked,
      blockers: preflight.blockers,
    };
    throw error;
  }

  const outcomes = [];

  for (const write of writes) {
    try {
      const result = await writer.createOnly({
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        payload: write.payload,
      });

      if (!ACCEPTED_EXECUTION_OUTCOMES.has(result?.outcome)) {
        const error = new Error(
          `MIG001E4_EXECUTION_OUTCOME_BLOCKED:${result?.outcome ?? 'UNKNOWN'}`,
        );
        error.details = {
          completed: outcomes.length,
          collectionPath: write.collectionPath,
          documentId: write.documentId,
        };
        throw error;
      }

      outcomes.push({
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        outcome: result.outcome,
        wrote: result.wrote === true,
      });
    } catch (cause) {
      if (cause?.message?.startsWith('MIG001E4_EXECUTION_OUTCOME_BLOCKED:')) {
        throw cause;
      }

      const error = new Error('MIG001E4_EXECUTION_STOPPED');
      error.cause = cause;
      error.details = {
        completed: outcomes.length,
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        batchMarkerAttempted:
          write.collectionPath === 'migration_batches' &&
          write.documentId === batchId,
      };
      throw error;
    }
  }

  const summary = summarizePilotWriteSet(writes);

  return {
    preflight: {
      checked: preflight.checked,
      missing: preflight.missing,
      unchanged: preflight.unchanged,
    },
    writes: summary,
    outcomes,
    created: outcomes.filter((row) => row.outcome === 'created').length,
    unchanged: outcomes.filter((row) =>
      ['unchanged', 'unchanged_after_race'].includes(row.outcome),
    ).length,
    batchMarkerLast:
      outcomes.at(-1)?.collectionPath === 'migration_batches' &&
      outcomes.at(-1)?.documentId === batchId,
  };
}