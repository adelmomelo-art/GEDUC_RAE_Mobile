import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  SEED_IAM_AUTH_STRATEGY,
  SEED_IAM_CALLER_IMPERSONATION_PERMISSION,
  SEED_IAM_CUSTOM_ROLE_ID,
  SEED_IAM_EXCLUDED_DATA_PERMISSIONS,
  SEED_IAM_PROJECT_ID,
  SEED_IAM_REQUIRED_DATA_PERMISSIONS,
  SEED_IAM_SERVICE_ACCOUNT_ID,
  assertSeedWriterPermissionProfile,
  buildSeedIamBlueprint,
  evaluateSeedWriterPermissions,
} from '../tools/catalogos/projeto_catalog_seed_iam_blueprint.mjs';

test('blueprint fixa projeto, identidade dedicada e impersonacao', () => {
  const blueprint =
    buildSeedIamBlueprint();

  assert.equal(
    blueprint.projectId,
    'geduc-rae-mobile',
  );

  assert.equal(
    blueprint.proposedServiceAccount.accountId,
    SEED_IAM_SERVICE_ACCOUNT_ID,
  );

  assert.equal(
    blueprint.proposedCustomRole.roleId,
    SEED_IAM_CUSTOM_ROLE_ID,
  );

  assert.equal(
    blueprint.proposedServiceAccount.authStrategy,
    SEED_IAM_AUTH_STRATEGY,
  );

  assert.equal(
    blueprint.impersonation.callerPermission,
    SEED_IAM_CALLER_IMPERSONATION_PERMISSION,
  );

  assert.equal(
    blueprint.proposedServiceAccount.keyFilesAllowed,
    false,
  );

  assert.equal(
    blueprint.impersonation.persistentServiceAccountKeyAllowed,
    false,
  );

  assert.equal(
    blueprint.remoteMutationImplemented,
    false,
  );

  assert.equal(
    blueprint.remoteExecutionImplemented,
    false,
  );
});

test('perfil de dados inclui somente get e create', () => {
  assert.deepEqual(
    [...SEED_IAM_REQUIRED_DATA_PERMISSIONS],
    [
      'datastore.entities.get',
      'datastore.entities.create',
    ],
  );

  for (const permission of [
    'datastore.entities.list',
    'datastore.entities.update',
    'datastore.entities.delete',
    'datastore.entities.allocateIds',
  ]) {
    assert.equal(
      SEED_IAM_REQUIRED_DATA_PERMISSIONS.includes(
        permission,
      ),
      false,
      permission,
    );

    assert.equal(
      SEED_IAM_EXCLUDED_DATA_PERMISSIONS.includes(
        permission,
      ),
      true,
      permission,
    );
  }
});

test('perfil minimo exato e aprovado', () => {
  const result =
    assertSeedWriterPermissionProfile([
      'datastore.entities.create',
      'datastore.entities.get',
    ]);

  assert.equal(result.approved, true);
  assert.deepEqual(
    [...result.requiredMissing],
    [],
  );
  assert.deepEqual(
    [...result.excludedPresent],
    [],
  );
});

test('falta de get ou create bloqueia', () => {
  for (const granted of [
    ['datastore.entities.get'],
    ['datastore.entities.create'],
    [],
  ]) {
    assert.throws(
      () =>
        assertSeedWriterPermissionProfile(
          granted,
        ),
      /BUGRAE002E_IAM_LEAST_PRIVILEGE_PROFILE_REJECTED/u,
    );
  }
});

test('update ou delete bloqueiam security readiness', () => {
  for (const extra of [
    'datastore.entities.update',
    'datastore.entities.delete',
  ]) {
    const result =
      evaluateSeedWriterPermissions([
        'datastore.entities.get',
        'datastore.entities.create',
        extra,
      ]);

    assert.equal(result.approved, false);
    assert.deepEqual(
      [...result.excludedPresent],
      [extra],
    );
  }
});

test('perfil observado no ADC authorized_user atual e rejeitado', () => {
  const result =
    evaluateSeedWriterPermissions([
      'datastore.entities.get',
      'datastore.entities.list',
      'datastore.entities.create',
      'datastore.entities.update',
      'datastore.entities.delete',
    ]);

  assert.equal(result.approved, false);

  assert.deepEqual(
    [...result.requiredMissing],
    [],
  );

  assert.deepEqual(
    [...result.excludedPresent],
    [
      'datastore.entities.list',
      'datastore.entities.update',
      'datastore.entities.delete',
    ],
  );
});

test('blueprint separa identidade de auditoria da identidade de escrita', () => {
  const blueprint =
    buildSeedIamBlueprint();

  assert.equal(
    blueprint.identitySeparation
      .auditIdentityMayInspectRuleset,
    true,
  );

  assert.equal(
    blueprint.identitySeparation
      .seedWriterMustBeDedicatedServiceAccount,
    true,
  );

  assert.equal(
    blueprint.identitySeparation
      .baseUserAdcMustNotCallFirestoreDocumentWriteApi,
    true,
  );

  assert.equal(
    blueprint.identitySeparation
      .firestoreReadBeforeCreateUsesSeedWriterIdentity,
    true,
  );
});

test('modulo e somente blueprint local, sem CLI ou rede', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_iam_blueprint.mjs',
    'utf8',
  );

  for (const pattern of [
    'process.argv',
    'pathToFileURL',
    'child_process',
    'gcloud ',
    'fetch(',
    'Invoke-RestMethod',
    'googleapis.com',
    'createServiceAccount',
    'setIamPolicy',
    'createRole',
  ]) {
    assert.equal(
      source.includes(pattern),
      false,
      pattern,
    );
  }
});

test('constantes principais permanecem congeladas', () => {
  assert.equal(
    SEED_IAM_PROJECT_ID,
    'geduc-rae-mobile',
  );

  assert.equal(
    SEED_IAM_SERVICE_ACCOUNT_ID,
    'fenix-project-catalog-seed',
  );

  assert.equal(
    SEED_IAM_CUSTOM_ROLE_ID,
    'FenixProjectCatalogSeedCreateOnly',
  );
});
