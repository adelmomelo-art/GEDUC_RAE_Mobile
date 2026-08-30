import {
  canonicalJson,
  normalizeText,
  sha256Hex,
} from './mig001e3_core.mjs';
import {
  FIRESTORE_API_BASE,
  readStringField,
} from './mig001e3_firestore_rest.mjs';

export const RECOVERY_PROJECT_ID = 'geduc-rae-mobile';
export const PROBE_BATCH_ID = 'mig001e5_rollback_probe_v1';
export const PROBE_DOCUMENT_ID = 'probe_mig001e5_v1';
export const PROBE_JOURNAL_ID = 'probe_mig001e5_v1_history';
export const PROBE_TARGET_COUNT = 4;

function assertExact(value, expected, errorCode) {
  if (normalizeText(value) !== expected) {
    throw new Error(errorCode);
  }
  return expected;
}

function hashPayload(base) {
  return {
    ...base,
    contentHash: sha256Hex(canonicalJson(base)),
  };
}

function buildProbePayloads() {
  const common = {
    schemaVersion: 1,
    probe: true,
    probeVersion: 'MIG-001E5-v1',
    containsPersonalData: false,
    numeroRAE: null,
    projectId: RECOVERY_PROJECT_ID,
    batchId: PROBE_BATCH_ID,
    documentId: PROBE_DOCUMENT_ID,
  };

  const staging = hashPayload({
    ...common,
    recordType: 'migration_rollback_probe',
    probeRole: 'staging',
  });

  const history = hashPayload({
    ...common,
    recordType: 'migration_rollback_probe',
    probeRole: 'history',
    readOnly: true,
  });

  const journal = hashPayload({
    ...common,
    recordType: 'migration_rollback_probe_journal',
    probeRole: 'journal',
    operation: 'CREATE',
    targetCollection: 'acoes_historicas',
    targetDocumentId: PROBE_DOCUMENT_ID,
    rollbackEligible: true,
  });

  const batch = hashPayload({
    schemaVersion: 1,
    probe: true,
    probeVersion: 'MIG-001E5-v1',
    containsPersonalData: false,
    recordType: 'migration_rollback_probe_batch',
    projectId: RECOVERY_PROJECT_ID,
    batchId: PROBE_BATCH_ID,
    expectedProbeTargets: PROBE_TARGET_COUNT,
    createOnly: true,
  });

  return { staging, history, journal, batch };
}

export function assertProbeConfig({
  projectId = RECOVERY_PROJECT_ID,
  batchId = PROBE_BATCH_ID,
  documentId = PROBE_DOCUMENT_ID,
} = {}) {
  assertExact(
    projectId,
    RECOVERY_PROJECT_ID,
    'MIG001E5_PROJECT_MISMATCH',
  );
  assertExact(
    batchId,
    PROBE_BATCH_ID,
    'MIG001E5_BATCH_MISMATCH',
  );
  assertExact(
    documentId,
    PROBE_DOCUMENT_ID,
    'MIG001E5_DOCUMENT_ID_MISMATCH',
  );
  return true;
}

export function buildProbeWriteSet(options = {}) {
  assertProbeConfig(options);
  const payloads = buildProbePayloads();

  const writes = [
    {
      operation: 'CREATE_ONLY',
      probeRole: 'staging',
      collectionPath: 'migration_google_forms_staging',
      documentId: PROBE_DOCUMENT_ID,
      payload: payloads.staging,
    },
    {
      operation: 'CREATE_ONLY',
      probeRole: 'history',
      collectionPath: 'acoes_historicas',
      documentId: PROBE_DOCUMENT_ID,
      payload: payloads.history,
    },
    {
      operation: 'CREATE_ONLY',
      probeRole: 'journal',
      collectionPath:
        `migration_batches/${PROBE_BATCH_ID}/changes`,
      documentId: PROBE_JOURNAL_ID,
      payload: payloads.journal,
    },
    {
      operation: 'CREATE_ONLY',
      probeRole: 'batch',
      collectionPath: 'migration_batches',
      documentId: PROBE_BATCH_ID,
      payload: payloads.batch,
    },
  ];

  if (writes.length !== PROBE_TARGET_COUNT) {
    throw new Error('MIG001E5_PROBE_TARGET_COUNT_INVALID');
  }

  if (
    writes.at(-1).collectionPath !== 'migration_batches' ||
    writes.at(-1).documentId !== PROBE_BATCH_ID
  ) {
    throw new Error('MIG001E5_BATCH_MARKER_NOT_LAST');
  }

  return writes;
}

function targetKey(collectionPath, documentId) {
  return `${collectionPath}\u001f${documentId}`;
}

