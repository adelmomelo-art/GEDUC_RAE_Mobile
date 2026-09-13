import {
  buildEvidenceUploadCapabilityClaims,
  issueEvidenceUploadCapability,
  maximumEvidenceCapabilityTtlSeconds,
} from "./evidence_capability";
import {
  buildEvidenceIdempotencyKey,
  buildEvidenceObjectKey,
  type EvidenceUploadGrantRequest,
} from "./evidence_contract";

export interface EvidenceAuthorBindingInput {
  callerUid: string;
  autorUserId: string;
  acaoId: string;
  evidenciaId: string;
}

export type EvidenceAuthorBindingDecision =
  | { allowed: true }
  | { allowed: false; code: string };

export interface EvidenceAuthorBindingVerifier {
  verify(
    input: EvidenceAuthorBindingInput,
  ): Promise<EvidenceAuthorBindingDecision>;
}

export interface EvidenceUploadGrant {
  uri: string;
  operation: "upload";
  expiresAt: string;
  objectKey: string;
  requiredHeaders: Record<string, string>;
  uploadIdentity: {
    acaoId: string;
    evidenciaId: string;
    sha256: string;
  };
}

export interface EvidenceUploadGrantIssuer {
  issue(
    request: EvidenceUploadGrantRequest,
    callerUid: string,
  ): Promise<EvidenceUploadGrant>;
}

export class EvidenceGrantError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "EvidenceGrantError";
  }
}

export interface HmacEvidenceUploadGrantIssuerOptions {
  capabilityKey: CryptoKey;
  authorBindingVerifier: EvidenceAuthorBindingVerifier;
  publicBaseUrl: string;
  now?: () => Date;
  ttlSeconds?: number;
}

function normalizePublicOrigin(value: string): string {
  let url: URL;

  try {
    url = new URL(value);
  } catch {
    throw new EvidenceGrantError(
      "invalid_grant_configuration",
      "Origem publica do Evidence Worker invalida.",
    );
  }

  if (
    url.protocol !== "https:" ||
    url.hostname.length === 0 ||
    url.username.length > 0 ||
    url.password.length > 0 ||
    url.search.length > 0 ||
    url.hash.length > 0 ||
    url.pathname !== "/"
  ) {
    throw new EvidenceGrantError(
      "invalid_grant_configuration",
      "Origem publica deve ser HTTPS e nao conter credenciais, path, query ou fragmento.",
    );
  }

  return url.origin;
}

function validateTtl(value: number): number {
  if (
    !Number.isSafeInteger(value) ||
    value <= 0 ||
    value > maximumEvidenceCapabilityTtlSeconds
  ) {
    throw new EvidenceGrantError(
      "invalid_grant_configuration",
      `TTL deve ser inteiro entre 1 e ${maximumEvidenceCapabilityTtlSeconds} segundos.`,
    );
  }

  return value;
}

export class HmacEvidenceUploadGrantIssuer
  implements EvidenceUploadGrantIssuer {
  private readonly capabilityKey: CryptoKey;
  private readonly authorBindingVerifier: EvidenceAuthorBindingVerifier;
  private readonly publicOrigin: string;
  private readonly now: () => Date;
  private readonly ttlSeconds: number;

  constructor(options: HmacEvidenceUploadGrantIssuerOptions) {
    this.capabilityKey = options.capabilityKey;
    this.authorBindingVerifier = options.authorBindingVerifier;
    this.publicOrigin = normalizePublicOrigin(options.publicBaseUrl);
    this.now = options.now ?? (() => new Date());
    this.ttlSeconds = validateTtl(
      options.ttlSeconds ?? maximumEvidenceCapabilityTtlSeconds,
    );
  }

  async issue(
    request: EvidenceUploadGrantRequest,
    callerUid: string,
  ): Promise<EvidenceUploadGrant> {
    const normalizedCallerUid = callerUid.trim();

    if (normalizedCallerUid.length === 0) {
      throw new EvidenceGrantError(
        "invalid_caller",
        "Caller autenticado obrigatorio para emissao do grant.",
      );
    }

    let authorDecision: EvidenceAuthorBindingDecision;

    try {
      authorDecision = await this.authorBindingVerifier.verify({
        callerUid: normalizedCallerUid,
        autorUserId: request.autorUserId,
        acaoId: request.acaoId,
        evidenciaId: request.evidenciaId,
      });
    } catch {
      throw new EvidenceGrantError(
        "author_verification_unavailable",
        "Validacao autoritativa do autor indisponivel.",
      );
    }

    if (!authorDecision.allowed) {
      throw new EvidenceGrantError(
        "author_binding_denied",
        "Autor da evidencia nao autorizado para o contexto informado.",
      );
    }

    const nowValue = this.now();
    const nowMilliseconds = nowValue.getTime();

    if (!Number.isFinite(nowMilliseconds)) {
      throw new EvidenceGrantError(
        "invalid_clock",
        "Relogio do emissor de grant invalido.",
      );
    }

    const issuedAt = new Date(
      Math.floor(nowMilliseconds / 1000) * 1000,
    );
    const expiresAt = new Date(
      issuedAt.getTime() + this.ttlSeconds * 1000,
    );
    const objectKey = buildEvidenceObjectKey(request);
    const idempotencyKey = buildEvidenceIdempotencyKey(request);
    const claims = buildEvidenceUploadCapabilityClaims(
      request,
      normalizedCallerUid,
      objectKey,
      issuedAt,
      expiresAt,
    );
    const capability = await issueEvidenceUploadCapability(
      claims,
      this.capabilityKey,
    );
    const uri = new URL(
      `/v1/evidencias/upload/${capability}`,
      this.publicOrigin,
    );

    return {
      uri: uri.toString(),
      operation: "upload",
      expiresAt: expiresAt.toISOString(),
      objectKey,
      requiredHeaders: {
        "Content-Type": request.contentType,
        "X-Fenix-Idempotency-Key": idempotencyKey,
      },
      uploadIdentity: {
        acaoId: request.acaoId,
        evidenciaId: request.evidenciaId,
        sha256: request.sha256,
      },
    };
  }
}
