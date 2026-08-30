import {
  assertAllowedCollectionPath,
  createOnlyDecision,
  normalizeText,
} from './mig001e3_core.mjs';

export const FIRESTORE_API_BASE = 'https://firestore.googleapis.com/v1';

function assertProjectId(projectId) {
  const value = normalizeText(projectId);

  if (!/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/u.test(value)) {
    throw new Error('MIG001E3_INVALID_PROJECT_ID');
  }

  return value;
}

function assertDocumentId(documentId) {
  const value = normalizeText(documentId);

  if (
    value === '' ||
    value === '.' ||
    value === '..' ||
    value.includes('/') ||
    value.length > 1500
  ) {
    throw new Error('MIG001E3_INVALID_DOCUMENT_ID');
  }

  return value;
}

function encodePathSegments(segments) {
  return segments.map((segment) => encodeURIComponent(segment)).join('/');
}

function splitCollectionPath(collectionPath) {
  const safe = assertAllowedCollectionPath(collectionPath);
  const segments = safe.split('/');

  return {
    safe,
    parentSegments: segments.slice(0, -1),
    collectionId: segments.at(-1),
  };
}

export function encodeFirestoreValue(value) {
  if (value === null) {
    return { nullValue: null };
  }

  if (typeof value === 'boolean') {
    return { booleanValue: value };
  }

  if (typeof value === 'string') {
    return { stringValue: value };
  }

  if (typeof value === 'number') {
    if (!Number.isFinite(value)) {
      throw new Error('MIG001E3_UNSUPPORTED_NUMBER');
    }

    if (Number.isSafeInteger(value)) {
      return { integerValue: String(value) };
    }

    return { doubleValue: value };
  }

  if (Array.isArray(value)) {
    return {
      arrayValue: {
        values: value.map(encodeFirestoreValue),
      },
    };
  }

  if (typeof value === 'object' && value !== undefined) {
    return {
      mapValue: {
        fields: encodeFirestoreFields(value),
      },
    };
  }

  throw new Error(`MIG001E3_UNSUPPORTED_VALUE_TYPE:${typeof value}`);
}

export function encodeFirestoreFields(document) {
  if (!document || typeof document !== 'object' || Array.isArray(document)) {
    throw new Error('MIG001E3_DOCUMENT_NOT_OBJECT');
  }

  const fields = {};

  for (const [key, value] of Object.entries(document)) {
    if (value === undefined) {
      throw new Error(`MIG001E3_UNDEFINED_FIELD:${key}`);
    }

    fields[key] = encodeFirestoreValue(value);
  }

  return fields;
}

export function readStringField(restDocument, fieldName) {
  const field = restDocument?.fields?.[fieldName];

  if (!field) return null;
  if (typeof field.stringValue === 'string') return field.stringValue;

  throw new Error(`MIG001E3_EXPECTED_STRING_FIELD:${fieldName}`);
}

