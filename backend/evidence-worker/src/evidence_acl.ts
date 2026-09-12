export type EvidenceAclProfile =
  | "administrador"
  | "gestor"
  | "gerente"
  | "coordenador"
  | "agente";

export interface EvidenceUserRecord {
  uid: string;
  ativo: boolean;
  perfilAcesso: string;
  regionalIds: readonly string[];
  equipeIds: readonly string[];
  projetoIds: readonly string[];
  scopeVersion: number;
}

export interface EvidenceRaeRecord {
  id: string;
  aclClassificacaoCompleta: boolean;
  responsavelUserId: string;
  coordenadorUserId: string;
  regionalId: string;
  equipeId: string;
  projetoId: string;
}

export interface EvidenceAclDataSource {
  loadUser(uid: string): Promise<EvidenceUserRecord | null>;
  loadRae(acaoId: string): Promise<EvidenceRaeRecord | null>;
}

export type EvidenceAclDecision =
  | { allowed: true }
  | {
      allowed: false;
      code: string;
    };

const knownProfiles = new Set<EvidenceAclProfile>([
  "administrador",
  "gestor",
  "gerente",
  "coordenador",
  "agente",
]);

function normalize(value: string): string {
  return value.trim();
}

function normalizeProfile(value: string): string {
  return value.trim().toLowerCase();
}

function nonEmpty(value: string): boolean {
  return normalize(value).length > 0;
}

function hasCompleteClassification(
  rae: EvidenceRaeRecord,
): boolean {
  return (
    rae.aclClassificacaoCompleta === true &&
    nonEmpty(rae.responsavelUserId) &&
    nonEmpty(rae.coordenadorUserId) &&
    nonEmpty(rae.regionalId) &&
    nonEmpty(rae.equipeId) &&
    nonEmpty(rae.projetoId)
  );
}

function managerScopeCovers(
  user: EvidenceUserRecord,
  rae: EvidenceRaeRecord,
): boolean {
  if (user.scopeVersion <= 0) {
    return false;
  }

  const regionais = new Set(
    user.regionalIds.map(normalize).filter(Boolean),
  );
  const equipes = new Set(
    user.equipeIds.map(normalize).filter(Boolean),
  );
  const projetos = new Set(
    user.projetoIds.map(normalize).filter(Boolean),
  );

  if (
    regionais.size === 0 ||
    equipes.size === 0 ||
    projetos.size === 0
  ) {
    return false;
  }

  return (
    regionais.has(normalize(rae.regionalId)) &&
    equipes.has(normalize(rae.equipeId)) &&
    projetos.has(normalize(rae.projetoId))
  );
}

export function authorizeEvidenceUpload(
  user: EvidenceUserRecord,
  rae: EvidenceRaeRecord,
): EvidenceAclDecision {
  const uid = normalize(user.uid);
  const profile = normalizeProfile(user.perfilAcesso);

  if (!user.ativo) {
    return {
      allowed: false,
      code: "inactive_user",
    };
  }

  if (uid.length === 0) {
    return {
      allowed: false,
      code: "invalid_user",
    };
  }

  if (!knownProfiles.has(profile as EvidenceAclProfile)) {
    return {
      allowed: false,
      code: "unknown_profile",
    };
  }

  if (profile === "administrador") {
    return { allowed: true };
  }

  if (!hasCompleteClassification(rae)) {
    return {
      allowed: false,
      code: "incomplete_rae_acl",
    };
  }

  if (profile === "gestor") {
    return {
      allowed: false,
      code: "read_only_profile",
    };
  }

  if (profile === "gerente") {
    if (!managerScopeCovers(user, rae)) {
      return {
        allowed: false,
        code: "scope_mismatch",
      };
    }

    return {
      allowed: false,
      code: "read_only_profile",
    };
  }

  if (profile === "coordenador") {
    if (normalize(rae.coordenadorUserId) !== uid) {
      return {
        allowed: false,
        code: "coordinator_mismatch",
      };
    }

    return { allowed: true };
  }

  if (profile === "agente") {
    if (normalize(rae.responsavelUserId) !== uid) {
      return {
        allowed: false,
        code: "responsible_mismatch",
      };
    }

    return { allowed: true };
  }

  return {
    allowed: false,
    code: "denied",
  };
}

export async function authorizeEvidenceUploadFromData(
  callerUid: string,
  acaoId: string,
  dataSource: EvidenceAclDataSource,
): Promise<EvidenceAclDecision> {
  const uid = callerUid.trim();
  const raeId = acaoId.trim();

  if (uid.length === 0) {
    return {
      allowed: false,
      code: "invalid_user",
    };
  }

  if (raeId.length === 0) {
    return {
      allowed: false,
      code: "invalid_rae",
    };
  }

  const user = await dataSource.loadUser(uid);

  if (user === null || normalize(user.uid) !== uid) {
    return {
      allowed: false,
      code: "user_not_found",
    };
  }

  const rae = await dataSource.loadRae(raeId);

  if (rae === null || normalize(rae.id) !== raeId) {
    return {
      allowed: false,
      code: "rae_not_found",
    };
  }

  return authorizeEvidenceUpload(user, rae);
}
