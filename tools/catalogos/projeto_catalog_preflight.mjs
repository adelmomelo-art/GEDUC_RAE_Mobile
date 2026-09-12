import { pathToFileURL } from 'node:url';

import {
  EXPECTED_RECORDS,
  SEED_COLLECTION,
  SEED_PROJECT_ID,
  buildSeedPlan,
  executeDryRun,
} from './projeto_catalog_seed.mjs';

import {
  createGcloudAdcTokenProvider,
} from '../migration/mig001e4_adc.mjs';

export const FIRESTORE_API_BASE = 'https://firestore.googleapis.com/v1';
export const PREFLIGHT_PAGE_SIZE = 100;

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

export function assertPreflightProjectId(projectId) {
  if (normalize(projectId) !== SEED_PROJECT_ID) {
    fail('BUGRAE002E_PREFLIGHT_PROJECT_CONFIRMATION_MISMATCH');
  }
  return SEED_PROJECT_ID;
}

export function assertPreflightCollection(collectionId) {
  if (normalize(collectionId) !== SEED_COLLECTION) {
    fail('BUGRAE002E_PREFLIGHT_COLLECTION_DENIED');
  }
  return SEED_COLLECTION;
}

function readStringField(restDocument, fieldName) {
  const field = restDocument?.fields?.[fieldName];
  if (!field) return null;

  if (typeof field.stringValue === 'string') {
    return field.stringValue;
  }

  fail('BUGRAE002E_PREFLIGHT_EXPECTED_STRING_FIELD', {
    fieldName,
  });
}

function documentIdFromName(name) {
  const value = normalize(name);

  if (value === '') {
    fail('BUGRAE002E_PREFLIGHT_DOCUMENT_NAME_INVALID');
  }

  const marker = `/documents/${SEED_COLLECTION}/`;
  const index = value.indexOf(marker);

  if (index < 0) {
    fail('BUGRAE002E_PREFLIGHT_DOCUMENT_OUTSIDE_COLLECTION', {
      name: value,
    });
  }

  const id = value.slice(index + marker.length);

  if (
    id === '' ||
    id.includes('/') ||
    id === '.' ||
    id === '..'
  ) {
    fail('BUGRAE002E_PREFLIGHT_DOCUMENT_ID_INVALID', {
      name: value,
    });
  }

  return id;
}

export class FirestoreProjectCatalogReadOnlyReader {
  constructor({
    projectId,
    fetchFn,
    accessTokenProvider,
    databaseId = '(default)',
    apiBase = FIRESTORE_API_BASE,
    pageSize = PREFLIGHT_PAGE_SIZE,
  }) {
    this.projectId = assertPreflightProjectId(projectId);
    this.collectionId = assertPreflightCollection(SEED_COLLECTION);

    if (typeof fetchFn !== 'function') {
      fail('BUGRAE002E_PREFLIGHT_FETCH_REQUIRED');
    }

    if (typeof accessTokenProvider !== 'function') {
      fail('BUGRAE002E_PREFLIGHT_TOKEN_PROVIDER_REQUIRED');
    }

    if (normalize(databaseId) === '') {
      fail('BUGRAE002E_PREFLIGHT_DATABASE_ID_INVALID');
    }

    if (!Number.isSafeInteger(pageSize) || pageSize < 1 || pageSize > 1000) {
      fail('BUGRAE002E_PREFLIGHT_PAGE_SIZE_INVALID');
    }

    this.databaseId = databaseId;
    this.fetchFn = fetchFn;
    this.accessTokenProvider = accessTokenProvider;
    this.apiBase = apiBase.replace(/\/+$/u, '');
    this.pageSize = pageSize;
  }

  async authHeaders() {
    const token = normalize(await this.accessTokenProvider());

    if (token.length < 50 || /\s/u.test(token)) {
      fail('BUGRAE002E_PREFLIGHT_ACCESS_TOKEN_INVALID');
    }

    return {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
    };
  }

  collectionUrl(pageToken = null) {
    const params = new URLSearchParams();
    params.set('pageSize', String(this.pageSize));
    params.append('mask.fieldPaths', 'contentHash');

    if (pageToken !== null) {
      const token = normalize(pageToken);
      if (token === '') {
        fail('BUGRAE002E_PREFLIGHT_PAGE_TOKEN_INVALID');
      }
      params.set('pageToken', token);
    }

    return `${this.apiBase}/projects/${encodeURIComponent(
      this.projectId,
    )}/databases/${encodeURIComponent(
      this.databaseId,
    )}/documents/${encodeURIComponent(
      this.collectionId,
    )}?${params.toString()}`;
  }

  async listCatalogDocuments() {
    const rows = [];
    let pageToken = null;
    let pages = 0;

    do {
      const response = await this.fetchFn(
        this.collectionUrl(pageToken),
        {
          method: 'GET',
          headers: await this.authHeaders(),
        },
      );

      if (!response?.ok) {
        fail('BUGRAE002E_PREFLIGHT_GET_FAILED', {
          status: response?.status ?? null,
        });
      }

      const body = await response.json();
      pages += 1;

      const documents = Array.isArray(body?.documents)
        ? body.documents
        : [];

      for (const document of documents) {
        rows.push({
          documentId: documentIdFromName(document?.name),
          contentHash: readStringField(document, 'contentHash'),
        });
      }

      pageToken =
        typeof body?.nextPageToken === 'string' &&
        body.nextPageToken.trim() !== ''
          ? body.nextPageToken
          : null;
    } while (pageToken !== null);

    rows.sort((a, b) => a.documentId.localeCompare(b.documentId));

    const ids = rows.map((row) => row.documentId);

    if (new Set(ids).size !== ids.length) {
      fail('BUGRAE002E_PREFLIGHT_DUPLICATE_REMOTE_DOCUMENT_ID');
    }

    return {
      pages,
      documents: rows,
    };
  }
}