function canonicalProbeTargets() {
  return new Map(
    buildProbeWriteSet().map((write) => [
      targetKey(write.collectionPath, write.documentId),
      {
        probeRole: write.probeRole,
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        expectedContentHash: write.payload.contentHash,
      },
    ]),
  );
}

export function assertProbeDeleteTarget(target) {
  if (!target || typeof target !== 'object' || Array.isArray(target)) {
    throw new Error('MIG001E5_PROBE_TARGET_REQUIRED');
  }

  const collectionPath = normalizeText(target.collectionPath)
    .replace(/\\/gu, '/');
  const documentId = normalizeText(target.documentId);
  const expectedContentHash = normalizeText(
    target.expectedContentHash,
  );

  const targets = canonicalProbeTargets();
  const expected = targets.get(
    targetKey(collectionPath, documentId),
  );

  if (!expected) {
    throw new Error(
      `MIG001E5_DELETE_TARGET_NOT_PROBE:${collectionPath}/${documentId}`,
    );
  }

  if (expectedContentHash !== expected.expectedContentHash) {
    throw new Error('MIG001E5_DELETE_EXPECTED_HASH_MISMATCH');
  }

  return { ...expected };
}

export function buildProbeRollbackPlan() {
  const byRole = new Map(
    buildProbeWriteSet().map((write) => [
      write.probeRole,
      {
        probeRole: write.probeRole,
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        expectedContentHash: write.payload.contentHash,
      },
    ]),
  );

  // Batch marker first, journal last.
  return [
    byRole.get('batch'),
    byRole.get('history'),
    byRole.get('staging'),
    byRole.get('journal'),
  ];
}

export function buildProbeRecoveryPlan() {
  // Same order as original create: batch marker last.
  return buildProbeWriteSet().map((write) => ({ ...write }));
}

function assertProjectId(projectId) {
  return assertExact(
    projectId,
    RECOVERY_PROJECT_ID,
    'MIG001E5_CONTROLLER_PROJECT_MISMATCH',
  );
}

function encodePathSegments(segments) {
  return segments.map((segment) => encodeURIComponent(segment)).join('/');
}

export class FirestoreProbeRecoveryController {
  constructor({
    projectId,
    databaseId = '(default)',
    fetchFn,
    accessTokenProvider,
    apiBase = FIRESTORE_API_BASE,
  }) {
    this.projectId = assertProjectId(projectId);
    this.databaseId = normalizeText(databaseId);

    if (this.databaseId === '') {
      throw new Error('MIG001E5_DATABASE_ID_REQUIRED');
    }

    if (typeof fetchFn !== 'function') {
      throw new Error('MIG001E5_FETCH_REQUIRED');
    }

    if (typeof accessTokenProvider !== 'function') {
      throw new Error('MIG001E5_TOKEN_PROVIDER_REQUIRED');
    }

    this.fetchFn = fetchFn;
    this.accessTokenProvider = accessTokenProvider;
    this.apiBase = apiBase.replace(/\/+$/u, '');
  }

  baseDocumentsUrl() {
    return `${this.apiBase}/projects/${encodeURIComponent(
      this.projectId,
    )}/databases/${encodeURIComponent(
      this.databaseId,
    )}/documents`;
  }

  probeDocumentUrl(target) {
    const safe = assertProbeDeleteTarget(target);
    const segments = [
      ...safe.collectionPath.split('/'),
      safe.documentId,
    ];

    return `${this.baseDocumentsUrl()}/${encodePathSegments(
      segments,
    )}`;
  }

  async authHeaders() {
    const token = normalizeText(await this.accessTokenProvider());

    if (token.length < 50 || /\s/u.test(token)) {
      throw new Error('MIG001E5_INVALID_ACCESS_TOKEN');
    }

    return {
      Authorization: `Bearer ${token}`,
    };
  }

  async getProbeState(target) {
    const safe = assertProbeDeleteTarget(target);

    const response = await this.fetchFn(
      `${this.probeDocumentUrl(
        safe,
      )}?mask.fieldPaths=contentHash`,
      {
        method: 'GET',
        headers: await this.authHeaders(),
      },
    );

    if (response?.status === 404) {
      return {
        exists: false,
        contentHash: null,
      };
    }

    if (!response?.ok) {
      throw new Error(
        `MIG001E5_PROBE_GET_FAILED:${response?.status ?? 'NO_STATUS'}`,
      );
    }

    const body = await response.json();

    return {
      exists: true,
      contentHash: readStringField(body, 'contentHash'),
    };
  }

