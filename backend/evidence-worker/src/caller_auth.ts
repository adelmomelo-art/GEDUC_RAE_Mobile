export interface AuthenticatedCaller {
  uid: string;
}

export interface FirebaseIdTokenPrincipal {
  uid: string;
}

export interface FirebaseIdTokenVerifier {
  verifyIdToken(
    idToken: string,
  ): Promise<FirebaseIdTokenPrincipal>;
}

export class CallerAuthError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "CallerAuthError";
  }
}

export function extractBearerToken(
  request: Request,
): string {
  const authorization = request.headers.get("authorization");

  if (authorization === null) {
    throw new CallerAuthError(
      "missing_authorization",
      "Authorization ausente.",
    );
  }

  const parts = authorization.trim().split(/\s+/);

  if (
    parts.length !== 2 ||
    parts[0].toLowerCase() !== "bearer" ||
    parts[1].length === 0
  ) {
    throw new CallerAuthError(
      "invalid_authorization",
      "Authorization deve usar Bearer token.",
    );
  }

  return parts[1];
}

function normalizeUid(value: unknown): string {
  if (typeof value !== "string") {
    throw new CallerAuthError(
      "invalid_principal",
      "Firebase principal sem UID valido.",
    );
  }

  const uid = value.trim();

  if (uid.length === 0) {
    throw new CallerAuthError(
      "invalid_principal",
      "Firebase principal sem UID valido.",
    );
  }

  return uid;
}

export async function authenticateCaller(
  request: Request,
  verifier: FirebaseIdTokenVerifier,
): Promise<AuthenticatedCaller> {
  const idToken = extractBearerToken(request);

  let principal: FirebaseIdTokenPrincipal;

  try {
    principal = await verifier.verifyIdToken(idToken);
  } catch {
    throw new CallerAuthError(
      "invalid_token",
      "Firebase ID Token invalido.",
    );
  }

  return {
    uid: normalizeUid(principal.uid),
  };
}
