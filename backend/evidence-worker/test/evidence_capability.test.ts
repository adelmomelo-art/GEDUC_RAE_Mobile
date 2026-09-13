import { describe, expect, it } from "vitest";
import {
  buildEvidenceUploadCapabilityClaims,
  importEvidenceCapabilityKey,
  issueEvidenceUploadCapability,
  verifyEvidenceUploadCapability,
} from "../src/evidence_capability";
import {
  parseEvidenceUploadGrantRequest,
} from "../src/evidence_contract";

const now = new Date("2026-09-12T18:00:00.000Z");
const expires = new Date("2026-09-12T18:05:00.000Z");

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

async function key(seed = "A") {
  return importEvidenceCapabilityKey(
    new TextEncoder().encode(seed.repeat(32)),
  );
}

describe("SEC-R2-002A.6 - upload capability", () => {
  it("monta claims vinculando caller e autor separadamente", () => {
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
      now,
      expires,
    );

    expect(claims.callerUid).toBe("uid-chamador-1");
    expect(claims.autorUserId).toBe("captor-77");
    expect(claims.acaoId).toBe("acao-77");
    expect(claims.evidenciaId).toBe("ev-99");
    expect(claims.tamanhoBytes).toBe(9876);
    expect(claims.contentType).toBe("image/jpeg");
  });

  it("emite e valida capability HMAC-SHA256", async () => {
    const signingKey = await key();
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
      now,
      expires,
    );

    const token = await issueEvidenceUploadCapability(
      claims,
      signingKey,
    );

    expect(token.split(".")).toHaveLength(2);

    await expect(
      verifyEvidenceUploadCapability(
        token,
        signingKey,
        new Date("2026-09-12T18:04:59.000Z"),
      ),
    ).resolves.toEqual(claims);
  });

  it("rejeita token adulterado", async () => {
    const signingKey = await key();
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      "evidencias/v1/acao-77/ev-99/hash.jpg",
      now,
      expires,
    );

    const token = await issueEvidenceUploadCapability(
      claims,
      signingKey,
    );

    const [payload, signature] = token.split(".");
    const first = payload[0] === "A" ? "B" : "A";
    const adulterado = `${first}${payload.slice(1)}.${signature}`;

    await expect(
      verifyEvidenceUploadCapability(
        adulterado,
        signingKey,
        now,
      ),
    ).rejects.toMatchObject({
      code: "invalid_signature",
    });
  });

  it("rejeita assinatura produzida por outra chave", async () => {
    const keyA = await key("A");
    const keyB = await key("B");
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      "evidencias/v1/acao-77/ev-99/hash.jpg",
      now,
      expires,
    );

    const token = await issueEvidenceUploadCapability(claims, keyA);

    await expect(
      verifyEvidenceUploadCapability(token, keyB, now),
    ).rejects.toMatchObject({
      code: "invalid_signature",
    });
  });

  it("rejeita capability expirada", async () => {
    const signingKey = await key();
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      "evidencias/v1/acao-77/ev-99/hash.jpg",
      now,
      expires,
    );

    const token = await issueEvidenceUploadCapability(
      claims,
      signingKey,
    );

    await expect(
      verifyEvidenceUploadCapability(
        token,
        signingKey,
        expires,
      ),
    ).rejects.toMatchObject({
      code: "expired",
    });
  });

  it("rejeita capability emitida no futuro", async () => {
    const signingKey = await key();
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
      new Date("2026-09-12T18:01:00.000Z"),
      new Date("2026-09-12T18:02:00.000Z"),
    );
    const token = await issueEvidenceUploadCapability(
      claims,
      signingKey,
    );

    await expect(
      verifyEvidenceUploadCapability(token, signingKey, now),
    ).rejects.toMatchObject({
      code: "not_yet_valid",
    });
  });

  it("rejeita capability com TTL superior a cinco minutos", async () => {
    const signingKey = await key();
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
      now,
      new Date("2026-09-12T18:05:01.000Z"),
    );
    const token = await issueEvidenceUploadCapability(
      claims,
      signingKey,
    );

    await expect(
      verifyEvidenceUploadCapability(token, signingKey, now),
    ).rejects.toMatchObject({
      code: "invalid_claims",
    });
  });

  it("rejeita relogio de validacao invalido", async () => {
    const signingKey = await key();
    const claims = buildEvidenceUploadCapabilityClaims(
      request(),
      "uid-chamador-1",
      `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
      now,
      expires,
    );
    const token = await issueEvidenceUploadCapability(
      claims,
      signingKey,
    );

    await expect(
      verifyEvidenceUploadCapability(
        token,
        signingKey,
        new Date(Number.NaN),
      ),
    ).rejects.toMatchObject({
      code: "invalid_clock",
    });
  });

  it("rejeita expiracao anterior ou igual a emissao", () => {
    expect(() =>
      buildEvidenceUploadCapabilityClaims(
        request(),
        "uid-chamador-1",
        "evidencias/v1/acao-77/ev-99/hash.jpg",
        now,
        now,
      ),
    ).toThrowError(expect.objectContaining({
      code: "invalid_expiration",
    }));
  });

  it("rejeita chave HMAC menor que 256 bits", async () => {
    await expect(
      importEvidenceCapabilityKey(
        new TextEncoder().encode("curta"),
      ),
    ).rejects.toMatchObject({
      code: "weak_key",
    });
  });
});
