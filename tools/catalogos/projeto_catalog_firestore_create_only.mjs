export const CATALOG_PROJECT_ID = 'geduc-rae-mobile';
export const CATALOG_COLLECTION = 'projetos';
export const FIRESTORE_API_BASE = 'https://firestore.googleapis.com/v1';

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

export function assertCatalogProjectId(projectId) {
  if (normalize(projectId) !== CATALOG_PROJECT_ID) {
    fail('BUGRAE002E_REMOTE_PROJECT_CONFIRMATION_MISMATCH');
  }

  return CATALOG_PROJECT_ID;
}

export function assertCatalogCollection(collectionPath) {
  if (normalize(collectionPath) !== CATALOG_COLLECTION) {
    fail('BUGRAE002E_REMOTE_COLLECTION_DENIED');
  }

  return CATALOG_COLLECTION;
}

export function assertCatalogDocumentId(documentId) {
  const value = normalize(documentId);

  if (
    value === '' ||
    value === '.' ||
    value === '..' ||
    value.includes('/') ||
    value.length > 1500
  ) {
    fail('BUGRAE002E_REMOTE_DOCUMENT_ID_INVALID');
  }

  return value;
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
      fail('BUGRAE002E_REMOTE_UNSUPPORTED_NUMBER');
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

  fail('BUGRAE002E_REMOTE_UNSUPPORTED_VALUE_TYPE', {
    type: typeof value,
  });
}

export function encodeFirestoreFields(document) {
  if (!document || typeof document !== 'object' || Array.isArray(document)) {
    fail('BUGRAE002E_REMOTE_DOCUMENT_NOT_OBJECT');
  }

  const fields = {};

  for (const [key, value] of Object.entries(document)) {
    if (value === undefined) {
      fail('BUGRAE002E_REMOTE_UNDEFINED_FIELD', { key });
    }

    fields[key] = encodeFirestoreValue(value);
  }

  return fields;
}

function readStringField(restDocument, fieldName) {
  const field = restDocument?.fields?.[fieldName];

  if (!field) return null;

  if (typeof field.stringValue === 'string') {
    return field.stringValue;
  }

  fail('BUGRAE002E_REMOTE_EXPECTED_STRING_FIELD', {
    fieldName,
  });
}

function createOnlyDecision(existingContentHash, intendedContentHash) {
  if (existingContentHash === null || existingContentHash === undefined) {
    return 'exists_without_comparable_hash';
  }

  if (existingContentHash === intendedContentHash) {
    return 'unchanged';
  }

  return 'changed_pending_review';
}

export class FirestoreProjectCatalogCreateOnlyAdapter {
  constructor({
    projectId,
    fetchFn,
    accessTokenProvider,
    databaseId = '(default)',
    apiBase = FIRESTORE_API_BASE,
  }) {
    this.projectId = assertCatalogProjectId(projectId);

    if (typeof fetchFn !== 'function') {
      fail('BUGRAE002E_REMOTE_FETCH_REQUIRED');
    }

    if (typeof accessTokenProvider !== 'function') {
      fail('BUGRAE002E_REMOTE_TOKEN_PROVIDER_REQUIRED');
    }

    if (normalize(databaseId) === '') {
      fail('BUGRAE002E_REMOTE_DATABASE_ID_INVALID');
    }

    this.fetchFn = fetchFn;
    this.accessTokenProvider = accessTokenProvider;
    this.databaseId = databaseId;
    this.apiBase = apiBase.replace(/\/+$/u, '');
  }

  baseDocumentsUrl() {
    return `${this.apiBase}/projects/${encodeURIComponent(
      this.projectId,
    )}/databases/${encodeURIComponent(
      this.databaseId,
    )}/documents`;
  }

  documentUrl(collectionPath, documentId) {
    const collection = assertCatalogCollection(collectionPath);
    const id = assertCatalogDocumentId(documentId);

    return `${this.baseDocumentsUrl()}/${encodeURIComponent(
      collection,
    )}/${encodeURIComponent(id)}`;
  }

  createUrl(collectionPath, documentId) {
    const collection = assertCatalogCollection(collectionPath);
    const id = assertCatalogDocumentId(documentId);

    return `${this.baseDocumentsUrl()}/${encodeURIComponent(
      collection,
    )}?documentId=${encodeURIComponent(id)}`;
  }

