import { describe, expect, it } from "vitest";
import type { FirebaseIdTokenVerifier } from "../src/caller_auth";
import type {
  EvidenceAclDataSource,
  EvidenceRaeRecord,
  EvidenceUserRecord,
} from "../src/evidence_acl";
import {
  handleRequest,
  type WorkerDependencies,
} from "../src/index";
import {
  EvidenceGrantError,
  type EvidenceUploadGrant,
  type EvidenceUploadGrantIssuer,
} from "../src/evidence_grant";
import type { EvidenceUploadGrantRequest } from "../src/evidence_contract";
import type { EvidenceUploadCapabilityClaims } from "../src/evidence_capability";
import {
  EvidenceUploadValidationError,
  type EvidenceUploadValidator,
} from "../src/evidence_upload";

class FakeVerifier implements FirebaseIdTokenVerifier {
  lastToken: string | null = null;
  shouldFail = false;

  async verifyIdToken(idToken: string) {
    this.lastToken = idToken;

    if (this.shouldFail) {
      throw new Error("token invalido");
    }

    return {
      uid: "uid-operacional-001",
    };
  }
}

class FakeAclDataSource implements EvidenceAclDataSource {
  userRecord: EvidenceUserRecord | null = {
    uid: "uid-operacional-001",
    ativo: true,
    perfilAcesso: "agente",
    regionalIds: [],
    equipeIds: [],
    projetoIds: [],
    scopeVersion: 1,
  };

  raeRecord: EvidenceRaeRecord | null = {
    id: "acao-77",
    aclClassificacaoCompleta: true,
    responsavelUserId: "uid-operacional-001",
    coordenadorUserId: "coordenador-1",
    regionalId: "regional-1",
    equipeId: "equipe-1",
    projetoId: "projeto-1",
  };

  lastUserId: string | null = null;
  lastRaeId: string | null = null;

  async loadUser(uid: string) {
    this.lastUserId = uid;
    return this.userRecord;
  }

  async loadRae(acaoId: string) {
    this.lastRaeId = acaoId;
    return this.raeRecord;
  }
}

class FakeGrantIssuer implements EvidenceUploadGrantIssuer {
  error: Error | null = null;
  lastRequest: EvidenceUploadGrantRequest | null = null;
  lastCallerUid: string | null = null;

  readonly grant: EvidenceUploadGrant = {
    uri: "https://evidence.fenix.test/v1/evidencias/upload/token-demo",
    operation: "upload",
    expiresAt: "2026-09-12T18:05:00.000Z",
    objectKey: `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
    requiredHeaders: {
      "Content-Type": "image/jpeg",
      "X-Fenix-Idempotency-Key":
        `evidence-upload-v1:acao-77:ev-99:${"a".repeat(64)}`,
    },
    uploadIdentity: {
      acaoId: "acao-77",
      evidenciaId: "ev-99",
      sha256: "a".repeat(64),
    },
  };

  async issue(
    uploadRequest: EvidenceUploadGrantRequest,
    callerUid: string,
  ): Promise<EvidenceUploadGrant> {
    this.lastRequest = uploadRequest;
    this.lastCallerUid = callerUid;

    if (this.error !== null) {
      throw this.error;
    }

    return this.grant;
  }
}

class FakeUploadValidator implements EvidenceUploadValidator {
  error: Error | null = null;
  lastCapability: string | null = null;
  lastRequest: Request | null = null;

  async validate(capability: string, request: Request) {
    this.lastCapability = capability;
    this.lastRequest = request;

    if (this.error !== null) {
      throw this.error;
    }

    const claims: EvidenceUploadCapabilityClaims = {
      v: 1,
      purpose: "evidence-upload",
      callerUid: "uid-operacional-001",
      autorUserId: "captor-77",
      acaoId: "acao-77",
      evidenciaId: "ev-99",
      contentType: "image/jpeg",
      tamanhoBytes: 3,
      sha256: "a".repeat(64),
      objectKey: `evidencias/v1/acao-77/ev-99/${"a".repeat(64)}.jpg`,
      issuedAt: 1789264800,
      expiresAt: 1789265100,
    };

    return {
      claims,
      bytes: Uint8Array.from([1, 2, 3]).buffer,
      sha256: claims.sha256,
    };
  }
}

async function request(
  path: string,
  method = "GET",
  body?: string,
  authorization: string | null = "Bearer test-token",
  verifier: FirebaseIdTokenVerifier = new FakeVerifier(),
  dataSource: EvidenceAclDataSource = new FakeAclDataSource(),
  grantIssuer: EvidenceUploadGrantIssuer = new FakeGrantIssuer(),
  uploadValidator?: EvidenceUploadValidator,
  extraHeaders: Record<string, string> = {},
): Promise<Response> {
  const headers = new Headers();

  if (body !== undefined) {
    headers.set("content-type", "application/json");
  }

  if (authorization !== null) {
    headers.set("authorization", authorization);
  }

  for (const [name, value] of Object.entries(extraHeaders)) {
    headers.set(name, value);
  }

  const dependencies: WorkerDependencies = {
    firebaseIdTokenVerifier: verifier,
    evidenceAclDataSource: dataSource,
    evidenceUploadGrantIssuer: grantIssuer,
    evidenceUploadValidator: uploadValidator,
  };

  return handleRequest(
    new Request(`https://fenix.test${path}`, {
      method,
      body,
      headers,
    }),
    dependencies,
  );
}

