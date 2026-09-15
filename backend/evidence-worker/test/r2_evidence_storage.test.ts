import { describe, expect, it } from "vitest";
import type {
  EvidencePrivateObjectMetadata,
  EvidencePrivateStorageCreateInput,
} from "../src/evidence_persistence";
import {
  createR2EvidenceUploadPersister,
  R2EvidencePrivateStorageAdapter,
  type R2EvidenceBucketBinding,
  type R2EvidenceObject,
  type R2EvidencePutOptions,
} from "../src/r2_evidence_storage";

const sha256 = "a".repeat(64);
const objectKey = `evidencias/v1/acao-77/ev-99/${sha256}.jpg`;
const idempotencyKey =
  `evidence-upload-v1:acao-77:ev-99:${sha256}`;

function checksum(value = sha256): ArrayBuffer {
  const bytes = new Uint8Array(value.length / 2);

  for (let index = 0; index < value.length; index += 2) {
    bytes[index / 2] = Number.parseInt(
      value.substring(index, index + 2),
      16,
    );
  }

  return bytes.buffer;
}

function metadata(): EvidencePrivateObjectMetadata {
  return {
    objectKey,
    acaoId: "acao-77",
    evidenciaId: "ev-99",
    autorUserId: "captor-77",
    contentType: "image/jpeg",
    tamanhoBytes: 12,
    sha256,
    idempotencyKey,
  };
}

function input(): EvidencePrivateStorageCreateInput {
  return {
    metadata: metadata(),
    requestedByCallerUid: "uid-chamador-1",
    bytes: new ArrayBuffer(12),
  };
}

function storedObject(
  overrides: Partial<R2EvidenceObject> = {},
): R2EvidenceObject {
  return {
    key: objectKey,
    size: 12,
    httpMetadata: {
      contentType: "image/jpeg",
    },
    customMetadata: {
      fenixSchema: "fenix-evidence-private-v1",
      acaoId: "acao-77",
      evidenciaId: "ev-99",
      autorUserId: "captor-77",
      contentType: "image/jpeg",
      tamanhoBytes: "12",
      sha256,
      idempotencyKey,
      requestedByCallerUid: "uid-chamador-1",
    },
    checksums: {
      sha256: checksum(),
    },
    ...overrides,
  };
}

class FakeR2Bucket implements R2EvidenceBucketBinding {
  putResult: R2EvidenceObject | null = storedObject();
  headResult: R2EvidenceObject | null = storedObject();
  putError: Error | null = null;
  headError: Error | null = null;
  calls: string[] = [];
  lastKey: string | null = null;
  lastBytes: ArrayBuffer | null = null;
  lastOptions: R2EvidencePutOptions | null = null;

  async put(
    key: string,
    value: ArrayBuffer,
    options: R2EvidencePutOptions,
  ): Promise<R2EvidenceObject | null> {
    this.calls.push("put");
    this.lastKey = key;
    this.lastBytes = value;
    this.lastOptions = options;

    if (this.putError !== null) {
      throw this.putError;
    }

    return this.putResult;
  }

  async head(key: string): Promise<R2EvidenceObject | null> {
    this.calls.push("head");
    this.lastKey = key;

    if (this.headError !== null) {
      throw this.headError;
    }

    return this.headResult;
  }
}

describe("SEC-R2-002A.6E - adapter Cloudflare R2", () => {
  it("cria com PUT condicional atomico e checksum SHA-256", async () => {
    const bucket = new FakeR2Bucket();
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);
    const current = input();

    await expect(adapter.createIfAbsent(current)).resolves.toEqual({
      status: "created",
    });

    expect(bucket.calls).toEqual(["put"]);
    expect(bucket.lastKey).toBe(objectKey);
    expect(bucket.lastBytes).toBe(current.bytes);
    expect(bucket.lastOptions).toEqual({
      onlyIf: {
        etagDoesNotMatch: "*",
      },
      httpMetadata: {
        contentType: "image/jpeg",
      },
      customMetadata: {
        fenixSchema: "fenix-evidence-private-v1",
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: "12",
        sha256,
        idempotencyKey,
        requestedByCallerUid: "uid-chamador-1",
      },
      sha256,
    });
  });

  it("consulta metadata somente apos precondicao de criacao falhar", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putResult = null;
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).resolves.toEqual({
      status: "already_exists",
      object: metadata(),
    });
    expect(bucket.calls).toEqual(["put", "head"]);
  });

  it("retorna conflito para metadata existente nao canonica", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putResult = null;
    bucket.headResult = storedObject({
      customMetadata: {
        ...storedObject().customMetadata!,
        evidenciaId: "outra-evidencia",
      },
    });
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).resolves.toEqual({
      status: "conflict",
    });
  });

  it("retorna conflito quando checksum R2 diverge", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putResult = null;
    bucket.headResult = storedObject({
      checksums: {
        sha256: checksum("b".repeat(64)),
      },
    });
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).resolves.toEqual({
      status: "conflict",
    });
  });

  it("retorna conflito quando tamanho fisico diverge", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putResult = null;
    bucket.headResult = storedObject({
      size: 13,
    });
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).resolves.toEqual({
      status: "conflict",
    });
  });

  it("falha fechado se objeto some apos precondicao", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putResult = null;
    bucket.headResult = null;
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).rejects.toMatchObject({
      code: "precondition_state_unavailable",
    });
    expect(bucket.calls).toEqual(["put", "head"]);
  });

  it("falha fechado para resposta de criacao inconsistente", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putResult = storedObject({
      size: 13,
    });
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).rejects.toMatchObject({
      code: "invalid_created_object",
    });
    expect(bucket.calls).toEqual(["put"]);
  });

  it("propaga falha R2 para conversao generica pela camada superior", async () => {
    const bucket = new FakeR2Bucket();
    bucket.putError = new Error("detalhe interno Cloudflare");
    const adapter = new R2EvidencePrivateStorageAdapter(bucket);

    await expect(adapter.createIfAbsent(input())).rejects.toThrow(
      "detalhe interno Cloudflare",
    );
  });

  it("wiring permanece ausente sem binding", () => {
    expect(createR2EvidenceUploadPersister({})).toBeUndefined();
  });

  it("wiring cria persister somente quando binding e injetado", () => {
    const bucket = new FakeR2Bucket();

    expect(
      createR2EvidenceUploadPersister({
        EVIDENCE_BUCKET: bucket,
      }),
    ).toBeDefined();
    expect(bucket.calls).toEqual([]);
  });
});
