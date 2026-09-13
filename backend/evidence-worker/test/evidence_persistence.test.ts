import { describe, expect, it } from "vitest";
import type { EvidenceUploadCapabilityClaims } from "../src/evidence_capability";
import {
  AtomicEvidenceUploadPersister,
  type EvidencePrivateObjectMetadata,
  type EvidencePrivateStorageCreateInput,
  type EvidencePrivateStorageCreateResult,
  type EvidencePrivateStoragePort,
} from "../src/evidence_persistence";
import type { ValidatedEvidenceUpload } from "../src/evidence_upload";

const sha256 = "a".repeat(64);
const objectKey = `evidencias/v1/acao-77/ev-99/${sha256}.jpg`;
const idempotencyKey =
  `evidence-upload-v1:acao-77:ev-99:${sha256}`;

function claims(): EvidenceUploadCapabilityClaims {
  return {
    v: 1,
    purpose: "evidence-upload",
    callerUid: "uid-chamador-1",
    autorUserId: "captor-77",
    acaoId: "acao-77",
    evidenciaId: "ev-99",
    contentType: "image/jpeg",
    tamanhoBytes: 12,
    sha256,
    objectKey,
    issuedAt: 1789264800,
    expiresAt: 1789265100,
  };
}

function upload(): ValidatedEvidenceUpload {
  return {
    claims: claims(),
    bytes: new ArrayBuffer(12),
    sha256,
  };
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

class FakePrivateStorage implements EvidencePrivateStoragePort {
  result: EvidencePrivateStorageCreateResult = {
    status: "created",
  };
  error: Error | null = null;
  lastInput: EvidencePrivateStorageCreateInput | null = null;
  calls = 0;

  async createIfAbsent(
    input: EvidencePrivateStorageCreateInput,
  ): Promise<EvidencePrivateStorageCreateResult> {
    this.calls += 1;
    this.lastInput = input;

    if (this.error !== null) {
      throw this.error;
    }

    return this.result;
  }
}

describe("SEC-R2-002A.6D - idempotencia e porta privada", () => {
  it("cria objeto sem sobrescrita e preserva caller e autor separados", async () => {
    const storage = new FakePrivateStorage();
    const persister = new AtomicEvidenceUploadPersister(storage);
    const current = upload();

    const result = await persister.persist(current);

    expect(result).toEqual({
      status: "created",
      objectKey,
      sha256,
      tamanhoBytes: 12,
    });
    expect(storage.calls).toBe(1);
    expect(storage.lastInput).toEqual({
      metadata: metadata(),
      requestedByCallerUid: "uid-chamador-1",
      bytes: current.bytes,
    });
    expect(storage.lastInput!.requestedByCallerUid).not.toBe(
      storage.lastInput!.metadata.autorUserId,
    );
  });

  it("trata objeto identico existente como sucesso idempotente", async () => {
    const storage = new FakePrivateStorage();
    storage.result = {
      status: "already_exists",
      object: metadata(),
    };
    const persister = new AtomicEvidenceUploadPersister(storage);

    await expect(persister.persist(upload())).resolves.toEqual({
      status: "already_exists",
      objectKey,
      sha256,
      tamanhoBytes: 12,
    });
    expect(storage.calls).toBe(1);
  });

  it.each([
    ["objectKey", "evidencias/v1/outra-chave.jpg"],
    ["acaoId", "outra-acao"],
    ["evidenciaId", "outra-evidencia"],
    ["autorUserId", "outro-autor"],
    ["contentType", "image/png"],
    ["tamanhoBytes", 13],
    ["sha256", "b".repeat(64)],
    ["idempotencyKey", "idempotencia-divergente"],
  ] as const)(
    "rejeita objeto existente com %s divergente",
    async (field, value) => {
      const storage = new FakePrivateStorage();
      storage.result = {
        status: "already_exists",
        object: {
          ...metadata(),
          [field]: value,
        } as EvidencePrivateObjectMetadata,
      };
      const persister = new AtomicEvidenceUploadPersister(storage);

      await expect(persister.persist(upload())).rejects.toMatchObject({
        code: "object_conflict",
      });
    },
  );

  it("rejeita objectKey nao canonica antes de acessar storage", async () => {
    const storage = new FakePrivateStorage();
    const persister = new AtomicEvidenceUploadPersister(storage);
    const current = upload();
    current.claims.objectKey = "evidencias/v1/forjada.jpg";

    await expect(persister.persist(current)).rejects.toMatchObject({
      code: "invalid_validated_upload",
    });
    expect(storage.calls).toBe(0);
  });

  it("rejeita tamanho dos bytes divergente antes de acessar storage", async () => {
    const storage = new FakePrivateStorage();
    const persister = new AtomicEvidenceUploadPersister(storage);
    const current = upload();
    current.bytes = new ArrayBuffer(11);

    await expect(persister.persist(current)).rejects.toMatchObject({
      code: "invalid_validated_upload",
    });
    expect(storage.calls).toBe(0);
  });

  it("rejeita SHA validado divergente antes de acessar storage", async () => {
    const storage = new FakePrivateStorage();
    const persister = new AtomicEvidenceUploadPersister(storage);
    const current = upload();
    current.sha256 = "b".repeat(64);

    await expect(persister.persist(current)).rejects.toMatchObject({
      code: "invalid_validated_upload",
    });
    expect(storage.calls).toBe(0);
  });

  it("converte falha da porta privada em indisponibilidade generica", async () => {
    const storage = new FakePrivateStorage();
    storage.error = new Error("detalhe interno R2");
    const persister = new AtomicEvidenceUploadPersister(storage);

    await expect(persister.persist(upload())).rejects.toMatchObject({
      code: "storage_unavailable",
      message: "Porta privada de persistencia indisponivel.",
    });
  });

  it("rejeita resultado desconhecido da porta privada", async () => {
    const storage = new FakePrivateStorage();
    storage.result = {
      status: "overwrite",
    } as unknown as EvidencePrivateStorageCreateResult;
    const persister = new AtomicEvidenceUploadPersister(storage);

    await expect(persister.persist(upload())).rejects.toMatchObject({
      code: "invalid_storage_result",
    });
  });
});