describe("SEC-R2-002A Worker", () => {
  it("responde health sem habilitar storage remoto", async () => {
    const response = await request("/health");

    expect(response.status).toBe(200);
    expect(response.headers.get("cache-control")).toBe("no-store");

    const body = await response.json();

    expect(body).toEqual({
      status: "ok",
      service: "fenix-evidence-api",
      remoteStorageEnabled: false,
    });
  });

  it("emite grant valido apos autenticacao, contrato e ACL", async () => {
    const grantIssuer = new FakeGrantIssuer();
    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      grantIssuer,
    );

    expect(response.status).toBe(200);
    expect(response.headers.get("cache-control")).toBe("no-store");
    expect(grantIssuer.lastCallerUid).toBe("uid-operacional-001");
    expect(grantIssuer.lastRequest).toMatchObject({
      autorUserId: "captor-77",
      acaoId: "acao-77",
      evidenciaId: "ev-99",
    });

    const body = await response.json();

    expect(body).toEqual(grantIssuer.grant);
  });

  it("nega grant quando vinculo autoritativo do autor falha", async () => {
    const grantIssuer = new FakeGrantIssuer();
    grantIssuer.error = new EvidenceGrantError(
      "author_binding_denied",
      "autor negado",
    );

    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-sem-vinculo",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      grantIssuer,
    );

    expect(response.status).toBe(403);
    expect(await response.json()).toEqual({
      error: "forbidden",
      code: "author_binding_denied",
    });
  });

  it("falha fechado quando emissor de grant fica indisponivel", async () => {
    const grantIssuer = new FakeGrantIssuer();
    grantIssuer.error = new Error("falha interna sensivel");

    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      grantIssuer,
    );

    expect(response.status).toBe(503);
    expect(await response.json()).toEqual({
      error: "service_unavailable",
      code: "grant_unavailable",
    });
  });

  it("rejeita grant sem Authorization", async () => {
    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
      null,
    );

    expect(response.status).toBe(401);
    expect(response.headers.get("www-authenticate")).toBe("Bearer");
    expect(await response.json()).toEqual({
      error: "unauthorized",
      code: "missing_authorization",
    });
  });

  it("rejeita Firebase ID Token invalido", async () => {
    const verifier = new FakeVerifier();
    verifier.shouldFail = true;

    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
      "Bearer token-invalido",
      verifier,
    );

    expect(verifier.lastToken).toBe("token-invalido");
    expect(response.status).toBe(401);
    expect(await response.json()).toEqual({
      error: "unauthorized",
      code: "invalid_token",
    });
  });

  it("nega grant quando ACL server-side nao autoriza", async () => {
    const dataSource = new FakeAclDataSource();

    dataSource.raeRecord = {
      ...dataSource.raeRecord!,
      responsavelUserId: "outro-agente",
    };

    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
      "Bearer token-valido",
      new FakeVerifier(),
      dataSource,
    );

    expect(dataSource.lastUserId).toBe("uid-operacional-001");
    expect(dataSource.lastRaeId).toBe("acao-77");
    expect(response.status).toBe(403);

    expect(await response.json()).toEqual({
      error: "forbidden",
      code: "responsible_mismatch",
    });
  });

  it("mantem verificador produtivo default fail-closed", async () => {
    const response = await handleRequest(
      new Request(
        "https://fenix.test/v1/evidencias/upload-grant",
        {
          method: "POST",
          headers: {
            authorization: "Bearer token-sem-verificador-real",
            "content-type": "application/json",
          },
          body: JSON.stringify({
            acaoId: "acao-77",
            evidenciaId: "ev-99",
            autorUserId: "captor-77",
            contentType: "image/jpeg",
            tamanhoBytes: 9876,
            sha256: "a".repeat(64),
          }),
        },
      ),
    );

    expect(response.status).toBe(401);
    expect(await response.json()).toEqual({
      error: "unauthorized",
      code: "invalid_token",
    });
  });

  it("rejeita JSON malformado no grant", async () => {
    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      "{invalido",
    );

    expect(response.status).toBe(400);
    expect(await response.json()).toEqual({
      error: "invalid_json",
    });
  });

  it("rejeita contrato invalido no grant", async () => {
    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "../acao",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
      }),
    );

    expect(response.status).toBe(400);
    expect(await response.json()).toEqual({
      error: "invalid_request",
      code: "unsafe_identifier",
    });
  });

  it("rejeita objectKey fornecida pelo cliente na rota", async () => {
    const response = await request(
      "/v1/evidencias/upload-grant",
      "POST",
      JSON.stringify({
        acaoId: "acao-77",
        evidenciaId: "ev-99",
        autorUserId: "captor-77",
        contentType: "image/jpeg",
        tamanhoBytes: 9876,
        sha256: "a".repeat(64),
        objectKey: "forjada.jpg",
      }),
    );

    expect(response.status).toBe(400);
    expect(await response.json()).toEqual({
      error: "invalid_request",
      code: "unexpected_field",
    });
  });

  it("mantem upload bloqueado", async () => {
    const uploadValidator = new FakeUploadValidator();
    const response = await request(
      "/v1/evidencias/upload/capability-demo",
      "PUT",
      "abc",
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      new FakeGrantIssuer(),
      uploadValidator,
      {
        "content-type": "image/jpeg",
        "x-fenix-idempotency-key": "idempotency-demo",
      },
    );

    expect(response.status).toBe(501);
    expect(await response.json()).toEqual({
      error: "not_implemented",
      code: "SEC_R2_002A_6C_STORAGE_FAIL_CLOSED",
    });
    expect(uploadValidator.lastCapability).toBe("capability-demo");
  });

  it("falha fechado quando validador do PUT nao esta configurado", async () => {
    const response = await request(
      "/v1/evidencias/upload/capability-demo",
      "PUT",
      "abc",
    );

    expect(response.status).toBe(503);
    expect(await response.json()).toEqual({
      error: "service_unavailable",
      code: "validator_unavailable",
    });
  });

  it("mapeia capability invalida sem expor detalhe criptografico", async () => {
    const uploadValidator = new FakeUploadValidator();
    uploadValidator.error = new EvidenceUploadValidationError(
      "invalid_capability",
      "assinatura interna divergente",
    );

    const response = await request(
      "/v1/evidencias/upload/capability-forjada",
      "PUT",
      "abc",
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      new FakeGrantIssuer(),
      uploadValidator,
    );

    expect(response.status).toBe(401);
    expect(response.headers.get("www-authenticate")).toBe("Capability");
    expect(await response.json()).toEqual({
      error: "unauthorized",
      code: "invalid_capability",
    });
  });

  it("mapeia divergencia dos bytes como conteudo nao processavel", async () => {
    const uploadValidator = new FakeUploadValidator();
    uploadValidator.error = new EvidenceUploadValidationError(
      "hash_mismatch",
      "hash interno divergente",
    );

    const response = await request(
      "/v1/evidencias/upload/capability-valida",
      "PUT",
      "abc",
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      new FakeGrantIssuer(),
      uploadValidator,
    );

    expect(response.status).toBe(422);
    expect(await response.json()).toEqual({
      error: "unprocessable_content",
      code: "hash_mismatch",
    });
  });

  it("rejeita query adicional no endpoint de upload", async () => {
    const uploadValidator = new FakeUploadValidator();
    const response = await request(
      "/v1/evidencias/upload/capability-demo?forjada=1",
      "PUT",
      "abc",
      "Bearer test-token",
      new FakeVerifier(),
      new FakeAclDataSource(),
      new FakeGrantIssuer(),
      uploadValidator,
    );

    expect(response.status).toBe(400);
    expect(await response.json()).toEqual({
      error: "invalid_upload",
      code: "unexpected_query",
    });
    expect(uploadValidator.lastCapability).toBeNull();
  });

  it("rejeita metodo incorreto no grant", async () => {
    const response = await request(
      "/v1/evidencias/upload-grant",
      "GET",
    );

    expect(response.status).toBe(405);
    expect(response.headers.get("allow")).toBe("POST");
  });

  it("rejeita capability vazia", async () => {
    const response = await request(
      "/v1/evidencias/upload/",
      "PUT",
    );

    expect(response.status).toBe(404);
  });

  it("rejeita rota desconhecida", async () => {
    const response = await request("/nao-existe");

    expect(response.status).toBe(404);
  });
});
