import { describe, expect, it } from "vitest";
import {
  buildEvidenceUploadCapabilityClaims,
  importEvidenceCapabilityKey,
  issueEvidenceUploadCapability,
} from "../src/evidence_capability";
import {
  buildEvidenceIdempotencyKey,
  buildEvidenceObjectKey,
  parseEvidenceUploadGrantRequest,
} from "../src/evidence_contract";
import {
  HmacEvidenceUploadValidator,
} from "../src/evidence_upload";

const issuedAt = new Date("2026-09-13T02:00:00.000Z");
const expiresAt = new Date("2026-09-13T02:05:00.000Z");
const validationTime = new Date("2026-09-13T02:04:59.000Z");
const jpegBytes = Uint8Array.from([
  0xff,
  0xd8,
  0xff,
  0xe0,
  0x00,
  0x10,
  0x4a,
  0x46,
  0x49,
  0x46,
  0xff,
  0xd9,
]);

async function sha256Hex(bytes: Uint8Array): Promise<string> {
  const buffer = new ArrayBuffer(bytes.byteLength);
  new Uint8Array(buffer).set(bytes);
  const digest = await crypto.subtle.digest("SHA-256", buffer);

  return Array.from(
    new Uint8Array(digest),
    (value) => value.toString(16).padStart(2, "0"),
  ).join("");
}

async function key(seed = "A"): Promise<CryptoKey> {
  return importEvidenceCapabilityKey(
    new TextEncoder().encode(seed.repeat(32)),
  );
}

async function fixture() {
  const signingKey = await key();
  const sha256 = await sha256Hex(jpegBytes);
  const uploadRequest = parseEvidenceUploadGrantRequest({
    acaoId: "acao-77",
    evidenciaId: "ev-99",
    autorUserId: "captor-77",
    contentType: "image/jpeg",
    tamanhoBytes: jpegBytes.byteLength,
    sha256,
  });
  const objectKey = buildEvidenceObjectKey(uploadRequest);
  const claims = buildEvidenceUploadCapabilityClaims(
    uploadRequest,
    "uid-chamador-1",
    objectKey,
    issuedAt,
    expiresAt,
  );
  const capability = await issueEvidenceUploadCapability(
    claims,
    signingKey,
  );
  const idempotencyKey = buildEvidenceIdempotencyKey(uploadRequest);
  const validator = new HmacEvidenceUploadValidator({
    capabilityKey: signingKey,
    now: () => validationTime,
  });

  return {
    capability,
    claims,
    idempotencyKey,
    signingKey,
    validator,
  };
}

function putRequest(
  body: Uint8Array = jpegBytes,
  headers: Record<string, string> = {},
): Request {
  const buffer = new ArrayBuffer(body.byteLength);
  new Uint8Array(buffer).set(body);

  return new Request(
    "https://evidence.fenix.test/v1/evidencias/upload/token",
    {
      method: "PUT",
      headers,
      body: buffer,
    },
  );
}

