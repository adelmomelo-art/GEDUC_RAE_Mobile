import {
  AtomicEvidenceUploadPersister,
  type EvidencePrivateObjectMetadata,
  type EvidencePrivateStorageCreateInput,
  type EvidencePrivateStorageCreateResult,
  type EvidencePrivateStoragePort,
  type EvidenceUploadPersister,
} from "./evidence_persistence";
import {
  buildEvidenceIdempotencyKey,
  buildEvidenceObjectKey,
  parseEvidenceUploadGrantRequest,
  type EvidenceUploadGrantRequest,
} from "./evidence_contract";

export interface R2EvidenceObject {
  key: string;
  size: number;
  httpMetadata?: {
    contentType?: string;
  };
  customMetadata?: Record<string, string>;
  checksums?: {
    sha256?: ArrayBuffer;
  };
}

export interface R2EvidencePutOptions {
  onlyIf: {
    etagDoesNotMatch: "*";
  };
  httpMetadata: {
    contentType: "image/jpeg";
  };
  customMetadata: Record<string, string>;
  sha256: string;
}

export interface R2EvidenceBucketBinding {
  put(
    key: string,
    value: ArrayBuffer,
    options: R2EvidencePutOptions,
  ): Promise<R2EvidenceObject | null>;

  head(key: string): Promise<R2EvidenceObject | null>;
}

export interface EvidenceWorkerR2Bindings {
  EVIDENCE_BUCKET?: R2EvidenceBucketBinding;
}

export class R2EvidenceStorageError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "R2EvidenceStorageError";
  }
}

const metadataSchema = "fenix-evidence-private-v1";

function bytesToHex(value: ArrayBuffer): string {
  return Array.from(
    new Uint8Array(value),
    (byte) => byte.toString(16).padStart(2, "0"),
  ).join("");
}

function serializeMetadata(
  input: EvidencePrivateStorageCreateInput,
): Record<string, string> {
  return {
    fenixSchema: metadataSchema,
    acaoId: input.metadata.acaoId,
    evidenciaId: input.metadata.evidenciaId,
    autorUserId: input.metadata.autorUserId,
    contentType: input.metadata.contentType,
    tamanhoBytes: input.metadata.tamanhoBytes.toString(10),
    sha256: input.metadata.sha256,
    idempotencyKey: input.metadata.idempotencyKey,
    requestedByCallerUid: input.requestedByCallerUid,
  };
}

function parseCanonicalSize(value: string | undefined): number | null {
  if (value === undefined || !/^[1-9][0-9]*$/.test(value)) {
    return null;
  }

  const parsed = Number(value);

  if (!Number.isSafeInteger(parsed) || parsed.toString(10) !== value) {
    return null;
  }

  return parsed;
}

function parseExistingObject(
  object: R2EvidenceObject,
): EvidencePrivateObjectMetadata | null {
  const metadata = object.customMetadata;

  if (
    metadata === undefined ||
    metadata.fenixSchema !== metadataSchema ||
    metadata.contentType !== "image/jpeg" ||
    metadata.requestedByCallerUid === undefined ||
    metadata.requestedByCallerUid.trim().length === 0
  ) {
    return null;
  }

  const tamanhoBytes = parseCanonicalSize(metadata.tamanhoBytes);

  if (tamanhoBytes === null) {
    return null;
  }

  let request: EvidenceUploadGrantRequest;

  try {
    request = parseEvidenceUploadGrantRequest({
      acaoId: metadata.acaoId,
      evidenciaId: metadata.evidenciaId,
      autorUserId: metadata.autorUserId,
      contentType: metadata.contentType,
      tamanhoBytes,
      sha256: metadata.sha256,
    });
  } catch {
    return null;
  }

  const objectKey = buildEvidenceObjectKey(request);
  const idempotencyKey = buildEvidenceIdempotencyKey(request);
  const storedChecksum = object.checksums?.sha256;

  if (
    object.key !== objectKey ||
    object.size !== tamanhoBytes ||
    object.httpMetadata?.contentType !== request.contentType ||
    metadata.idempotencyKey !== idempotencyKey ||
    storedChecksum === undefined ||
    bytesToHex(storedChecksum) !== request.sha256
  ) {
    return null;
  }

  return {
    objectKey,
    acaoId: request.acaoId,
    evidenciaId: request.evidenciaId,
    autorUserId: request.autorUserId,
    contentType: request.contentType,
    tamanhoBytes: request.tamanhoBytes,
    sha256: request.sha256,
    idempotencyKey,
  };
}

function sameIdentity(
  expected: EvidencePrivateObjectMetadata,
  actual: EvidencePrivateObjectMetadata,
): boolean {
  return (
    expected.objectKey === actual.objectKey &&
    expected.acaoId === actual.acaoId &&
    expected.evidenciaId === actual.evidenciaId &&
    expected.autorUserId === actual.autorUserId &&
    expected.contentType === actual.contentType &&
    expected.tamanhoBytes === actual.tamanhoBytes &&
    expected.sha256 === actual.sha256 &&
    expected.idempotencyKey === actual.idempotencyKey
  );
}

export class R2EvidencePrivateStorageAdapter
  implements EvidencePrivateStoragePort {
  constructor(
    private readonly bucket: R2EvidenceBucketBinding,
  ) {}

  async createIfAbsent(
    input: EvidencePrivateStorageCreateInput,
  ): Promise<EvidencePrivateStorageCreateResult> {
    const created = await this.bucket.put(
      input.metadata.objectKey,
      input.bytes,
      {
        onlyIf: {
          etagDoesNotMatch: "*",
        },
        httpMetadata: {
          contentType: input.metadata.contentType,
        },
        customMetadata: serializeMetadata(input),
        sha256: input.metadata.sha256,
      },
    );

    if (created !== null) {
      const createdIdentity = parseExistingObject(created);

      if (
        createdIdentity === null ||
        !sameIdentity(input.metadata, createdIdentity)
      ) {
        throw new R2EvidenceStorageError(
          "invalid_created_object",
          "R2 retornou identidade inesperada apos a criacao.",
        );
      }

      return {
        status: "created",
      };
    }

    const existing = await this.bucket.head(input.metadata.objectKey);

    if (existing === null) {
      throw new R2EvidenceStorageError(
        "precondition_state_unavailable",
        "Objeto nao pode ser confirmado apos precondicao R2.",
      );
    }

    const existingIdentity = parseExistingObject(existing);

    if (existingIdentity === null) {
      return {
        status: "conflict",
      };
    }

    return {
      status: "already_exists",
      object: existingIdentity,
    };
  }
}

export function createR2EvidenceUploadPersister(
  bindings: EvidenceWorkerR2Bindings,
): EvidenceUploadPersister | undefined {
  if (bindings.EVIDENCE_BUCKET === undefined) {
    return undefined;
  }

  return new AtomicEvidenceUploadPersister(
    new R2EvidencePrivateStorageAdapter(bindings.EVIDENCE_BUCKET),
  );
}
