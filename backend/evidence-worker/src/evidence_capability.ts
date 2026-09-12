import type { EvidenceUploadGrantRequest } from "./evidence_contract";

export interface EvidenceUploadCapabilityClaims {
  v: 1;
  purpose: "evidence-upload";
  callerUid: string;
  autorUserId: string;
  acaoId: string;
  evidenciaId: string;
  contentType: "image/jpeg";
  tamanhoBytes: number;
  sha256: string;
  objectKey: string;
  issuedAt: number;
  expiresAt: number;
}

export class EvidenceCapabilityError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "EvidenceCapabilityError";
  }
}

function base64UrlEncode(bytes: Uint8Array): string {
  let binary = "";

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

function base64UrlDecode(value: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]+$/.test(value)) {
    throw new EvidenceCapabilityError(
      "invalid_token_encoding",
      "Capability possui codificacao invalida.",
    );
  }

  const padding =
    value.length % 4 === 0
      ? ""
      : "=".repeat(4 - (value.length % 4));

  const normalized = value
    .replace(/-/g, "+")
    .replace(/_/g, "/") + padding;

  let binary: string;

  try {
    binary = atob(normalized);
  } catch {
    throw new EvidenceCapabilityError(
      "invalid_token_encoding",
      "Capability possui codificacao invalida.",
    );
  }

  return Uint8Array.from(
    binary,
    (character) => character.charCodeAt(0),
  );
}

function toArrayBuffer(
  bytes: Uint8Array<ArrayBufferLike>,
): ArrayBuffer {
  const buffer = new ArrayBuffer(bytes.byteLength);
  new Uint8Array(buffer).set(bytes);
  return buffer;
}

function encodeText(value: string): Uint8Array {
  return new TextEncoder().encode(value);
}

function decodeText(value: Uint8Array): string {
  return new TextDecoder(
    "utf-8",
    { fatal: true },
  ).decode(value);
}

function canonicalClaimsJson(
  claims: EvidenceUploadCapabilityClaims,
): string {
  return JSON.stringify({
    v: claims.v,
    purpose: claims.purpose,
    callerUid: claims.callerUid,
    autorUserId: claims.autorUserId,
    acaoId: claims.acaoId,
    evidenciaId: claims.evidenciaId,
    contentType: claims.contentType,
    tamanhoBytes: claims.tamanhoBytes,
    sha256: claims.sha256,
    objectKey: claims.objectKey,
    issuedAt: claims.issuedAt,
    expiresAt: claims.expiresAt,
  });
}

export async function importEvidenceCapabilityKey(
  rawKey: Uint8Array,
): Promise<CryptoKey> {
  if (rawKey.byteLength < 32) {
    throw new EvidenceCapabilityError(
      "weak_key",
      "Chave HMAC deve possuir pelo menos 32 bytes.",
    );
  }

  return crypto.subtle.importKey(
    "raw",
    toArrayBuffer(rawKey),
    {
      name: "HMAC",
      hash: "SHA-256",
    },
    false,
    ["sign", "verify"],
  );
}

export function buildEvidenceUploadCapabilityClaims(
  request: EvidenceUploadGrantRequest,
  callerUid: string,
  objectKey: string,
  issuedAt: Date,
  expiresAt: Date,
): EvidenceUploadCapabilityClaims {
  const caller = callerUid.trim();
  const key = objectKey.trim();
  const issued = Math.floor(issuedAt.getTime() / 1000);
  const expires = Math.floor(expiresAt.getTime() / 1000);

  if (caller.length === 0) {
    throw new EvidenceCapabilityError(
      "invalid_caller",
      "callerUid obrigatorio.",
    );
  }

  if (key.length === 0) {
    throw new EvidenceCapabilityError(
      "invalid_object_key",
      "objectKey obrigatoria.",
    );
  }

  if (
    !Number.isSafeInteger(issued) ||
    !Number.isSafeInteger(expires) ||
    expires <= issued
  ) {
    throw new EvidenceCapabilityError(
      "invalid_expiration",
      "Expiracao deve ser posterior a emissao.",
    );
  }

  return {
    v: 1,
    purpose: "evidence-upload",
    callerUid: caller,
    autorUserId: request.autorUserId,
    acaoId: request.acaoId,
    evidenciaId: request.evidenciaId,
    contentType: request.contentType,
    tamanhoBytes: request.tamanhoBytes,
    sha256: request.sha256,
    objectKey: key,
    issuedAt: issued,
    expiresAt: expires,
  };
}

