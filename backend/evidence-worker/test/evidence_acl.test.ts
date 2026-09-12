import { describe, expect, it } from "vitest";
import {
  authorizeEvidenceUpload,
  authorizeEvidenceUploadFromData,
  type EvidenceAclDataSource,
  type EvidenceRaeRecord,
  type EvidenceUserRecord,
} from "../src/evidence_acl";

function user(
  overrides: Partial<EvidenceUserRecord> = {},
): EvidenceUserRecord {
  return {
    uid: "agente-1",
    ativo: true,
    perfilAcesso: "agente",
    regionalIds: [],
    equipeIds: [],
    projetoIds: [],
    scopeVersion: 1,
    ...overrides,
  };
}

function rae(
  overrides: Partial<EvidenceRaeRecord> = {},
): EvidenceRaeRecord {
  return {
    id: "acao-1",
    aclClassificacaoCompleta: true,
    responsavelUserId: "agente-1",
    coordenadorUserId: "coordenador-1",
    regionalId: "regional-1",
    equipeId: "equipe-1",
    projetoId: "projeto-1",
    ...overrides,
  };
}

class FakeDataSource implements EvidenceAclDataSource {
  userRecord: EvidenceUserRecord | null = user();
  raeRecord: EvidenceRaeRecord | null = rae();
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

describe("SEC-R2-002A.5 - evidence ACL", () => {
  it("permite Administrador mesmo em RAE sem classificacao integral", () => {
    expect(
      authorizeEvidenceUpload(
        user({
          uid: "admin-1",
          perfilAcesso: "administrador",
        }),
        rae({
          aclClassificacaoCompleta: false,
          responsavelUserId: "",
          coordenadorUserId: "",
          equipeId: "",
          projetoId: "",
        }),
      ),
    ).toEqual({ allowed: true });
  });

  it("nega usuario inativo", () => {
    expect(
      authorizeEvidenceUpload(
        user({ ativo: false }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "inactive_user",
    });
  });

  it("nega perfil desconhecido", () => {
    expect(
      authorizeEvidenceUpload(
        user({ perfilAcesso: "visitante" }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "unknown_profile",
    });
  });

  it("nega RAE incompleto para perfil operacional", () => {
    expect(
      authorizeEvidenceUpload(
        user(),
        rae({ aclClassificacaoCompleta: false }),
      ),
    ).toEqual({
      allowed: false,
      code: "incomplete_rae_acl",
    });
  });

  it("nega Gestor por ser somente leitura", () => {
    expect(
      authorizeEvidenceUpload(
        user({
          uid: "gestor-1",
          perfilAcesso: "gestor",
        }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "read_only_profile",
    });
  });

  it("Gerente valida escopo integral mas continua somente leitura", () => {
    expect(
      authorizeEvidenceUpload(
        user({
          uid: "gerente-1",
          perfilAcesso: "gerente",
          regionalIds: ["regional-1"],
          equipeIds: ["equipe-1"],
          projetoIds: ["projeto-1"],
          scopeVersion: 1,
        }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "read_only_profile",
    });
  });

  it("Gerente fora do escopo falha antes da regra read-only", () => {
    expect(
      authorizeEvidenceUpload(
        user({
          uid: "gerente-1",
          perfilAcesso: "gerente",
          regionalIds: ["regional-2"],
          equipeIds: ["equipe-1"],
          projetoIds: ["projeto-1"],
        }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "scope_mismatch",
    });
  });

  it("permite Coordenador apenas no proprio RAE", () => {
    expect(
      authorizeEvidenceUpload(
        user({
          uid: "coordenador-1",
          perfilAcesso: "coordenador",
        }),
        rae(),
      ),
    ).toEqual({ allowed: true });

    expect(
      authorizeEvidenceUpload(
        user({
          uid: "coordenador-2",
          perfilAcesso: "coordenador",
        }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "coordinator_mismatch",
    });
  });

  it("permite Agente apenas quando e responsavel pelo RAE", () => {
    expect(
      authorizeEvidenceUpload(user(), rae()),
    ).toEqual({ allowed: true });

    expect(
      authorizeEvidenceUpload(
        user({ uid: "agente-2" }),
        rae(),
      ),
    ).toEqual({
      allowed: false,
      code: "responsible_mismatch",
    });
  });

  it("carrega usuario e RAE por IDs autoritativos", async () => {
    const dataSource = new FakeDataSource();

    const decision = await authorizeEvidenceUploadFromData(
      "agente-1",
      "acao-1",
      dataSource,
    );

    expect(dataSource.lastUserId).toBe("agente-1");
    expect(dataSource.lastRaeId).toBe("acao-1");
    expect(decision).toEqual({ allowed: true });
  });

  it("nega quando usuario nao existe", async () => {
    const dataSource = new FakeDataSource();
    dataSource.userRecord = null;

    await expect(
      authorizeEvidenceUploadFromData(
        "agente-1",
        "acao-1",
        dataSource,
      ),
    ).resolves.toEqual({
      allowed: false,
      code: "user_not_found",
    });
  });

  it("nega quando RAE nao existe", async () => {
    const dataSource = new FakeDataSource();
    dataSource.raeRecord = null;

    await expect(
      authorizeEvidenceUploadFromData(
        "agente-1",
        "acao-1",
        dataSource,
      ),
    ).resolves.toEqual({
      allowed: false,
      code: "rae_not_found",
    });
  });
});
