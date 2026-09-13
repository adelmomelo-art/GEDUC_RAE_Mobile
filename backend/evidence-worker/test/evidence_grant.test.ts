import { describe, expect, it } from "vitest";
import {
  importEvidenceCapabilityKey,
  verifyEvidenceUploadCapability,
} from "../src/evidence_capability";
import {
  parseEvidenceUploadGrantRequest,
} from "../src/evidence_contract";
import {
  HmacEvidenceUploadGrantIssuer,
  type EvidenceAuthorBindingInput,
  type EvidenceAuthorBindingVerifier,
} from "../src/evidence_grant";

const now = new Date("2026-09-12T18:00:00.900Z");

function request() {
  return parseEvidenceUploadGrantRequest({
    acaoId: "acao-77",
    evidenciaId: "ev-99",
    autorUserId: "captor-77",
    contentType: "image/jpeg",
    tamanhoBytes: 9876,
    sha256: "a".repeat(64),
  });
}

async function key() {
  return importEvidenceCapabilityKey(
    new TextEncoder().encode("A".repeat(32)),
  );
}

class FakeAuthorBindingVerifier
  implements EvidenceAuthorBindingVerifier {
  allowed = true;
  shouldFail = false;
  lastInput: EvidenceAuthorBindingInput | null = null;

  async verify(input: EvidenceAuthorBindingInput) {
    this.lastInput = input;

    if (this.shouldFail) {
      throw new Error("fonte autoritativa indisponivel");
    }

    return this.allowed
      ? { allowed: true as const }
      : { allowed: false as const, code: "not_bound" };
  }
}

async function issuer(
  verifier = new FakeAuthorBindingVerifier(),
  options: { ttlSeconds?: number; publicBaseUrl?: string } = {},
) {
  return new HmacEvidenceUploadGrantIssuer({
    capabilityKey: await key(),
    authorBindingVerifier: verifier,
    publicBaseUrl:
      options.publicBaseUrl ?? "https://evidence.fenix.test",
    now: () => now,
    ttlSeconds: options.ttlSeconds,
  });
}

describe("SEC-R2-002A.6B - upload grant", () => {
  it("emite response compativel com EvidenceAccessGrant", async () => {
    const verifier = new FakeAuthorBindingVerifier();
    const grant = await (await issuer(verifier)).issue(
      request(),
      "uid-chamador-1",
    );

    expect(verifier.lastInput).toEqual({
      callerUid: "uid-chamador-1",
      autorUserId: "captor-77",
      acaoId: "acao-77",
      evidenciaId: "ev-99",
    });
    expect(grant.operation).toBe("upload");
    expect(grant.expiresAt).toBe("2026-09-12T18:05:00.000Z");
    expect(grant.objectKey).toBe(
      `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
    );
    expect(grant.requiredHeaders).toEqual({
      "Content-Type": "image/jpeg",
      "X-Fenix-Idempotency-Key":
        `evidence-upload-v1:acao-77:ev-99:${"a".repeat(64)}`,
    });
    expect(grant.uploadIdentity).toEqual({
      acaoId: "acao-77",
      evidenciaId: "ev-99",
      sha256: "a".repeat(64),
    });
    expect(new URL(grant.uri).protocol).toBe("https:");
  });

  it("assina capability vinculando caller e autor distintos", async () => {
    const signingKey = await key();
    const grantIssuer = new HmacEvidenceUploadGrantIssuer({
      capabilityKey: signingKey,
      authorBindingVerifier: new FakeAuthorBindingVerifier(),
      publicBaseUrl: "https://evidence.fenix.test",
      now: () => now,
      ttlSeconds: 120,
    });

    const grant = await grantIssuer.issue(
      request(),
      "uid-chamador-1",
    );
    const capability = new URL(grant.uri).pathname.split("/").at(-1)!;
    const claims = await verifyEvidenceUploadCapability(
      capability,
      signingKey,
      new Date("2026-09-12T18:01:59.000Z"),
    );

    expect(claims.callerUid).toBe("uid-chamador-1");
    expect(claims.autorUserId).toBe("captor-77");
    expect(claims.objectKey).toBe(grant.objectKey);
    expect(claims.issuedAt).toBe(1789236000);
    expect(claims.expiresAt).toBe(1789236120);
  });

  it("nega autor sem vinculo autoritativo", async () => {
    const verifier = new FakeAuthorBindingVerifier();
    verifier.allowed = false;

    await expect(
      (await issuer(verifier)).issue(request(), "uid-chamador-1"),
    ).rejects.toMatchObject({
      code: "author_binding_denied",
    });
  });

  it("falha fechado quando fonte autoritativa fica indisponivel", async () => {
    const verifier = new FakeAuthorBindingVerifier();
    verifier.shouldFail = true;

    await expect(
      (await issuer(verifier)).issue(request(), "uid-chamador-1"),
    ).rejects.toMatchObject({
      code: "author_verification_unavailable",
    });
  });

  it("rejeita caller vazio", async () => {
    await expect(
      (await issuer()).issue(request(), "   "),
    ).rejects.toMatchObject({
      code: "invalid_caller",
    });
  });

  it("rejeita origem publica sem HTTPS", async () => {
    await expect(
      issuer(
        new FakeAuthorBindingVerifier(),
        { publicBaseUrl: "http://evidence.fenix.test" },
      ),
    ).rejects.toMatchObject({
      code: "invalid_grant_configuration",
    });
  });

  it("rejeita TTL superior a cinco minutos", async () => {
    await expect(
      issuer(
        new FakeAuthorBindingVerifier(),
        { ttlSeconds: 301 },
      ),
    ).rejects.toMatchObject({
      code: "invalid_grant_configuration",
    });
  });

  it("rejeita relogio invalido", async () => {
    const grantIssuer = new HmacEvidenceUploadGrantIssuer({
      capabilityKey: await key(),
      authorBindingVerifier: new FakeAuthorBindingVerifier(),
      publicBaseUrl: "https://evidence.fenix.test",
      now: () => new Date(Number.NaN),
    });

    await expect(
      grantIssuer.issue(request(), "uid-chamador-1"),
    ).rejects.toMatchObject({
      code: "invalid_clock",
    });
  });
});
