export const SEED_IAM_PROJECT_ID = 'geduc-rae-mobile';

export const SEED_IAM_SERVICE_ACCOUNT_ID =
  'fenix-project-catalog-seed';

export const SEED_IAM_CUSTOM_ROLE_ID =
  'FenixProjectCatalogSeedCreateOnly';

export const SEED_IAM_AUTH_STRATEGY =
  'service_account_impersonation_short_lived_token';

export const SEED_IAM_CALLER_IMPERSONATION_PERMISSION =
  'iam.serviceAccounts.getAccessToken';

export const SEED_IAM_RECOMMENDED_IMPERSONATION_ROLE =
  'roles/iam.serviceAccountTokenCreator';

export const SEED_IAM_REQUIRED_DATA_PERMISSIONS =
  Object.freeze([
    'datastore.entities.get',
    'datastore.entities.create',
  ]);

export const SEED_IAM_EXCLUDED_DATA_PERMISSIONS =
  Object.freeze([
    'datastore.entities.list',
    'datastore.entities.update',
    'datastore.entities.delete',
    'datastore.entities.allocateIds',
  ]);

function normalizePermission(value) {
  return typeof value === 'string'
    ? value.trim()
    : '';
}

function uniqueSorted(values) {
  return Object.freeze(
    [
      ...new Set(
        values
          .map(normalizePermission)
          .filter((value) => value !== ''),
      ),
    ].sort(),
  );
}

export function buildSeedIamBlueprint() {
  return Object.freeze({
    mode: 'iam-least-privilege-blueprint',
    projectId: SEED_IAM_PROJECT_ID,

    proposedServiceAccount: Object.freeze({
      accountId: SEED_IAM_SERVICE_ACCOUNT_ID,
      email:
        `${SEED_IAM_SERVICE_ACCOUNT_ID}` +
        `@${SEED_IAM_PROJECT_ID}.iam.gserviceaccount.com`,
      existsRemotely: false,
      keyFilesAllowed: false,
      authStrategy: SEED_IAM_AUTH_STRATEGY,
    }),

    proposedCustomRole: Object.freeze({
      roleId: SEED_IAM_CUSTOM_ROLE_ID,
      existsRemotely: false,
      includedPermissions:
        SEED_IAM_REQUIRED_DATA_PERMISSIONS,
      excludedPermissions:
        SEED_IAM_EXCLUDED_DATA_PERMISSIONS,
    }),

    impersonation: Object.freeze({
      callerPermission:
        SEED_IAM_CALLER_IMPERSONATION_PERMISSION,
      recommendedStandardRole:
        SEED_IAM_RECOMMENDED_IMPERSONATION_ROLE,
      bindOnTargetServiceAccountOnly: true,
      shortLivedCredentialRequired: true,
      persistentServiceAccountKeyAllowed: false,
    }),

    identitySeparation: Object.freeze({
      auditIdentityMayInspectRuleset: true,
      seedWriterMustBeDedicatedServiceAccount: true,
      baseUserAdcMustNotCallFirestoreDocumentWriteApi: true,
      firestoreReadBeforeCreateUsesSeedWriterIdentity: true,
    }),

    remoteMutationImplemented: false,
    remoteExecutionImplemented: false,
  });
}

export function evaluateSeedWriterPermissions(grantedPermissions) {
  const granted =
    uniqueSorted(
      Array.isArray(grantedPermissions)
        ? grantedPermissions
        : [],
    );

  const requiredMissing =
    SEED_IAM_REQUIRED_DATA_PERMISSIONS
      .filter(
        (permission) =>
          !granted.includes(permission),
      );

  const excludedPresent =
    SEED_IAM_EXCLUDED_DATA_PERMISSIONS
      .filter(
        (permission) =>
          granted.includes(permission),
      );

  const approved =
    requiredMissing.length === 0 &&
    excludedPresent.length === 0;

  return Object.freeze({
    approved,
    granted,
    requiredMissing:
      Object.freeze(requiredMissing),
    excludedPresent:
      Object.freeze(excludedPresent),
    requiredExact:
      SEED_IAM_REQUIRED_DATA_PERMISSIONS,
    excluded:
      SEED_IAM_EXCLUDED_DATA_PERMISSIONS,
  });
}

export function assertSeedWriterPermissionProfile(
  grantedPermissions,
) {
  const result =
    evaluateSeedWriterPermissions(
      grantedPermissions,
    );

  if (!result.approved) {
    const error =
      new Error(
        'BUGRAE002E_IAM_LEAST_PRIVILEGE_PROFILE_REJECTED',
      );

    error.details = result;
    throw error;
  }

  return result;
}