export class FirestoreRestWriter {
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
      throw new Error('MIG001E3_INVALID_DATABASE_ID');
    }

    if (typeof fetchFn !== 'function') {
      throw new Error('MIG001E3_FETCH_REQUIRED');
    }

    if (typeof accessTokenProvider !== 'function') {
      throw new Error('MIG001E3_TOKEN_PROVIDER_REQUIRED');
    }

    this.fetchFn = fetchFn;
    this.accessTokenProvider = accessTokenProvider;
    this.apiBase = apiBase.replace(/\/+$/u, '');
  }

  baseDocumentsUrl() {
    return `${this.apiBase}/projects/${encodeURIComponent(
      this.projectId,
    )}/databases/${encodeURIComponent(this.databaseId)}/documents`;
  }

  documentUrl(collectionPath, documentId) {
    const { safe } = splitCollectionPath(collectionPath);
    const id = assertDocumentId(documentId);

    return `${this.baseDocumentsUrl()}/${encodePathSegments(
      [...safe.split('/'), id],
    )}`;
  }

  createUrl(collectionPath, documentId) {
    const { parentSegments, collectionId } =
      splitCollectionPath(collectionPath);
    const id = assertDocumentId(documentId);

    const parent =
      parentSegments.length === 0
        ? this.baseDocumentsUrl()
        : `${this.baseDocumentsUrl()}/${encodePathSegments(parentSegments)}`;

    return `${parent}/${encodeURIComponent(
      collectionId,
    )}?documentId=${encodeURIComponent(id)}`;
  }

  async authHeaders() {
    const token = normalizeText(await this.accessTokenProvider());

    if (token.length < 50) {
      throw new Error('MIG001E3_INVALID_ACCESS_TOKEN');
    }

    return {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  async getExistingContentHash(collectionPath, documentId) {
    const url = `${this.documentUrl(
      collectionPath,
      documentId,
    )}?mask.fieldPaths=contentHash`;

    const response = await this.fetchFn(url, {
      method: 'GET',
      headers: await this.authHeaders(),
    });

    if (response.status === 404) {
      return { exists: false, contentHash: null };
    }

    if (!response.ok) {
      throw new Error(`MIG001E3_GET_FAILED:${response.status}`);
    }

    const body = await response.json();

    return {
      exists: true,
      contentHash: readStringField(body, 'contentHash'),
    };
  }

  async createDocument(collectionPath, documentId, payload) {
    const response = await this.fetchFn(
      this.createUrl(collectionPath, documentId),
      {
        method: 'POST',
        headers: await this.authHeaders(),
        body: JSON.stringify({
          fields: encodeFirestoreFields(payload),
        }),
      },
    );

    if (response.ok) {
      return { created: true, conflict: false };
    }

    if (response.status === 409) {
      return { created: false, conflict: true };
    }

    throw new Error(`MIG001E3_CREATE_FAILED:${response.status}`);
  }

  async createOnly({
    collectionPath,
    documentId,
    payload,
    intendedContentHash = null,
  }) {
    const safeCollectionPath = assertAllowedCollectionPath(collectionPath);
    const safeDocumentId = assertDocumentId(documentId);

    const intendedHash =
      intendedContentHash ??
      (typeof payload?.contentHash === 'string' ? payload.contentHash : null);

    const existing = await this.getExistingContentHash(
      safeCollectionPath,
      safeDocumentId,
    );

    if (existing.exists) {
      if (intendedHash === null) {
        return {
          outcome: 'exists_without_comparable_hash',
          wrote: false,
        };
      }

      return {
        outcome: createOnlyDecision(existing.contentHash, intendedHash),
        wrote: false,
      };
    }

    const created = await this.createDocument(
      safeCollectionPath,
      safeDocumentId,
      payload,
    );

    if (created.created) {
      return { outcome: 'created', wrote: true };
    }

    // Corrida entre GET e POST: nunca faz patch.
    // Rele apenas o hash e classifica o documento vencedor.
    const afterConflict = await this.getExistingContentHash(
      safeCollectionPath,
      safeDocumentId,
    );

    if (!afterConflict.exists) {
      throw new Error('MIG001E3_CREATE_CONFLICT_WITHOUT_DOCUMENT');
    }

    if (intendedHash === null) {
      return {
        outcome: 'conflict_without_comparable_hash',
        wrote: false,
      };
    }

    return {
      outcome:
        afterConflict.contentHash === intendedHash
          ? 'unchanged_after_race'
          : 'changed_pending_review_after_race',
      wrote: false,
    };
  }
}

export function assertWriterSurface(writer) {
  const forbidden = ['patch', 'update', 'delete', 'deleteDocument'];

  for (const name of forbidden) {
    if (typeof writer?.[name] === 'function') {
      throw new Error(`MIG001E3_FORBIDDEN_WRITER_METHOD:${name}`);
    }
  }

  return true;
}