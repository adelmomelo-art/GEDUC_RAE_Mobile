import { describe, expect, it } from "vitest";
import {
  authenticateCaller,
  CallerAuthError,
  extractBearerToken,
  type FirebaseIdTokenVerifier,
} from "../src/caller_auth";

class FakeVerifier implements FirebaseIdTokenVerifier {
  lastToken: string | null = null;
  shouldFail = false;
  uid = "uid-operacional-001";

  async verifyIdToken(idToken: string) {
    this.lastToken = idToken;

    if (this.shouldFail) {
      throw new Error("assinatura invalida");
    }

    return {
      uid: this.uid,
    };
  }
}

function request(
  authorization?: string,
): Request {
  const headers = new Headers();

  if (authorization !== undefined) {
    headers.set("authorization", authorization);
  }

  return new Request("https://fenix.test/test", {
    headers,
  });
}

function authError(
  callback: () => unknown,
): CallerAuthError {
  try {
    callback();
  } catch (error) {
    expect(error).toBeInstanceOf(CallerAuthError);
    return error as CallerAuthError;
  }

  throw new Error("Era esperado CallerAuthError.");
}

describe("SEC-R2-002A.4 - caller authentication", () => {
  it("extrai Bearer token valido", () => {
    expect(
      extractBearerToken(request("Bearer token-123")),
    ).toBe("token-123");
  });

  it("aceita esquema Bearer sem diferenciar maiusculas", () => {
    expect(
      extractBearerToken(request("bearer token-abc")),
    ).toBe("token-abc");
  });

  it("rejeita Authorization ausente", () => {
    const error = authError(() => {
      extractBearerToken(request());
    });

    expect(error.code).toBe("missing_authorization");
  });

  it("rejeita esquema Authorization invalido", () => {
    const error = authError(() => {
      extractBearerToken(request("Basic abc"));
    });

    expect(error.code).toBe("invalid_authorization");
  });

  it("autentica chamador e preserva UID canonico", async () => {
    const verifier = new FakeVerifier();
    verifier.uid = "  uid-operacional-777  ";

    const caller = await authenticateCaller(
      request("Bearer firebase-token"),
      verifier,
    );

    expect(verifier.lastToken).toBe("firebase-token");
    expect(caller).toEqual({
      uid: "uid-operacional-777",
    });
  });

  it("converte falha do verificador em invalid_token", async () => {
    const verifier = new FakeVerifier();
    verifier.shouldFail = true;

    await expect(
      authenticateCaller(
        request("Bearer token-invalido"),
        verifier,
      ),
    ).rejects.toMatchObject({
      code: "invalid_token",
    });
  });

  it("rejeita principal sem UID", async () => {
    const verifier = new FakeVerifier();
    verifier.uid = "   ";

    await expect(
      authenticateCaller(
        request("Bearer token-valido"),
        verifier,
      ),
    ).rejects.toMatchObject({
      code: "invalid_principal",
    });
  });
});