export async function issueEvidenceUploadCapability(
  claims: EvidenceUploadCapabilityClaims,
  key: CryptoKey,
): Promise<string> {
  const payload = base64UrlEncode(
    encodeText(canonicalClaimsJson(claims)),
  );

  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    toArrayBuffer(encodeText(payload)),
  );

  return `${payload}.${base64UrlEncode(new Uint8Array(signature))}`;
}

function isClaims(
  value: unknown,
): value is EvidenceUploadCapabilityClaims {
  if (
    typeof value !== "object" ||
    value === null ||
    Array.isArray(value)
  ) {
    return false;
  }

  const claims = value as Record<string, unknown>;

  return (
    claims.v === 1 &&
    claims.purpose === "evidence-upload" &&
    typeof claims.callerUid === "string" &&
    claims.callerUid.trim().length > 0 &&
    typeof claims.autorUserId === "string" &&
    claims.autorUserId.trim().length > 0 &&
    typeof claims.acaoId === "string" &&
    claims.acaoId.trim().length > 0 &&
    typeof claims.evidenciaId === "string" &&
    claims.evidenciaId.trim().length > 0 &&
    claims.contentType === "image/jpeg" &&
    typeof claims.tamanhoBytes === "number" &&
    Number.isSafeInteger(claims.tamanhoBytes) &&
    claims.tamanhoBytes > 0 &&
    typeof claims.sha256 === "string" &&
    /^[a-f0-9]{64}$/.test(claims.sha256) &&
    typeof claims.objectKey === "string" &&
    claims.objectKey.trim().length > 0 &&
    typeof claims.issuedAt === "number" &&
    Number.isSafeInteger(claims.issuedAt) &&
    typeof claims.expiresAt === "number" &&
    Number.isSafeInteger(claims.expiresAt) &&
    claims.expiresAt > claims.issuedAt
  );
}

export async function verifyEvidenceUploadCapability(
  token: string,
  key: CryptoKey,
  now: Date,
): Promise<EvidenceUploadCapabilityClaims> {
  const parts = token.split(".");

  if (parts.length !== 2) {
    throw new EvidenceCapabilityError(
      "invalid_token",
      "Capability malformada.",
    );
  }

  const [payload, signatureEncoded] = parts;
  const signature = base64UrlDecode(signatureEncoded);

  const validSignature = await crypto.subtle.verify(
    "HMAC",
    key,
    toArrayBuffer(signature),
    toArrayBuffer(encodeText(payload)),
  );

  if (!validSignature) {
    throw new EvidenceCapabilityError(
      "invalid_signature",
      "Assinatura da capability invalida.",
    );
  }

  let parsed: unknown;

  try {
    parsed = JSON.parse(
      decodeText(base64UrlDecode(payload)),
    );
  } catch {
    throw new EvidenceCapabilityError(
      "invalid_claims",
      "Claims da capability invalidas.",
    );
  }

  if (!isClaims(parsed)) {
    throw new EvidenceCapabilityError(
      "invalid_claims",
      "Claims da capability invalidas.",
    );
  }

  const nowSeconds = Math.floor(now.getTime() / 1000);

  if (nowSeconds >= parsed.expiresAt) {
    throw new EvidenceCapabilityError(
      "expired",
      "Capability expirada.",
    );
  }

  return parsed;
}
