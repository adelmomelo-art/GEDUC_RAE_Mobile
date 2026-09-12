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

export interface WorkerDependencies {
  firebaseIdTokenVerifier: FirebaseIdTokenVerifier;
  evidenceAclDataSource: EvidenceAclDataSource;
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

const defaultDependencies: WorkerDependencies = {
  firebaseIdTokenVerifier: disabledFirebaseIdTokenVerifier,
  evidenceAclDataSource: disabledEvidenceAclDataSource,
};
const jsonHeaders = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
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

function notImplemented(): Response {
  return jsonResponse(501, {
    error: "not_implemented",
    code: "SEC_R2_002A_FAIL_CLOSED",
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

    return notImplemented();
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

    return notImplemented();
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
