import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  IAM_PLAN_CUSTOM_ROLE_NAME,
  IAM_PLAN_MODE,
  IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
  IAM_PLAN_TOKEN_CREATOR_ROLE,
  buildSeedIamMutationDryRun,
  validateOperatorPrincipal,
} from '../tools/catalogos/projeto_catalog_seed_iam_mutation_plan.mjs';

const OPERATOR =
  'user:operator@example.invalid';

test('plano e exclusivamente dry-run', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  assert.equal(
    plan.mode,
    'dry-run-only',
  );

  assert.equal(
    IAM_PLAN_MODE,
    'dry-run-only',
  );

  assert.equal(
    plan.executeAvailable,
    false,
  );

  assert.equal(
    plan.remoteMutationPerformed,
    false,
  );

  assert.equal(
    plan.persistentKeyAllowed,
    false,
  );
});

test('identidade e role sao exatamente as aprovadas no blueprint', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  assert.equal(
    plan.serviceAccountEmail,
    'fenix-project-catalog-seed@geduc-rae-mobile.iam.gserviceaccount.com',
  );

  assert.equal(
    IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
    plan.serviceAccountEmail,
  );

  assert.equal(
    IAM_PLAN_CUSTOM_ROLE_NAME,
    'projects/geduc-rae-mobile/roles/FenixProjectCatalogSeedCreateOnly',
  );

  assert.deepEqual(
    [...plan.customRolePermissions],
    [
      'datastore.entities.get',
      'datastore.entities.create',
    ],
  );
});

test('plano forward possui quatro operacoes na ordem controlada', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  assert.deepEqual(
    plan.forward.map(
      (item) => item.kind,
    ),
    [
      'CREATE_SERVICE_ACCOUNT',
      'CREATE_CUSTOM_ROLE',
      'ADD_PROJECT_IAM_BINDING',
      'ADD_SERVICE_ACCOUNT_IAM_BINDING',
    ],
  );

  for (const item of plan.forward) {
    assert.equal(item.execute, false);
    assert.equal(item.mutatesIam, true);
  }
});

test('rollback e reverso e tambem nao executavel', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  assert.deepEqual(
    plan.rollback.map(
      (item) => item.kind,
    ),
    [
      'REMOVE_SERVICE_ACCOUNT_IAM_BINDING',
      'REMOVE_PROJECT_IAM_BINDING',
      'DELETE_CUSTOM_ROLE',
      'DELETE_SERVICE_ACCOUNT',
    ],
  );

  for (const item of plan.rollback) {
    assert.equal(item.execute, false);
  }
});

test('custom role gerada contem get + create e nenhum privilegio proibido', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  const createRole =
    plan.forward.find(
      (item) =>
        item.kind === 'CREATE_CUSTOM_ROLE',
    );

  const command =
    createRole.command.join(' ');

  assert.match(
    command,
    /datastore\.entities\.get,datastore\.entities\.create/u,
  );

  for (const forbidden of [
    'datastore.entities.list',
    'datastore.entities.update',
    'datastore.entities.delete',
    'datastore.entities.allocateIds',
  ]) {
    assert.equal(
      command.includes(forbidden),
      false,
      forbidden,
    );
  }
});

test('binding de dados aponta somente para a service account dedicada', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  const binding =
    plan.forward.find(
      (item) =>
        item.kind === 'ADD_PROJECT_IAM_BINDING',
    );

  const command =
    binding.command.join(' ');

  assert.match(
    command,
    /serviceAccount:fenix-project-catalog-seed@geduc-rae-mobile\.iam\.gserviceaccount\.com/u,
  );

  assert.match(
    command,
    /projects\/geduc-rae-mobile\/roles\/FenixProjectCatalogSeedCreateOnly/u,
  );
});

test('token creator e vinculado ao recurso da service account alvo', () => {
  const plan =
    buildSeedIamMutationDryRun({
      operatorPrincipal: OPERATOR,
    });

  const binding =
    plan.forward.find(
      (item) =>
        item.kind === 'ADD_SERVICE_ACCOUNT_IAM_BINDING',
    );

  assert.equal(
    binding.command.includes(
      IAM_PLAN_SERVICE_ACCOUNT_EMAIL,
    ),
    true,
  );

  assert.equal(
    binding.command.includes(
      `--role=${IAM_PLAN_TOKEN_CREATOR_ROLE}`,
    ),
    true,
  );

  assert.equal(
    binding.command.includes(
      `--member=${OPERATOR}`,
    ),
    true,
  );
});

test('principal do operador e obrigatorio e nao e inventado', () => {
  for (const value of [
    '',
    null,
    undefined,
    'operator@example.com',
  ]) {
    assert.throws(
      () =>
        validateOperatorPrincipal(value),
      /BUGRAE002E_IAM_PLAN_OPERATOR_PRINCIPAL/u,
    );
  }

  assert.equal(
    validateOperatorPrincipal(
      'user:real@example.com',
    ),
    'user:real@example.com',
  );
});

test('modulo nao executa gcloud, rede ou IAM', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_iam_mutation_plan.mjs',
    'utf8',
  );

  for (const pattern of [
    'process.argv',
    'pathToFileURL',
    'child_process',
    'exec(',
    'execFile(',
    'spawn(',
    'fetch(',
    'googleapis.com',
    'Invoke-RestMethod',
  ]) {
    assert.equal(
      source.includes(pattern),
      false,
      pattern,
    );
  }
});