describe("SEC-R2-002A.6C - validacao do PUT e bytes", () => {
  it("valida capability, headers, tamanho, JPEG e SHA-256 reais", async () => {
    const current = await fixture();
    const result = await current.validator.validate(
      current.capability,
      putRequest(jpegBytes, {
        "content-type": "image/jpeg",
        "content-length": String(jpegBytes.byteLength),
        "x-fenix-idempotency-key": current.idempotencyKey,
      }),
    );

    expect(result.claims.callerUid).toBe("uid-chamador-1");
    expect(result.claims.autorUserId).toBe("captor-77");
    expect(result.bytes.byteLength).toBe(jpegBytes.byteLength);
    expect(result.sha256).toBe(current.claims.sha256);
  });

  it("aceita ausencia de Content-Length e mede o stream real", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).resolves.toMatchObject({
      sha256: current.claims.sha256,
    });
  });

  it("rejeita capability adulterada", async () => {
    const current = await fixture();
    const first = current.capability[0] === "A" ? "B" : "A";

    await expect(
      current.validator.validate(
        `${first}${current.capability.slice(1)}`,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "invalid_capability" });
  });

  it("rejeita capability expirada", async () => {
    const current = await fixture();
    const validator = new HmacEvidenceUploadValidator({
      capabilityKey: current.signingKey,
      now: () => expiresAt,
    });

    await expect(
      validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "expired_capability" });
  });

  it("rejeita objectKey nao canonica mesmo quando assinada", async () => {
    const current = await fixture();
    const inconsistentClaims = {
      ...current.claims,
      objectKey: "evidencias/v1/forjada.jpg",
    };
    const capability = await issueEvidenceUploadCapability(
      inconsistentClaims,
      current.signingKey,
    );

    await expect(
      current.validator.validate(
        capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "invalid_capability" });
  });

  it("rejeita Content-Type divergente", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/png",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "unsupported_content_type" });
  });

  it("rejeita chave de idempotencia ausente", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
        }),
      ),
    ).rejects.toMatchObject({ code: "missing_idempotency_key" });
  });

  it("rejeita chave de idempotencia divergente", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": "forjada",
        }),
      ),
    ).rejects.toMatchObject({ code: "idempotency_mismatch" });
  });

  it("rejeita Content-Length divergente antes de consumir o corpo", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "content-length": String(jpegBytes.byteLength + 1),
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "size_mismatch" });
  });

  it("rejeita corpo maior que o tamanho assinado", async () => {
    const current = await fixture();
    const larger = Uint8Array.from([...jpegBytes, 0x00]);

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(larger, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "size_mismatch" });
  });

  it("rejeita corpo menor que o tamanho assinado", async () => {
    const current = await fixture();
    const shorter = jpegBytes.slice(0, -1);

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(shorter, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "size_mismatch" });
  });

  it("rejeita bytes sem assinatura JPEG", async () => {
    const current = await fixture();
    const invalidJpeg = Uint8Array.from(jpegBytes);
    invalidJpeg[0] = 0x00;
    const invalidHash = await sha256Hex(invalidJpeg);
    const canonicalRequest = parseEvidenceUploadGrantRequest({
      acaoId: current.claims.acaoId,
      evidenciaId: current.claims.evidenciaId,
      autorUserId: current.claims.autorUserId,
      contentType: current.claims.contentType,
      tamanhoBytes: invalidJpeg.byteLength,
      sha256: invalidHash,
    });
    const claims = buildEvidenceUploadCapabilityClaims(
      canonicalRequest,
      current.claims.callerUid,
      buildEvidenceObjectKey(canonicalRequest),
      issuedAt,
      expiresAt,
    );
    const capability = await issueEvidenceUploadCapability(
      claims,
      current.signingKey,
    );

    await expect(
      current.validator.validate(
        capability,
        putRequest(invalidJpeg, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": buildEvidenceIdempotencyKey(
            canonicalRequest,
          ),
        }),
      ),
    ).rejects.toMatchObject({ code: "invalid_jpeg_signature" });
  });

  it("rejeita SHA-256 real divergente", async () => {
    const current = await fixture();
    const differentJpeg = Uint8Array.from(jpegBytes);
    differentJpeg[5] = 0x11;

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(differentJpeg, {
          "content-type": "image/jpeg",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "hash_mismatch" });
  });

  it("rejeita codificacao de corpo que alteraria os bytes", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "content-encoding": "gzip",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "content_encoding_not_allowed" });
  });

  it("rejeita upload parcial por Content-Range", async () => {
    const current = await fixture();

    await expect(
      current.validator.validate(
        current.capability,
        putRequest(jpegBytes, {
          "content-type": "image/jpeg",
          "content-range": "bytes 0-11/12",
          "x-fenix-idempotency-key": current.idempotencyKey,
        }),
      ),
    ).rejects.toMatchObject({ code: "content_range_not_allowed" });
  });
});
