import {
  buildEvidenceIdempotencyKey,
  buildEvidenceObjectKey,
  parseEvidenceUploadGrantRequest,
  type EvidenceUploadGrantRequest,
} from "./evidence_contract";
import type { ValidatedEvidenceUpload } from "./evidence_upload";

export interface EvidencePrivateObjectMetadata {
  objectKey: string;
  acaoId: string;
  evidenciaId: string;
  autorUserId: string;
  contentType: "image/jpeg";
  tamanhoBytes: number;
  sha256: string;
  idempotencyKey: string;
}

export interface EvidencePrivateStorageCreateInput {
  metadata: EvidencePrivateObjectMetadata;
  requestedByCallerUid: string;
  bytes: ArrayBuffer;
}

export type EvidencePrivateStorageCreateResult =
  | { status: "created" }
  | { status: "conflict" }
  | {
      status: "already_exists";
      object: EvidencePrivateObjectMetadata;
    };

export interface EvidencePrivateStoragePort {
  createIfAbsent(
    input: EvidencePrivateStorageCreateInput,
  ): Promise<EvidencePrivateStorageCreateResult>;
}

export interface EvidenceUploadPersistenceResult {
  status: "created" | "already_exists";
  objectKey: string;
  sha256: string;
  tamanhoBytes: number;
}

export interface EvidenceUploadPersister {
  persist(
    upload: ValidatedEvidenceUpload,
  ): Promise<EvidenceUploadPersistenceResult>;
}

export class EvidencePersistenceError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "EvidencePersistenceError";
  }
}

function invalidValidatedUpload(): EvidencePersistenceError {
  return new EvidencePersistenceError(
    "invalid_validated_upload",
    "Upload validado diverge do contrato de persistencia.",
  );
}

function buildMetadata(
  upload: ValidatedEvidenceUpload,
): EvidencePrivateObjectMetadata {
  let request: EvidenceUploadGrantRequest;

  try {
    request = parseEvidenceUploadGrantRequest({
      acaoId: upload.claims.acaoId,
      evidenciaId: upload.claims.evidenciaId,
      autorUserId: upload.claims.autorUserId,
      contentType: upload.claims.contentType,
      tamanhoBytes: upload.claims.tamanhoBytes,
      sha256: upload.claims.sha256,
    });
  } catch {
    throw invalidValidatedUpload();
  }

  const callerUid = upload.claims.callerUid.trim();
  const objectKey = buildEvidenceObjectKey(request);

  if (
    callerUid.length === 0 ||
    upload.claims.objectKey !== objectKey ||
    upload.sha256 !== request.sha256 ||
    !(upload.bytes instanceof ArrayBuffer) ||
    upload.bytes.byteLength !== request.tamanhoBytes
  ) {
    throw invalidValidatedUpload();
  }

  return {
    objectKey,
    acaoId: request.acaoId,
    evidenciaId: request.evidenciaId,
    autorUserId: request.autorUserId,
    contentType: request.contentType,
    tamanhoBytes: request.tamanhoBytes,
    sha256: request.sha256,
    idempotencyKey: buildEvidenceIdempotencyKey(request),
  };
}

function metadataMatches(
  expected: EvidencePrivateObjectMetadata,
  actual: EvidencePrivateObjectMetadata,
): boolean {
  return (
    actual.objectKey === expected.objectKey &&
    actual.acaoId === expected.acaoId &&
    actual.evidenciaId === expected.evidenciaId &&
    actual.autorUserId === expected.autorUserId &&
    actual.contentType === expected.contentType &&
    actual.tamanhoBytes === expected.tamanhoBytes &&
    actual.sha256 === expected.sha256 &&
    actual.idempotencyKey === expected.idempotencyKey
  );
}

export class AtomicEvidenceUploadPersister
  implements EvidenceUploadPersister {
  constructor(
    private readonly storage: EvidencePrivateStoragePort,
  ) {}

  async persist(
    upload: ValidatedEvidenceUpload,
  ): Promise<EvidenceUploadPersistenceResult> {
    const metadata = buildMetadata(upload);
    let result: EvidencePrivateStorageCreateResult;

    try {
      result = await this.storage.createIfAbsent({
        metadata,
        requestedByCallerUid: upload.claims.callerUid.trim(),
        bytes: upload.bytes,
      });
    } catch {
      throw new EvidencePersistenceError(
        "storage_unavailable",
        "Porta privada de persistencia indisponivel.",
      );
    }

    if (result.status === "created") {
      return {
        status: "created",
        objectKey: metadata.objectKey,
        sha256: metadata.sha256,
        tamanhoBytes: metadata.tamanhoBytes,
      };
    }

    if (result.status === "conflict") {
      throw new EvidencePersistenceError(
        "object_conflict",
        "Objeto existente nao possui identidade autorizada.",
      );
    }

    if (result.status === "already_exists") {
      if (!metadataMatches(metadata, result.object)) {
        throw new EvidencePersistenceError(
          "object_conflict",
          "Objeto existente diverge da identidade autorizada.",
        );
      }

      return {
        status: "already_exists",
        objectKey: metadata.objectKey,
        sha256: metadata.sha256,
        tamanhoBytes: metadata.tamanhoBytes,
      };
    }

    throw new EvidencePersistenceError(
      "invalid_storage_result",
      "Porta privada retornou resultado invalido.",
    );
  }
}
