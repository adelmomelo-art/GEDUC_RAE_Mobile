import {
  EvidenceCapabilityError,
  type EvidenceUploadCapabilityClaims,
  verifyEvidenceUploadCapability,
} from "./evidence_capability";
import {
  buildEvidenceIdempotencyKey,
  buildEvidenceObjectKey,
  maximumEvidenceUploadBytes,
  parseEvidenceUploadGrantRequest,
} from "./evidence_contract";

export interface ValidatedEvidenceUpload {
  claims: EvidenceUploadCapabilityClaims;
  bytes: ArrayBuffer;
  sha256: string;
}

export interface EvidenceUploadValidator {
  validate(
    capability: string,
    request: Request,
  ): Promise<ValidatedEvidenceUpload>;
}

export class EvidenceUploadValidationError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "EvidenceUploadValidationError";
  }
}

export interface HmacEvidenceUploadValidatorOptions {
  capabilityKey: CryptoKey;
  now?: () => Date;
}

function invalidCapability(): EvidenceUploadValidationError {
  return new EvidenceUploadValidationError(
    "invalid_capability",
    "Capability de upload invalida.",
  );
}

function canonicalRequestFromClaims(
  claims: EvidenceUploadCapabilityClaims,
) {
  try {
    return parseEvidenceUploadGrantRequest({
      acaoId: claims.acaoId,
      evidenciaId: claims.evidenciaId,
      autorUserId: claims.autorUserId,
      contentType: claims.contentType,
      tamanhoBytes: claims.tamanhoBytes,
      sha256: claims.sha256,
    });
  } catch {
    throw invalidCapability();
  }
}

function validateHeaders(
  request: Request,
  claims: EvidenceUploadCapabilityClaims,
  expectedIdempotencyKey: string,
): void {
  const contentType = request.headers.get("content-type");

  if (contentType !== claims.contentType) {
    throw new EvidenceUploadValidationError(
      "unsupported_content_type",
      "Content-Type diverge da capability.",
    );
  }

  const idempotencyKey = request.headers.get(
    "x-fenix-idempotency-key",
  );

  if (idempotencyKey === null || idempotencyKey.length === 0) {
    throw new EvidenceUploadValidationError(
      "missing_idempotency_key",
      "X-Fenix-Idempotency-Key obrigatoria.",
    );
  }

  if (idempotencyKey !== expectedIdempotencyKey) {
    throw new EvidenceUploadValidationError(
      "idempotency_mismatch",
      "Chave de idempotencia diverge da capability.",
    );
  }

  const contentEncoding = request.headers.get("content-encoding");

  if (
    contentEncoding !== null &&
    contentEncoding.trim().toLowerCase() !== "identity"
  ) {
    throw new EvidenceUploadValidationError(
      "content_encoding_not_allowed",
      "Content-Encoding nao permitido para evidencia.",
    );
  }

  if (request.headers.has("content-range")) {
    throw new EvidenceUploadValidationError(
      "content_range_not_allowed",
      "Upload parcial nao permitido.",
    );
  }

  const contentLength = request.headers.get("content-length");

  if (contentLength === null) {
    return;
  }

  if (!/^[1-9][0-9]*$/.test(contentLength)) {
    throw new EvidenceUploadValidationError(
      "invalid_content_length",
      "Content-Length invalido.",
    );
  }

  const declaredLength = Number(contentLength);

  if (!Number.isSafeInteger(declaredLength)) {
    throw new EvidenceUploadValidationError(
      "invalid_content_length",
      "Content-Length invalido.",
    );
  }

  if (declaredLength > maximumEvidenceUploadBytes) {
    throw new EvidenceUploadValidationError(
      "payload_too_large",
      "Corpo excede o limite de bytes permitido.",
    );
  }

  if (declaredLength !== claims.tamanhoBytes) {
    throw new EvidenceUploadValidationError(
      "size_mismatch",
      "Content-Length diverge da capability.",
    );
  }
}

