import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  ENTRYPOINT_REMOTE_EXECUTION_AVAILABLE,
  buildEntrypointStatus,
  parseEntrypointArgs,
  runEntrypoint,
} from '../tools/catalogos/projeto_catalog_seed_entrypoint.mjs';

test('status e o unico modo disponivel', () => {
  const args = parseEntrypointArgs([
    '--status',
    '--project-id',
    'geduc-rae-mobile',
  ]);

  assert.equal(args.mode, 'status');
  assert.equal(args.projectId, 'geduc-rae-mobile');

  assert.throws(
    () =>
      parseEntrypointArgs([
        '--project-id',
        'geduc-rae-mobile',
      ]),
    /BUGRAE002E_ENTRYPOINT_STATUS_MODE_REQUIRED/u,
  );
});

test('projeto diferente e bloqueado', () => {
  assert.throws(
    () =>
      parseEntrypointArgs([
        '--status',
        '--project-id',
        'outro-projeto',
      ]),
    /BUGRAE002E_ENTRYPOINT_PROJECT_MISMATCH/u,
  );
});

test('todos os aliases de execucao remota estao bloqueados', () => {
  for (const token of [
    '--execute-remote',
    '--apply',
    '--seed',
  ]) {
    assert.throws(
      () =>
        parseEntrypointArgs([
          '--status',
          '--project-id',
          'geduc-rae-mobile',
          token,
        ]),
      /BUGRAE002E_ENTRYPOINT_REMOTE_EXECUTION_DISABLED/u,
    );
  }
});

test('status declara dupla trava pronta mas execucao remota indisponivel', () => {
  const status = buildEntrypointStatus();

  assert.equal(
    status.primaryAuthorizationPhraseDefined,
    true,
  );

  assert.equal(
    status.secondConfirmationPhraseDefined,
    true,
  );

  assert.equal(status.doubleLockImplemented, true);
  assert.equal(status.readinessRunnerImplemented, true);
  assert.equal(status.createOnlyExecutorImplemented, true);

  assert.equal(
    ENTRYPOINT_REMOTE_EXECUTION_AVAILABLE,
    false,
  );

  assert.equal(status.remoteExecutionAvailable, false);
  assert.equal(status.adcInvoked, false);
  assert.equal(status.networkInvoked, false);
  assert.equal(status.firestoreReads, 0);
  assert.equal(status.firestoreWrites, 0);
  assert.equal(status.seedExecuted, false);
});

test('runEntrypoint status nao executa nenhuma dependencia remota', async () => {
  const result = await runEntrypoint([
    '--status',
    '--project-id',
    'geduc-rae-mobile',
  ]);

  assert.equal(result.mode, 'seed-entrypoint-status');
  assert.equal(result.expected, 53);
  assert.equal(result.remoteExecutionAvailable, false);
  assert.equal(result.firestoreReads, 0);
  assert.equal(result.firestoreWrites, 0);
  assert.equal(result.seedExecuted, false);
});

test('entrypoint nao importa ADC, fetch ou adaptador Firestore', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_entrypoint.mjs',
    'utf8',
  );

  for (const pattern of [
    'mig001e4_adc',
    'fetch(',
    'projeto_catalog_firestore_create_only',
    'createProductionCatalogReadOnlyComposition',
    'executeDoubleLockedCatalogSeed(',
    "method: 'POST'",
    'method: "POST"',
    "method: 'PUT'",
    "method: 'PATCH'",
    "method: 'DELETE'",
  ]) {
    assert.equal(
      source.includes(pattern),
      false,
      pattern,
    );
  }
});

test('entrypoint possui CLI somente para status', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed_entrypoint.mjs',
    'utf8',
  );

  assert.equal(source.includes('process.argv'), true);
  assert.equal(source.includes('pathToFileURL'), true);

  assert.equal(
    source.includes(
      'BUGRAE002E_ENTRYPOINT_REMOTE_EXECUTION_DISABLED',
    ),
    true,
  );
});
