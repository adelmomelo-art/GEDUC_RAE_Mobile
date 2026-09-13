import {
  authenticateCaller,
  CallerAuthError,
  type AuthenticatedCaller,
  type FirebaseIdTokenVerifier,
} from "./caller_auth";
import {
  authorizeEvidenceUploadFromData,
  type EvidenceAclDataSource,
} from "./evidence_acl";
import {
  EvidenceContractError,
  parseEvidenceUploadGrantRequest,
  type EvidenceUploadGrantRequest,
} from "./evidence_contract";
import {
  EvidenceGrantError,
  type EvidenceUploadGrantIssuer,
} from "./evidence_grant";
import {
  EvidencePersistenceError,
  type EvidenceUploadPersister,
} from "./evidence_persistence";
import {
  EvidenceUploadValidationError,
  type ValidatedEvidenceUpload,
  type EvidenceUploadValidator,
} from "./evidence_upload";

export interface WorkerDependencies {
  firebaseIdTokenVerifier: FirebaseIdTokenVerifier;
  evidenceAclDataSource: EvidenceAclDataSource;
  evidenceUploadGrantIssuer: EvidenceUploadGrantIssuer;
  evidenceUploadValidator?: EvidenceUploadValidator;
  evidenceUploadPersister?: EvidenceUploadPersister;
}

const disabledFirebaseIdTokenVerifier: FirebaseIdTokenVerifier = {
  async verifyIdToken(): Promise<never> {
    throw new Error("Firebase ID Token verifier nao configurado.");
  },
};

const disabledEvidenceAclDataSource: EvidenceAclDataSource = {
  async loadUser() {
    return null;
  },

  async loadRae() {
    return null;
  },
};

const disabledEvidenceUploadGrantIssuer: EvidenceUploadGrantIssuer = {
  async issue(): Promise<never> {
    throw new EvidenceGrantError(
      "grant_unavailable",
      "Emissor de grant nao configurado.",
    );
  },
};

const disabledEvidenceUploadValidator: EvidenceUploadValidator = {
  async validate(): Promise<never> {
    throw new EvidenceUploadValidationError(
      "validator_unavailable",
      "Validador de upload nao configurado.",
    );
  },
};

const disabledEvidenceUploadPersister: EvidenceUploadPersister = {
  async persist(): Promise<never> {
    throw new EvidencePersistenceError(
      "persistence_unavailable",
      "Porta privada de persistencia nao configurada.",
    );
  },
};

const defaultDependencies: WorkerDependencies = {
  firebaseIdTokenVerifier: disabledFirebaseIdTokenVerifier,
  evidenceAclDataSource: disabledEvidenceAclDataSource,
  evidenceUploadGrantIssuer: disabledEvidenceUploadGrantIssuer,
};
const jsonHeaders = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

function jsonResponse(
  status: number,
  body: unknown,
  extraHeaders: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...jsonHeaders,
      ...extraHeaders,
    },
  });
}

function methodNotAllowed(allow: string): Response {
  return jsonResponse(
    405,
    {
      error: "method_not_allowed",
    },
    { allow },
  );
}

function uploadValidationErrorResponse(
  error: EvidenceUploadValidationError,
): Response {
  if (
    error.code === "invalid_capability" ||
    error.code === "expired_capability"
  ) {
    return jsonResponse(
      401,
      {
        error: "unauthorized",
        code: error.code,
      },
      {
        "www-authenticate": "Capability",
      },
    );
  }

  if (error.code === "validator_unavailable") {
    return jsonResponse(503, {
      error: "service_unavailable",
      code: error.code,
    });
  }

  if (error.code === "payload_too_large") {
    return jsonResponse(413, {
      error: "payload_too_large",
      code: error.code,
    });
  }

  if (
    error.code === "unsupported_content_type" ||
    error.code === "content_encoding_not_allowed" ||
    error.code === "invalid_jpeg_signature"
  ) {
    return jsonResponse(415, {
      error: "unsupported_media_type",
      code: error.code,
    });
  }

  if (error.code === "idempotency_mismatch") {
    return jsonResponse(409, {
      error: "conflict",
      code: error.code,
    });
  }

  if (
    error.code === "size_mismatch" ||
    error.code === "hash_mismatch"
  ) {
    return jsonResponse(422, {
      error: "unprocessable_content",
      code: error.code,
    });
  }

  return jsonResponse(400, {
    error: "invalid_upload",
    code: error.code,
  });
}