async function readExactBody(
  request: Request,
  expectedBytes: number,
): Promise<ArrayBuffer> {
  if (expectedBytes > maximumEvidenceUploadBytes) {
    throw new EvidenceUploadValidationError(
      "payload_too_large",
      "Corpo excede o limite de bytes permitido.",
    );
  }

  if (request.body === null) {
    throw new EvidenceUploadValidationError(
      "missing_body",
      "Corpo da evidencia obrigatorio.",
    );
  }

  const buffer = new ArrayBuffer(expectedBytes);
  const bytes = new Uint8Array(buffer);
  const reader = request.body.getReader();
  let offset = 0;

  try {
    while (true) {
      const chunk = await reader.read();

      if (chunk.done) {
        break;
      }

      if (offset + chunk.value.byteLength > expectedBytes) {
        await reader.cancel();
        throw new EvidenceUploadValidationError(
          "size_mismatch",
          "Corpo possui mais bytes que o autorizado.",
        );
      }

      bytes.set(chunk.value, offset);
      offset += chunk.value.byteLength;
    }
  } catch (error) {
    if (error instanceof EvidenceUploadValidationError) {
      throw error;
    }

    throw new EvidenceUploadValidationError(
      "body_read_failed",
      "Falha ao ler corpo da evidencia.",
    );
  } finally {
    reader.releaseLock();
  }

  if (offset !== expectedBytes) {
    throw new EvidenceUploadValidationError(
      "size_mismatch",
      "Corpo possui menos bytes que o autorizado.",
    );
  }

  return buffer;
}

async function sha256Hex(bytes: ArrayBuffer): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", bytes);

  return Array.from(
    new Uint8Array(digest),
    (value) => value.toString(16).padStart(2, "0"),
  ).join("");
}

function validateJpegSignature(bytes: ArrayBuffer): void {
  const view = new Uint8Array(bytes);

  if (
    view.byteLength < 5 ||
    view[0] !== 0xff ||
    view[1] !== 0xd8 ||
    view[2] !== 0xff ||
    view[view.byteLength - 2] !== 0xff ||
    view[view.byteLength - 1] !== 0xd9
  ) {
    throw new EvidenceUploadValidationError(
      "invalid_jpeg_signature",
      "Bytes recebidos nao possuem assinatura JPEG valida.",
    );
  }
}

export class HmacEvidenceUploadValidator
  implements EvidenceUploadValidator {
  private readonly capabilityKey: CryptoKey;
  private readonly now: () => Date;

  constructor(options: HmacEvidenceUploadValidatorOptions) {
    this.capabilityKey = options.capabilityKey;
    this.now = options.now ?? (() => new Date());
  }

  async validate(
    capability: string,
    request: Request,
  ): Promise<ValidatedEvidenceUpload> {
    let claims: EvidenceUploadCapabilityClaims;

    try {
      claims = await verifyEvidenceUploadCapability(
        capability,
        this.capabilityKey,
        this.now(),
      );
    } catch (error) {
      if (
        error instanceof EvidenceCapabilityError &&
        error.code === "expired"
      ) {
        throw new EvidenceUploadValidationError(
          "expired_capability",
          "Capability de upload expirada.",
        );
      }

      throw invalidCapability();
    }

    const canonicalRequest = canonicalRequestFromClaims(claims);
    const expectedObjectKey = buildEvidenceObjectKey(canonicalRequest);

    if (claims.objectKey !== expectedObjectKey) {
      throw invalidCapability();
    }

    const expectedIdempotencyKey = buildEvidenceIdempotencyKey(
      canonicalRequest,
    );

    validateHeaders(request, claims, expectedIdempotencyKey);

    const bytes = await readExactBody(
      request,
      claims.tamanhoBytes,
    );

    validateJpegSignature(bytes);

    const actualSha256 = await sha256Hex(bytes);

    if (actualSha256 !== claims.sha256) {
      throw new EvidenceUploadValidationError(
        "hash_mismatch",
        "SHA-256 real diverge da capability.",
      );
    }

    return {
      claims,
      bytes,
      sha256: actualSha256,
    };
  }
}
