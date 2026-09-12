export interface EvidenceUploadGrantRequest {
  acaoId: string;
  evidenciaId: string;
  autorUserId: string;
  contentType: "image/jpeg";
  tamanhoBytes: number;
  sha256: string;
}

export class EvidenceContractError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "EvidenceContractError";
  }
}

const allowedFields = new Set([
  "acaoId",
  "evidenciaId",
  "autorUserId",
  "contentType",
  "tamanhoBytes",
  "sha256",
]);

const sha256Pattern = /^[a-f0-9]{64}$/;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function normalizeSegment(
  value: unknown,
  field: string,
): string {
  if (typeof value !== "string") {
    throw new EvidenceContractError(
      "invalid_field",
      `${field} deve ser string.`,
    );
  }

  const normalized = value.trim();

  if (normalized.length === 0) {
    throw new EvidenceContractError(
      "invalid_field",
      `${field} nao pode ser vazio.`,
    );
  }

  if (
    normalized === "." ||
    normalized === ".." ||
    normalized.includes("/") ||
    normalized.includes("\\") ||
    /[\u0000-\u001f\u007f]/.test(normalized)
  ) {
    throw new EvidenceContractError(
      "unsafe_identifier",
      `${field} contem caracteres nao permitidos.`,
    );
  }

  return normalized;
}

export function parseEvidenceUploadGrantRequest(
  input: unknown,
): EvidenceUploadGrantRequest {
  if (!isRecord(input)) {
    throw new EvidenceContractError(
      "invalid_body",
      "Body deve ser um objeto JSON.",
    );
  }

  for (const field of Object.keys(input)) {
    if (!allowedFields.has(field)) {
      throw new EvidenceContractError(
        "unexpected_field",
        `Campo inesperado: ${field}.`,
      );
    }
  }

  const acaoId = normalizeSegment(input.acaoId, "acaoId");
  const evidenciaId = normalizeSegment(
    input.evidenciaId,
    "evidenciaId",
  );
  const autorUserId = normalizeSegment(
    input.autorUserId,
    "autorUserId",
  );

  if (input.contentType !== "image/jpeg") {
    throw new EvidenceContractError(
      "unsupported_content_type",
      "contentType deve ser image/jpeg.",
    );
  }

  if (
    typeof input.tamanhoBytes !== "number" ||
    !Number.isSafeInteger(input.tamanhoBytes) ||
    input.tamanhoBytes <= 0
  ) {
    throw new EvidenceContractError(
      "invalid_size",
      "tamanhoBytes deve ser inteiro positivo.",
    );
  }

  if (
    typeof input.sha256 !== "string" ||
    !sha256Pattern.test(input.sha256)
  ) {
    throw new EvidenceContractError(
      "invalid_sha256",
      "sha256 deve conter 64 caracteres hexadecimais minusculos.",
    );
  }

  return {
    acaoId,
    evidenciaId,
    autorUserId,
    contentType: "image/jpeg",
    tamanhoBytes: input.tamanhoBytes,
    sha256: input.sha256,
  };
}

export function buildEvidenceObjectKey(
  request: EvidenceUploadGrantRequest,
): string {
  return (
    `evidencias/v1/${request.acaoId}/` +
    `${request.evidenciaId}/${request.sha256}.jpg`
  );
}

export function buildEvidenceIdempotencyKey(
  request: EvidenceUploadGrantRequest,
): string {
  return (
    `evidence-upload-v1:${request.acaoId}:` +
    `${request.evidenciaId}:${request.sha256}`
  );
}
