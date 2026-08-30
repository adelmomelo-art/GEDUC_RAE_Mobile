import {
  canonicalJson,
  normalizeText,
  sha256Hex,
} from './mig001e3_core.mjs';
import { FIRESTORE_API_BASE } from './mig001e3_firestore_rest.mjs';

export const FINGERPRINT_READ_ALLOWLIST = Object.freeze([
  'acoes',
  'contadores',
]);

function assertProjectId(projectId) {
  const value = normalizeText(projectId);

  if (!/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/u.test(value)) {
    throw new Error('MIG001E4_FINGERPRINT_INVALID_PROJECT_ID');
  }

  return value;
}

export function assertFingerprintCollection(collectionId) {
  const value = normalizeText(collectionId);

  if (!FINGERPRINT_READ_ALLOWLIST.includes(value)) {
    throw new Error(`MIG001E4_FINGERPRINT_COLLECTION_DENIED:${value}`);
  }

  return value;
}

function canonicalRestDocument(document) {
  if (!document || typeof document !== 'object' || Array.isArray(document)) {
    throw new Error('MIG001E4_FINGERPRINT_INVALID_DOCUMENT');
  }

  const name = normalizeText(document.name);

  if (name === '') {
    throw new Error('MIG001E4_FINGERPRINT_DOCUMENT_NAME_REQUIRED');
  }

  return {
    name,
    fields: document.fields ?? {},
    createTime: document.createTime ?? null,
    updateTime: document.updateTime ?? null,
  };
}

export class FirestoreReadOnlyFingerprinter {
  constructor({
    projectId,
    databaseId = '(default)',
    fetchFn,
    accessTokenProvider,
    apiBase = FIRESTORE_API_BASE,
    pageSize = 300,
  }) {
    this.projectId = assertProjectId(projectId);
    this.databaseId = normalizeText(databaseId);

    if (this.databaseId === '') {
      throw new Error('MIG001E4_FINGERPRINT_INVALID_DATABASE_ID');
    }

    if (typeof fetchFn !== 'function') {
      throw new Error('MIG001E4_FINGERPRINT_FETCH_REQUIRED');
    }

    if (typeof accessTokenProvider !== 'function') {
      throw new Error('MIG001E4_FINGERPRINT_TOKEN_PROVIDER_REQUIRED');
    }

    if (!Number.isSafeInteger(pageSize) || pageSize < 1 || pageSize > 1000) {
      throw new Error('MIG001E4_FINGERPRINT_INVALID_PAGE_SIZE');
    }

    this.fetchFn = fetchFn;
    this.accessTokenProvider = accessTokenProvider;
    this.apiBase = apiBase.replace(/\/+$/u, '');
    this.pageSize = pageSize;
  }

  baseDocumentsUrl() {
    return `${this.apiBase}/projects/${encodeURIComponent(
      this.projectId,
    )}/databases/${encodeURIComponent(this.databaseId)}/documents`;
  }

  async authHeaders() {
    const token = await this.accessTokenProvider();

    if (
      typeof token !== 'string' ||
      token.length < 50 ||
      /\s/u.test(token)
    ) {
      throw new Error('MIG001E4_FINGERPRINT_INVALID_ACCESS_TOKEN');
    }

    return {
      Authorization: `Bearer ${token}`,
    };
  }

  async listCollectionDocuments(collectionId) {
    const safeCollection = assertFingerprintCollection(collectionId);
    const documents = [];
    let pageToken = null;
    let pages = 0;

    do {
      pages += 1;

      if (pages > 1000) {
        throw new Error('MIG001E4_FINGERPRINT_PAGE_LIMIT_EXCEEDED');
      }

      const params = new URLSearchParams({
        pageSize: String(this.pageSize),
        showMissing: 'false',
      });

      if (pageToken !== null) {
        params.set('pageToken', pageToken);
      }

      const url = `${this.baseDocumentsUrl()}/${encodeURIComponent(
        safeCollection,
      )}?${params.toString()}`;

      const response = await this.fetchFn(url, {
        method: 'GET',
        headers: await this.authHeaders(),
      });

      if (!response?.ok) {
        throw new Error(
          `MIG001E4_FINGERPRINT_LIST_FAILED:${response?.status ?? 'NO_STATUS'}`,
        );
      }

      const body = await response.json();
      const pageDocuments = body.documents ?? [];

      if (!Array.isArray(pageDocuments)) {
        throw new Error('MIG001E4_FINGERPRINT_DOCUMENTS_NOT_ARRAY');
      }

      documents.push(...pageDocuments.map(canonicalRestDocument));

      const next = body.nextPageToken;

      if (next === undefined || next === null || next === '') {
        pageToken = null;
      } else if (typeof next === 'string' && !/\s/u.test(next)) {
        pageToken = next;
      } else {
        throw new Error('MIG001E4_FINGERPRINT_INVALID_PAGE_TOKEN');
      }
    } while (pageToken !== null);

    documents.sort((a, b) => a.name.localeCompare(b.name));

    return {
      collectionId: safeCollection,
      pages,
      documents,
    };
  }

  async fingerprintCollection(collectionId) {
    const listed = await this.listCollectionDocuments(collectionId);

    const material = listed.documents
      .map((document) => canonicalJson(document))
      .join('\n');

    const namesMaterial = listed.documents
      .map((document) => document.name)
      .join('\n');

    return {
      collectionId: listed.collectionId,
      count: listed.documents.length,
      pages: listed.pages,
      sha256: sha256Hex(material),
      namesSha256: sha256Hex(namesMaterial),
    };
  }
}

export function assertFingerprinterReadOnlySurface(fingerprinter) {
  const forbidden = [
    'create',
    'createOnly',
    'createDocument',
    'patch',
    'update',
    'delete',
    'deleteDocument',
    'write',
  ];

  for (const name of forbidden) {
    if (typeof fingerprinter?.[name] === 'function') {
      throw new Error(`MIG001E4_FINGERPRINTER_FORBIDDEN_METHOD:${name}`);
    }
  }

  return true;
}