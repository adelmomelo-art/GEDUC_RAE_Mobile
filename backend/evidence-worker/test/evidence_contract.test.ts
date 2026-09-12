import { describe, expect, it } from "vitest";
import {
  buildEvidenceIdempotencyKey,
  buildEvidenceObjectKey,
  EvidenceContractError,
  parseEvidenceUploadGrantRequest,
} from "../src/evidence_contract";

const sha = "a".repeat(64);

function validRequest(
  overrides: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    acaoId: "acao-77",
    evidenciaId: "ev-99",
    autorUserId: "captor-77",
    contentType: "image/jpeg",
    tamanhoBytes: 9876,
    sha256: sha,
    ...overrides,
  };
}

function contractError(input: unknown): EvidenceContractError {
  try {
    parseEvidenceUploadGrantRequest(input);
  } catch (error) {
    expect(error).toBeInstanceOf(EvidenceContractError);
    return error as EvidenceContractError;
  }

  throw new Error("Era esperado EvidenceContractError.");
}

describe("SEC-R2-002A.3 - evidence contract", () => {
  it("aceita request valido e normaliza identificadores", () => {
    const request = parseEvidenceUploadGrantRequest(
      validRequest({
        acaoId: "  acao-77  ",
        evidenciaId: " ev-99 ",
        autorUserId: " captor-77 ",
      }),
    );

    expect(request).toEqual({
      acaoId: "acao-77",
      evidenciaId: "ev-99",
      autorUserId: "captor-77",
      contentType: "image/jpeg",
      tamanhoBytes: 9876,
      sha256: sha,
    });
  });

  it("gera objectKey e idempotencyKey deterministicas", () => {
    const request = parseEvidenceUploadGrantRequest(validRequest());

    expect(buildEvidenceObjectKey(request)).toBe(
      `evidencias/v1/acao-77/ev-99/${sha}.jpg`,
    );

    expect(buildEvidenceIdempotencyKey(request)).toBe(
      `evidence-upload-v1:acao-77:ev-99:${sha}`,
    );
  });

  it("rejeita objectKey enviada pelo cliente", () => {
    const error = contractError(
      validRequest({
        objectKey: "evidencias/forjada.jpg",
      }),
    );

    expect(error.code).toBe("unexpected_field");
  });

  it("rejeita path traversal em identificadores", () => {
    const error = contractError(
      validRequest({
        acaoId: "../acao-77",
      }),
    );

    expect(error.code).toBe("unsafe_identifier");
  });

  it("rejeita SHA-256 fora do formato canonico", () => {
    const error = contractError(
      validRequest({
        sha256: "A".repeat(64),
      }),
    );

    expect(error.code).toBe("invalid_sha256");
  });

  it("rejeita MIME diferente do artefato preparado JPEG", () => {
    const error = contractError(
      validRequest({
        contentType: "image/png",
      }),
    );

    expect(error.code).toBe("unsupported_content_type");
  });

  it("rejeita tamanho nao positivo", () => {
    const error = contractError(
      validRequest({
        tamanhoBytes: 0,
      }),
    );

    expect(error.code).toBe("invalid_size");
  });

  it("rejeita autorUserId vazio", () => {
    const error = contractError(
      validRequest({
        autorUserId: "   ",
      }),
    );

    expect(error.code).toBe("invalid_field");
  });
});