function persistenceErrorResponse(
  error: EvidencePersistenceError,
): Response {
  if (error.code === "object_conflict") {
    return jsonResponse(409, {
      error: "conflict",
      code: error.code,
    });
  }

  return jsonResponse(503, {
    error: "service_unavailable",
    code: "storage_unavailable",
  });
}

export async function handleRequest(
  request: Request,
  dependencies: WorkerDependencies = defaultDependencies,
): Promise<Response> {
  const url = new URL(request.url);
  const path = url.pathname;

  if (path === "/health") {
    if (request.method !== "GET") {
      return methodNotAllowed("GET");
    }

    return jsonResponse(200, {
      status: "ok",
      service: "fenix-evidence-api",
      remoteStorageEnabled: false,
    });
  }

  if (path === "/v1/evidencias/upload-grant") {
    if (request.method !== "POST") {
      return methodNotAllowed("POST");
    }

    let caller: AuthenticatedCaller;

    try {
      caller = await authenticateCaller(
        request,
        dependencies.firebaseIdTokenVerifier,
      );
    } catch (error) {
      if (error instanceof CallerAuthError) {
        return jsonResponse(
          401,
          {
            error: "unauthorized",
            code: error.code,
          },
          {
            "www-authenticate": "Bearer",
          },
        );
      }

      throw error;
    }

    let body: unknown;

    try {
      body = await request.json();
    } catch {
      return jsonResponse(400, {
        error: "invalid_json",
      });
    }

    let uploadRequest: EvidenceUploadGrantRequest;

    try {
      uploadRequest = parseEvidenceUploadGrantRequest(body);
    } catch (error) {
      if (error instanceof EvidenceContractError) {
        return jsonResponse(400, {
          error: "invalid_request",
          code: error.code,
        });
      }

      throw error;
    }

    const acl = await authorizeEvidenceUploadFromData(
      caller.uid,
      uploadRequest.acaoId,
      dependencies.evidenceAclDataSource,
    );

    if (!acl.allowed) {
      return jsonResponse(403, {
        error: "forbidden",
        code: acl.code,
      });
    }

    try {
      const grant = await dependencies.evidenceUploadGrantIssuer.issue(
        uploadRequest,
        caller.uid,
      );

      return jsonResponse(200, grant);
    } catch (error) {
      if (error instanceof EvidenceGrantError) {
        if (error.code === "author_binding_denied") {
          return jsonResponse(403, {
            error: "forbidden",
            code: error.code,
          });
        }

        return jsonResponse(503, {
          error: "service_unavailable",
          code: error.code,
        });
      }

      return jsonResponse(503, {
        error: "service_unavailable",
        code: "grant_unavailable",
      });
    }
  }

  const uploadPrefix = "/v1/evidencias/upload/";

  if (path.startsWith(uploadPrefix)) {
    const capability = path.substring(uploadPrefix.length);

    if (capability.length === 0) {
      return jsonResponse(404, {
        error: "not_found",
      });
    }

    if (request.method !== "PUT") {
      return methodNotAllowed("PUT");
    }

    if (url.search.length > 0) {
      return jsonResponse(400, {
        error: "invalid_upload",
        code: "unexpected_query",
      });
    }

    const uploadValidator =
      dependencies.evidenceUploadValidator ??
      disabledEvidenceUploadValidator;

    let validatedUpload: ValidatedEvidenceUpload;

    try {
      validatedUpload = await uploadValidator.validate(
        capability,
        request,
      );
    } catch (error) {
      if (error instanceof EvidenceUploadValidationError) {
        return uploadValidationErrorResponse(error);
      }

      return jsonResponse(503, {
        error: "service_unavailable",
        code: "upload_validation_unavailable",
      });
    }

    const uploadPersister =
      dependencies.evidenceUploadPersister ??
      disabledEvidenceUploadPersister;

    try {
      const result = await uploadPersister.persist(validatedUpload);
      const idempotent = result.status === "already_exists";

      return jsonResponse(idempotent ? 200 : 201, {
        status: result.status,
        operation: "upload",
        objectKey: result.objectKey,
        sha256: result.sha256,
        tamanhoBytes: result.tamanhoBytes,
        idempotent,
      });
    } catch (error) {
      if (error instanceof EvidencePersistenceError) {
        return persistenceErrorResponse(error);
      }

      return jsonResponse(503, {
        error: "service_unavailable",
        code: "storage_unavailable",
      });
    }
  }

  return jsonResponse(404, {
    error: "not_found",
  });
}

export default {
  fetch(request: Request): Promise<Response> {
    return handleRequest(request);
  },
};