  async deleteProbeIfHashMatches(target) {
    const safe = assertProbeDeleteTarget(target);
    const existing = await this.getProbeState(safe);

    if (!existing.exists) {
      return {
        outcome: 'already_missing',
        deleted: false,
      };
    }

    if (
      typeof existing.contentHash !== 'string' ||
      existing.contentHash === ''
    ) {
      throw new Error('MIG001E5_PROBE_EXISTING_HASH_REQUIRED');
    }

    if (existing.contentHash !== safe.expectedContentHash) {
      throw new Error('MIG001E5_PROBE_EXISTING_HASH_MISMATCH');
    }

    const response = await this.fetchFn(
      this.probeDocumentUrl(safe),
      {
        method: 'DELETE',
        headers: await this.authHeaders(),
      },
    );

    if (response?.status === 404) {
      return {
        outcome: 'already_missing_after_race',
        deleted: false,
      };
    }

    if (!response?.ok) {
      throw new Error(
        `MIG001E5_PROBE_DELETE_FAILED:${response?.status ?? 'NO_STATUS'}`,
      );
    }

    return {
      outcome: 'deleted',
      deleted: true,
    };
  }
}

export function assertRecoveryControllerSurface(controller) {
  const forbidden = [
    'delete',
    'deleteDocument',
    'deleteAll',
    'recursiveDelete',
    'patch',
    'update',
    'write',
  ];

  for (const name of forbidden) {
    if (typeof controller?.[name] === 'function') {
      throw new Error(
        `MIG001E5_FORBIDDEN_CONTROLLER_METHOD:${name}`,
      );
    }
  }

  return true;
}

export async function executeProbeRollback({ controller }) {
  if (
    typeof controller?.deleteProbeIfHashMatches !== 'function'
  ) {
    throw new Error('MIG001E5_HASH_GUARDED_DELETE_REQUIRED');
  }

  const plan = buildProbeRollbackPlan();
  const outcomes = [];

  for (const target of plan) {
    try {
      const result =
        await controller.deleteProbeIfHashMatches(target);

      if (
        !['deleted', 'already_missing', 'already_missing_after_race']
          .includes(result?.outcome)
      ) {
        throw new Error(
          `MIG001E5_ROLLBACK_OUTCOME_BLOCKED:${result?.outcome ?? 'UNKNOWN'}`,
        );
      }

      outcomes.push({
        probeRole: target.probeRole,
        collectionPath: target.collectionPath,
        documentId: target.documentId,
        outcome: result.outcome,
        deleted: result.deleted === true,
      });
    } catch (cause) {
      const error = new Error('MIG001E5_ROLLBACK_STOPPED');
      error.cause = cause;
      error.details = {
        completed: outcomes.length,
        probeRole: target.probeRole,
        collectionPath: target.collectionPath,
        documentId: target.documentId,
      };
      throw error;
    }
  }

  return {
    attempted: plan.length,
    completed: outcomes.length,
    deleted: outcomes.filter((row) => row.deleted).length,
    outcomes,
    batchDeletedFirst:
      outcomes.at(0)?.probeRole === 'batch',
    journalDeletedLast:
      outcomes.at(-1)?.probeRole === 'journal',
  };
}

export async function executeProbeRecovery({ writer }) {
  if (typeof writer?.createOnly !== 'function') {
    throw new Error('MIG001E5_CREATE_ONLY_WRITER_REQUIRED');
  }

  const plan = buildProbeRecoveryPlan();
  const outcomes = [];

  for (const write of plan) {
    try {
      const result = await writer.createOnly({
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        payload: write.payload,
      });

      if (
        !['created', 'unchanged', 'unchanged_after_race']
          .includes(result?.outcome)
      ) {
        throw new Error(
          `MIG001E5_RECOVERY_OUTCOME_BLOCKED:${result?.outcome ?? 'UNKNOWN'}`,
        );
      }

      outcomes.push({
        probeRole: write.probeRole,
        collectionPath: write.collectionPath,
        documentId: write.documentId,
        outcome: result.outcome,
        wrote: result.wrote === true,
      });
    } catch (cause) {
      const error = new Error('MIG001E5_RECOVERY_STOPPED');
      error.cause = cause;
      error.details = {
        completed: outcomes.length,
        probeRole: write.probeRole,
        collectionPath: write.collectionPath,
        documentId: write.documentId,
      };
      throw error;
    }
  }

  return {
    attempted: plan.length,
    completed: outcomes.length,
    created: outcomes.filter(
      (row) => row.outcome === 'created',
    ).length,
    unchanged: outcomes.filter(
      (row) =>
        row.outcome === 'unchanged' ||
        row.outcome === 'unchanged_after_race',
    ).length,
    outcomes,
    batchCreatedLast:
      outcomes.at(-1)?.probeRole === 'batch',
  };
}