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

async function request(
  path: string,
  method = "GET",
  body?: string,
  authorization: string | null = "Bearer test-token",
  verifier: FirebaseIdTokenVerifier = new FakeVerifier(),
  dataSource: EvidenceAclDataSource = new FakeAclDataSource(),
): Promise<Response> {
  const headers = new Headers();

  if (body !== undefined) {
    headers.set("content-type", "application/json");
  }

  if (authorization !== null) {
    headers.set("authorization", authorization);
  }

  const dependencies: WorkerDependencies = {
    firebaseIdTokenVerifier: verifier,
    evidenceAclDataSource: dataSource,
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

describe("SEC-R2-002A Worker fail-closed", () => {
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

  it("mantem grant valido bloqueado apos validar contrato", async () => {
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
    );

    expect(response.status).toBe(501);

    const body = await response.json();

    expect(body).toEqual({
      error: "not_implemented",
      code: "SEC_R2_002A_FAIL_CLOSED",
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
    const response = await request(
      "/v1/evidencias/upload/capability-demo",
      "PUT",
    );

    expect(response.status).toBe(501);
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