  async authHeaders() {
    const token = normalize(await this.accessTokenProvider());

    if (token.length < 50 || /\s/u.test(token)) {
      fail('BUGRAE002E_REMOTE_ACCESS_TOKEN_INVALID');
    }

    return {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  async getExistingContentHash(collectionPath, documentId) {
    const collection = assertCatalogCollection(collectionPath);
    const id = assertCatalogDocumentId(documentId);

    const response = await this.fetchFn(
      `${this.documentUrl(
        collection,
        id,
      )}?mask.fieldPaths=contentHash`,
      {
        method: 'GET',
        headers: await this.authHeaders(),
      },
    );

    if (response.status === 404) {
      return {
        exists: false,
        contentHash: null,
      };
    }

    if (!response.ok) {
      fail('BUGRAE002E_REMOTE_GET_FAILED', {
        status: response.status,
      });
    }

    const body = await response.json();

    return {
      exists: true,
      contentHash: readStringField(body, 'contentHash'),
    };
  }

  async #createDocument(collectionPath, documentId, payload) {
    const collection = assertCatalogCollection(collectionPath);
    const id = assertCatalogDocumentId(documentId);

    const response = await this.fetchFn(
      this.createUrl(collection, id),
      {
        method: 'POST',
        headers: await this.authHeaders(),
        body: JSON.stringify({
          fields: encodeFirestoreFields(payload),
        }),
      },
    );

    if (response.ok) {
      return {
        created: true,
        conflict: false,
      };
    }

    if (response.status === 409) {
      return {
        created: false,
        conflict: true,
      };
    }

    fail('BUGRAE002E_REMOTE_CREATE_FAILED', {
      status: response.status,
    });
  }

  async createOnly({
    collectionPath,
    documentId,
    payload,
    intendedContentHash = null,
  }) {
    const collection = assertCatalogCollection(collectionPath);
    const id = assertCatalogDocumentId(documentId);

    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      fail('BUGRAE002E_REMOTE_PAYLOAD_INVALID');
    }

    const hash =
      intendedContentHash ??
      (typeof payload.contentHash === 'string'
        ? payload.contentHash
        : null);

    if (typeof hash !== 'string' || hash.trim() === '') {
      fail('BUGRAE002E_REMOTE_INTENDED_HASH_REQUIRED');
    }

    if (payload.contentHash !== hash) {
      fail('BUGRAE002E_REMOTE_PAYLOAD_HASH_MISMATCH');
    }

    const existing =
      await this.getExistingContentHash(
        collection,
        id,
      );

    if (existing.exists) {
      return {
        outcome: createOnlyDecision(
          existing.contentHash,
          hash,
        ),
        wrote: false,
      };
    }

    const created =
      await this.#createDocument(
        collection,
        id,
        payload,
      );

    if (created.created) {
      return {
        outcome: 'created',
        wrote: true,
      };
    }

    const afterConflict =
      await this.getExistingContentHash(
        collection,
        id,
      );

    if (!afterConflict.exists) {
      fail('BUGRAE002E_REMOTE_CONFLICT_WITHOUT_DOCUMENT');
    }

    if (afterConflict.contentHash === hash) {
      return {
        outcome: 'unchanged_after_race',
        wrote: false,
      };
    }

    if (
      afterConflict.contentHash === null ||
      afterConflict.contentHash === undefined
    ) {
      return {
        outcome: 'conflict_without_comparable_hash',
        wrote: false,
      };
    }

    return {
      outcome: 'changed_pending_review_after_race',
      wrote: false,
    };
  }
}

export function assertRemoteAdapterSurface(adapter) {
  if (typeof adapter?.getExistingContentHash !== 'function') {
    fail('BUGRAE002E_REMOTE_GET_HASH_METHOD_REQUIRED');
  }

  if (typeof adapter?.createOnly !== 'function') {
    fail('BUGRAE002E_REMOTE_CREATE_ONLY_METHOD_REQUIRED');
  }

  const forbidden = [
    'create',
    'createDocument',
    'set',
    'write',
    'update',
    'patch',
    'put',
    'delete',
    'deleteDocument',
  ];

  for (const name of forbidden) {
    if (typeof adapter?.[name] === 'function') {
      fail('BUGRAE002E_REMOTE_FORBIDDEN_METHOD', {
        name,
      });
    }
  }

  return true;
}
