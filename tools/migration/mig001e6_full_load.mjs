import {
  OFFICIAL_SOURCE,
  assertAllowedCollectionPath,
  canonicalJson,
  normalizeText,
  sha256Hex,
} from './mig001e3_core.mjs';

export const FULL_LOAD_PROJECT_ID = 'geduc-rae-mobile';
export const FULL_LOAD_BATCH_ID = 'mig001e6_full_1051_v1';
export const FULL_LOAD_EXPECTED_RECORDS = 1051;
export const FULL_LOAD_LOGICAL_TARGETS = 3154;
export const FULL_LOAD_EXPECTED_INITIAL_MISSING = 3134;
export const FULL_LOAD_EXPECTED_INITIAL_UNCHANGED = 20;
export const FULL_LOAD_CHUNK_SIZE = 100;
export const FULL_LOAD_RECOVERY_MODE = 'resume_forward';

const ACCEPTED_CREATE_OUTCOMES = new Set([
  'created',
  'unchanged',
  'unchanged_after_race',
]);

const DENIED_TARGET_ROOTS = new Set([
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

function targetKey(collectionPath, documentId) {
  return `${collectionPath}\u001f${documentId}`;
}

function rootOf(collectionPath) {
  return collectionPath.split('/')[0];
}

function assertHash(value, code) {
  if (
    typeof value !== 'string' ||
    !/^[0-9a-f]{64}$/u.test(value)
  ) {
    throw new Error(code);
  }

  return value;
}

export function assertFullLoadConfig({
  projectId = FULL_LOAD_PROJECT_ID,
  batchId = FULL_LOAD_BATCH_ID,
  expectedRecords = FULL_LOAD_EXPECTED_RECORDS,
  chunkSize = FULL_LOAD_CHUNK_SIZE,
} = {}) {
  if (normalizeText(projectId) !== FULL_LOAD_PROJECT_ID) {
    throw new Error('MIG001E6_PROJECT_MISMATCH');
  }

  if (normalizeText(batchId) !== FULL_LOAD_BATCH_ID) {
    throw new Error('MIG001E6_BATCH_MISMATCH');
  }

  if (expectedRecords !== FULL_LOAD_EXPECTED_RECORDS) {
    throw new Error('MIG001E6_RECORD_COUNT_MUST_BE_1051');
  }

  if (
    !Number.isSafeInteger(chunkSize) ||
    chunkSize < 1 ||
    chunkSize > FULL_LOAD_CHUNK_SIZE
  ) {
    throw new Error('MIG001E6_INVALID_CHUNK_SIZE');
  }

  return true;
}

function buildJournalPayload(item) {
  const base = {
    schemaVersion: 1,
    recordType: 'migration_change_journal_e6',
    operation: 'ENSURE_CREATE_ONLY',
    batchId: FULL_LOAD_BATCH_ID,
    targetCollection: 'acoes_historicas',
    targetDocumentId: item.id,
    sourceIdentityHash: item.sourceIdentityHash,
    targetContentHash: item.contentHash,
    stagingContentHash: item.stagingContentHash,
    writePolicy: 'CREATE_ONLY',
    rollbackEligible: false,
    recoveryMode: FULL_LOAD_RECOVERY_MODE,
    transientAttemptOutcomePersisted: false,
  };

  return {
    ...base,
    contentHash: sha256Hex(canonicalJson(base)),
  };
}

function buildBatchPayload(transformedRecords, journalPayloads) {
  const ids = transformedRecords
    .map((item) => item.id)
    .sort();

  const historyHashes = transformedRecords
    .map((item) => item.contentHash)
    .sort();

  const stagingHashes = transformedRecords
    .map((item) => item.stagingContentHash)
    .sort();

  const journalHashes = journalPayloads
    .map((payload) => payload.contentHash)
    .sort();

  const base = {
    schemaVersion: 1,
    recordType: 'migration_batch_google_forms_e6',
    batchId: FULL_LOAD_BATCH_ID,
    policyVersion: OFFICIAL_SOURCE.policyVersion,
    sourceSha256: OFFICIAL_SOURCE.expectedSha256,
    expectedRecords: FULL_LOAD_EXPECTED_RECORDS,
    expectedLogicalTargets: FULL_LOAD_LOGICAL_TARGETS,
    mode: 'historical_full_load',
    createOnly: true,
    batchMarkerLast: true,
    rollbackEnabled: false,
    recoveryMode: FULL_LOAD_RECOVERY_MODE,
    idSetHash: sha256Hex(ids.join('\n')),
    historyContentSetHash: sha256Hex(
      historyHashes.join('\n'),
    ),
    stagingContentSetHash: sha256Hex(
      stagingHashes.join('\n'),
    ),
    journalContentSetHash: sha256Hex(
      journalHashes.join('\n'),
    ),
  };

  return {
    ...base,
    contentHash: sha256Hex(canonicalJson(base)),
  };
}

function validateTransformedRecord(item) {
  if (!item || typeof item !== 'object' || Array.isArray(item)) {
    throw new Error('MIG001E6_TRANSFORMED_RECORD_INVALID');
  }

  if (!/^gf_[0-9a-f]{64}$/u.test(normalizeText(item.id))) {
    throw new Error('MIG001E6_HISTORICAL_ID_INVALID');
  }

  assertHash(
    item.sourceIdentityHash,
    'MIG001E6_SOURCE_IDENTITY_HASH_INVALID',
  );
  assertHash(
    item.contentHash,
    'MIG001E6_HISTORY_CONTENT_HASH_INVALID',
  );
  assertHash(
    item.stagingContentHash,
    'MIG001E6_STAGING_CONTENT_HASH_INVALID',
  );

  if (
    item.document?.contentHash !== item.contentHash ||
    item.stagingDocument?.contentHash !== item.stagingContentHash
  ) {
    throw new Error('MIG001E6_PAYLOAD_HASH_REFERENCE_INVALID');
  }

  return true;
}

function assertWrite(write) {
  if (
    !write ||
    write.operation !== 'CREATE_ONLY' ||
    typeof write.collectionPath !== 'string' ||
    typeof write.documentId !== 'string'
  ) {
    throw new Error('MIG001E6_WRITE_INVALID');
  }

  assertAllowedCollectionPath(write.collectionPath);

  if (DENIED_TARGET_ROOTS.has(rootOf(write.collectionPath))) {
    throw new Error(
      `MIG001E6_DENIED_TARGET_ROOT:${rootOf(write.collectionPath)}`,
    );
  }

  assertHash(
    write.payload?.contentHash,
    'MIG001E6_WRITE_CONTENT_HASH_INVALID',
  );

  return true;
}

export function buildFullLoadPlan(
  transformedRecords,
  options = {},
) {
  assertFullLoadConfig(options);

  if (
    !Array.isArray(transformedRecords) ||
    transformedRecords.length !== FULL_LOAD_EXPECTED_RECORDS
  ) {
    throw new Error('MIG001E6_TRANSFORMED_RECORDS_MUST_BE_1051');
  }

  transformedRecords.forEach(validateTransformedRecord);

  const uniqueIds = new Set(
    transformedRecords.map((item) => item.id),
  );

  if (uniqueIds.size !== FULL_LOAD_EXPECTED_RECORDS) {
    throw new Error('MIG001E6_DUPLICATE_HISTORICAL_ID');
  }

  const journalPayloads = transformedRecords.map(
    buildJournalPayload,
  );

  const records = transformedRecords.map((item, index) => {
    const journalPayload = journalPayloads[index];

    const staging = {
      role: 'staging',
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath(
        'migration_google_forms_staging',
      ),
      documentId: item.id,
      payload: item.stagingDocument,
    };

    const history = {
      role: 'history',
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath(
        'acoes_historicas',
      ),
      documentId: item.id,
      payload: item.document,
    };

    const journal = {
      role: 'journal',
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath(
        `migration_batches/${FULL_LOAD_BATCH_ID}/changes`,
      ),
      documentId: `${item.id}_history`,
      payload: journalPayload,
    };

    [staging, history, journal].forEach(assertWrite);

    return {
      historicalId: item.id,
      writes: [staging, history, journal],
    };
  });

  const batch = {
    role: 'batch',
    operation: 'CREATE_ONLY',
    collectionPath: assertAllowedCollectionPath(
      'migration_batches',
    ),
    documentId: FULL_LOAD_BATCH_ID,
    payload: buildBatchPayload(
      transformedRecords,
      journalPayloads,
    ),
  };

  assertWrite(batch);

  const flatWrites = [
    ...records.flatMap((record) => record.writes),
    batch,
  ];

  if (flatWrites.length !== FULL_LOAD_LOGICAL_TARGETS) {
    throw new Error('MIG001E6_LOGICAL_TARGET_COUNT_INVALID');
  }

  if (
    flatWrites.at(-1).role !== 'batch' ||
    flatWrites.at(-1).documentId !== FULL_LOAD_BATCH_ID
  ) {
    throw new Error('MIG001E6_BATCH_MARKER_NOT_LAST');
  }

  const keys = flatWrites.map((write) =>
    targetKey(write.collectionPath, write.documentId));

  if (new Set(keys).size !== keys.length) {
    throw new Error('MIG001E6_DUPLICATE_TARGET');
  }

  return {
    projectId: FULL_LOAD_PROJECT_ID,
    batchId: FULL_LOAD_BATCH_ID,
    expectedRecords: FULL_LOAD_EXPECTED_RECORDS,
    chunkSize: options.chunkSize ?? FULL_LOAD_CHUNK_SIZE,
    records,
    batch,
    writes: flatWrites,
  };
}

export function summarizeFullLoadPlan(plan) {
  if (!plan || !Array.isArray(plan.writes)) {
    throw new Error('MIG001E6_PLAN_REQUIRED');
  }

  const summary = {
    staging: 0,
    history: 0,
    journal: 0,
    batch: 0,
    total: plan.writes.length,
  };

  for (const write of plan.writes) {
    if (write.role === 'staging') summary.staging += 1;
    else if (write.role === 'history') summary.history += 1;
    else if (write.role === 'journal') summary.journal += 1;
    else if (write.role === 'batch') summary.batch += 1;
    else throw new Error('MIG001E6_UNKNOWN_ROLE');
  }

  return summary;
}

function classifyExisting(existing, expectedHash) {
  if (!existing?.exists) {
    return 'missing';
  }

  if (existing.contentHash === expectedHash) {
    return 'unchanged';
  }

  if (
    existing.contentHash === null ||
    existing.contentHash === undefined ||
    existing.contentHash === ''
  ) {
    return 'exists_without_comparable_hash';
  }

  return 'changed_pending_review';
}

export async function preflightFullLoadTargets({
  reader,
  plan,
}) {
  if (
    typeof reader?.getExistingContentHash !== 'function'
  ) {
    throw new Error('MIG001E6_PREFLIGHT_READER_REQUIRED');
  }

  if (
    !plan ||
    !Array.isArray(plan.writes) ||
    plan.writes.length !== FULL_LOAD_LOGICAL_TARGETS
  ) {
    throw new Error('MIG001E6_PREFLIGHT_PLAN_INVALID');
  }

  const results = [];
  const byKey = new Map();

  for (const write of plan.writes) {
    const existing = await reader.getExistingContentHash(
      write.collectionPath,
      write.documentId,
    );

    const classification = classifyExisting(
      existing,
      write.payload.contentHash,
    );

    const row = {
      key: targetKey(
        write.collectionPath,
        write.documentId,
      ),
      role: write.role,
      collectionPath: write.collectionPath,
      documentId: write.documentId,
      classification,
    };

    results.push(row);
    byKey.set(row.key, row);
  }

  const summary = {
    checked: results.length,
    missing: results.filter(
      (row) => row.classification === 'missing',
    ).length,
    unchanged: results.filter(
      (row) => row.classification === 'unchanged',
    ).length,
    changedPendingReview: results.filter(
      (row) =>
        row.classification === 'changed_pending_review',
    ).length,
    existsWithoutComparableHash: results.filter(
      (row) =>
        row.classification ===
        'exists_without_comparable_hash',
    ).length,
  };

  return {
    ready:
      summary.changedPendingReview === 0 &&
      summary.existsWithoutComparableHash === 0,
    summary,
    results,
    byKey,
  };
}

export function assertExpectedInitialPreflight(preflight) {
  const summary = preflight?.summary;

  if (
    !summary ||
    summary.checked !== FULL_LOAD_LOGICAL_TARGETS ||
    summary.missing !== FULL_LOAD_EXPECTED_INITIAL_MISSING ||
    summary.unchanged !== FULL_LOAD_EXPECTED_INITIAL_UNCHANGED ||
    summary.changedPendingReview !== 0 ||
    summary.existsWithoutComparableHash !== 0
  ) {
    throw new Error('MIG001E6_INITIAL_PREFLIGHT_COUNTS_MISMATCH');
  }

  return true;
}

async function verifyExactWrites({
  reader,
  writes,
}) {
  let checked = 0;

  for (const write of writes) {
    const existing = await reader.getExistingContentHash(
      write.collectionPath,
      write.documentId,
    );

    if (
      !existing?.exists ||
      existing.contentHash !== write.payload.contentHash
    ) {
      throw new Error(
        `MIG001E6_RECONCILIATION_FAILED:${write.role}:${write.documentId}`,
      );
    }

    checked += 1;
  }

  return checked;
}

function preflightRowFor(preflight, write) {
  const row = preflight.byKey.get(
    targetKey(write.collectionPath, write.documentId),
  );

  if (!row) {
    throw new Error('MIG001E6_PREFLIGHT_ROW_MISSING');
  }

  return row;
}

async function ensureWrite({
  writer,
  write,
  preflightRow,
}) {
  if (preflightRow.classification === 'unchanged') {
    return {
      outcome: 'unchanged_preflight',
      wrote: false,
    };
  }

  if (preflightRow.classification !== 'missing') {
    throw new Error(
      `MIG001E6_WRITE_CLASSIFICATION_BLOCKED:${preflightRow.classification}`,
    );
  }

  const result = await writer.createOnly({
    collectionPath: write.collectionPath,
    documentId: write.documentId,
    payload: write.payload,
  });

  if (!ACCEPTED_CREATE_OUTCOMES.has(result?.outcome)) {
    throw new Error(
      `MIG001E6_CREATE_OUTCOME_BLOCKED:${result?.outcome ?? 'UNKNOWN'}`,
    );
  }

  return {
    outcome: result.outcome,
    wrote: result.wrote === true,
  };
}

export async function executeFullLoadResumeForward({
  writer,
  plan,
  requireExpectedInitialCounts = false,
}) {
  if (
    typeof writer?.getExistingContentHash !== 'function' ||
    typeof writer?.createOnly !== 'function'
  ) {
    throw new Error('MIG001E6_WRITER_REQUIRED');
  }

  const preflight = await preflightFullLoadTargets({
    reader: writer,
    plan,
  });

  if (!preflight.ready) {
    const error = new Error('MIG001E6_PREFLIGHT_BLOCKED');
    error.details = preflight.summary;
    throw error;
  }

  if (requireExpectedInitialCounts) {
    assertExpectedInitialPreflight(preflight);
  }

  const batchPreflight = preflightRowFor(
    preflight,
    plan.batch,
  );

  const nonBatchWrites = plan.writes.slice(0, -1);
  const missingNonBatch = nonBatchWrites.filter(
    (write) =>
      preflightRowFor(preflight, write).classification ===
      'missing',
  );

  if (
    batchPreflight.classification === 'unchanged' &&
    missingNonBatch.length > 0
  ) {
    throw new Error(
      'MIG001E6_BATCH_MARKER_PRESENT_WITH_INCOMPLETE_SET',
    );
  }

  const outcomes = [];
  let chunksCompleted = 0;

  if (batchPreflight.classification !== 'unchanged') {
    for (
      let offset = 0;
      offset < plan.records.length;
      offset += plan.chunkSize
    ) {
      const chunk = plan.records.slice(
        offset,
        offset + plan.chunkSize,
      );

      for (const record of chunk) {
        for (const write of record.writes) {
          const result = await ensureWrite({
            writer,
            write,
            preflightRow: preflightRowFor(
              preflight,
              write,
            ),
          });

          outcomes.push({
            role: write.role,
            documentId: write.documentId,
            outcome: result.outcome,
            wrote: result.wrote,
          });
        }
      }

      chunksCompleted += 1;
    }

    const reconciled = await verifyExactWrites({
      reader: writer,
      writes: nonBatchWrites,
    });

    if (reconciled !== nonBatchWrites.length) {
      throw new Error(
        'MIG001E6_NON_BATCH_RECONCILIATION_COUNT_INVALID',
      );
    }

    const markerResult = await ensureWrite({
      writer,
      write: plan.batch,
      preflightRow: batchPreflight,
    });

    outcomes.push({
      role: 'batch',
      documentId: plan.batch.documentId,
      outcome: markerResult.outcome,
      wrote: markerResult.wrote,
    });

    const markerVerified = await verifyExactWrites({
      reader: writer,
      writes: [plan.batch],
    });

    if (markerVerified !== 1) {
      throw new Error(
        'MIG001E6_BATCH_MARKER_RECONCILIATION_INVALID',
      );
    }
  } else {
    const reconciled = await verifyExactWrites({
      reader: writer,
      writes: nonBatchWrites,
    });

    if (reconciled !== nonBatchWrites.length) {
      throw new Error(
        'MIG001E6_COMPLETED_BATCH_RECONCILIATION_INVALID',
      );
    }
  }

  return {
    preflight: preflight.summary,
    chunksCompleted,
    outcomes,
    createCalls: outcomes.filter(
      (row) =>
        row.outcome !== 'unchanged_preflight',
    ).length,
    writesPerformed: outcomes.filter(
      (row) => row.wrote,
    ).length,
    skippedUnchanged: outcomes.filter(
      (row) => row.outcome === 'unchanged_preflight',
    ).length,
    batchMarkerLast:
      outcomes.length === 0 ||
      outcomes.at(-1)?.role === 'batch',
    completedBeforeRun:
      batchPreflight.classification === 'unchanged',
  };
}