export function assertReadOnlyReaderSurface(reader) {
  const forbidden = [
    'create',
    'createOnly',
    'createDocument',
    'write',
    'update',
    'patch',
    'put',
    'delete',
    'deleteDocument',
  ];

  for (const name of forbidden) {
    if (typeof reader?.[name] === 'function') {
      fail('BUGRAE002E_PREFLIGHT_FORBIDDEN_METHOD', { name });
    }
  }

  if (typeof reader?.listCatalogDocuments !== 'function') {
    fail('BUGRAE002E_PREFLIGHT_LIST_METHOD_REQUIRED');
  }

  return true;
}

export function classifyCatalogPreflight({
  plan,
  remoteDocuments,
}) {
  if (!Array.isArray(plan) || plan.length !== EXPECTED_RECORDS) {
    fail('BUGRAE002E_PREFLIGHT_PLAN_INVALID');
  }

  if (!Array.isArray(remoteDocuments)) {
    fail('BUGRAE002E_PREFLIGHT_REMOTE_DOCUMENTS_INVALID');
  }

  const intended = new Map(
    plan.map((item) => [
      item.documentId,
      item.intendedContentHash,
    ]),
  );

  const remote = new Map();

  for (const row of remoteDocuments) {
    if (
      !row ||
      typeof row.documentId !== 'string' ||
      row.documentId.trim() === ''
    ) {
      fail('BUGRAE002E_PREFLIGHT_REMOTE_ROW_INVALID');
    }

    if (remote.has(row.documentId)) {
      fail('BUGRAE002E_PREFLIGHT_DUPLICATE_REMOTE_DOCUMENT_ID');
    }

    remote.set(row.documentId, row.contentHash ?? null);
  }

  const results = [];
  const blockers = [];

  for (const item of plan) {
    let classification;

    if (!remote.has(item.documentId)) {
      classification = 'missing';
    } else {
      const remoteHash = remote.get(item.documentId);

      if (remoteHash === item.intendedContentHash) {
        classification = 'unchanged';
      } else if (
        remoteHash === null ||
        remoteHash === undefined
      ) {
        classification = 'exists_without_comparable_hash';
      } else {
        classification = 'changed_pending_review';
      }
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

  for (const documentId of remote.keys()) {
    if (!intended.has(documentId)) {
      const row = {
        documentId,
        classification: 'unexpected_remote_document',
      };

      results.push(row);
      blockers.push(row);
    }
  }

  results.sort((a, b) => a.documentId.localeCompare(b.documentId));
  blockers.sort((a, b) => a.documentId.localeCompare(b.documentId));

  const count = (kind) =>
    results.filter((row) => row.classification === kind).length;

  return {
    ready: blockers.length === 0,
    expected: EXPECTED_RECORDS,
    remote: remoteDocuments.length,
    missing: count('missing'),
    unchanged: count('unchanged'),
    existsWithoutComparableHash: count(
      'exists_without_comparable_hash',
    ),
    changedPendingReview: count('changed_pending_review'),
    unexpectedRemoteDocuments: count(
      'unexpected_remote_document',
    ),
    blockers,
    results,
  };
}

export async function executeCatalogRemotePreflight({
  projectId,
  reader,
}) {
  assertPreflightProjectId(projectId);
  assertReadOnlyReaderSurface(reader);

  const local = await executeDryRun({
    projectId,
  });

  const remote = await reader.listCatalogDocuments();

  const preflight = classifyCatalogPreflight({
    plan: local.plan,
    remoteDocuments: remote.documents,
  });

  return {
    mode: 'remote-read-only-preflight',
    projectId,
    collection: SEED_COLLECTION,
    pages: remote.pages,
    ...preflight,
    firestoreReads: remote.pages,
    firestoreWrites: 0,
  };
}

export function parseArgs(argv) {
  const args = {
    mode: null,
    projectId: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];

    if (token === '--remote-read-only') {
      args.mode = 'remote-read-only';
      continue;
    }

    if (token === '--apply') {
      fail('BUGRAE002E_PREFLIGHT_APPLY_FORBIDDEN');
    }

    if (token === '--project-id') {
      const value = argv[index + 1];

      if (!value || value.startsWith('--')) {
        fail('BUGRAE002E_PREFLIGHT_PROJECT_ID_ARGUMENT_REQUIRED');
      }

      args.projectId = value;
      index += 1;
      continue;
    }

    fail('BUGRAE002E_PREFLIGHT_UNKNOWN_ARGUMENT', { token });
  }

  if (args.mode !== 'remote-read-only') {
    fail('BUGRAE002E_PREFLIGHT_EXPLICIT_REMOTE_MODE_REQUIRED');
  }

  assertPreflightProjectId(args.projectId);

  return Object.freeze(args);
}

export async function main(
  argv = process.argv.slice(2),
  {
    fetchFn = globalThis.fetch,
    accessTokenProvider = createGcloudAdcTokenProvider(),
  } = {},
) {
  const args = parseArgs(argv);

  if (typeof fetchFn !== 'function') {
    fail('BUGRAE002E_PREFLIGHT_GLOBAL_FETCH_UNAVAILABLE');
  }

  const reader = new FirestoreProjectCatalogReadOnlyReader({
    projectId: args.projectId,
    fetchFn,
    accessTokenProvider,
  });

  const result = await executeCatalogRemotePreflight({
    projectId: args.projectId,
    reader,
  });

  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  return result;
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
