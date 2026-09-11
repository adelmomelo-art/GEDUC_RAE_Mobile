import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  EXECUTOR_EXPECTED_RECORDS,
  assertCreateOnlyWriterSurface,
  createInMemoryCreateOnlyWriter,
  executeCatalogCreateOnly,
  parseArgs,
  preflightCreateOnlyTargets,
} from '../tools/catalogos/projeto_catalog_executor.mjs';

import {
  SEED_PROJECT_ID,
  executeDryRun,
} from '../tools/catalogos/projeto_catalog_seed.mjs';

test('CLI exige simulacao local e project-id explicito', () => {
  assert.throws(
    () => parseArgs(['--project-id', SEED_PROJECT_ID]),
    /BUGRAE002E_EXECUTOR_SIMULATION_MODE_REQUIRED/u,
  );

  assert.throws(
    () =>
      parseArgs([
        '--simulate-empty',
        '--project-id',
        'outro-projeto',
      ]),
    /BUGRAE002E_EXECUTOR_PROJECT_CONFIRMATION_MISMATCH/u,
  );

  const parsed = parseArgs([
    '--simulate-empty',
    '--project-id',
    SEED_PROJECT_ID,
  ]);

  assert.equal(parsed.mode, 'local-simulation');
  assert.equal(parsed.projectId, SEED_PROJECT_ID);
});

test('apply e modos remotos permanecem bloqueados', () => {
  for (const token of [
    '--apply',
    '--remote',
    '--remote-apply',
  ]) {
    assert.throws(
      () =>
        parseArgs([
          '--simulate-empty',
          '--project-id',
          SEED_PROJECT_ID,
          token,
        ]),
      /BUGRAE002E_EXECUTOR_REMOTE_APPLY_FORBIDDEN/u,
    );
  }
});

test('writer precisa ter superficie estreita create-only', () => {
  const safe = {
    async getExistingContentHash() {
      return {
        exists: false,
        contentHash: null,
      };
    },
    async createOnly() {
      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  assert.equal(assertCreateOnlyWriterSurface(safe), true);

  assert.throws(
    () =>
      assertCreateOnlyWriterSurface({
        ...safe,
        async update() {},
      }),
    /BUGRAE002E_EXECUTOR_FORBIDDEN_WRITER_METHOD/u,
  );

  assert.throws(
    () =>
      assertCreateOnlyWriterSurface({
        ...safe,
        async createDocument() {},
      }),
    /BUGRAE002E_EXECUTOR_FORBIDDEN_WRITER_METHOD/u,
  );
});

test('preflight de colecao vazia verifica 53 antes de escrever', async () => {
  const local = await executeDryRun({
    projectId: SEED_PROJECT_ID,
  });

  let reads = 0;
  let writes = 0;

  const writer = {
    async getExistingContentHash() {
      reads += 1;
      return {
        exists: false,
        contentHash: null,
      };
    },
    async createOnly() {
      writes += 1;
      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  const result = await preflightCreateOnlyTargets({
    writer,
    plan: local.plan,
  });

  assert.equal(result.ready, true);
  assert.equal(result.checked, EXECUTOR_EXPECTED_RECORDS);
  assert.equal(result.missing, EXECUTOR_EXPECTED_RECORDS);
  assert.equal(result.blockers.length, 0);
  assert.equal(reads, EXECUTOR_EXPECTED_RECORDS);
  assert.equal(writes, 0);
});

test('hash divergente bloqueia antes de qualquer createOnly', async () => {
  let reads = 0;
  let writes = 0;

  const writer = {
    async getExistingContentHash() {
      reads += 1;

      if (reads === 7) {
        return {
          exists: true,
          contentHash: 'hash-divergente',
        };
      }

      return {
        exists: false,
        contentHash: null,
      };
    },
    async createOnly() {
      writes += 1;
      throw new Error('CREATE_MUST_NOT_RUN');
    },
  };

  await assert.rejects(
    () =>
      executeCatalogCreateOnly({
        writer,
        projectId: SEED_PROJECT_ID,
      }),
    /BUGRAE002E_EXECUTOR_PREFLIGHT_BLOCKED/u,
  );

  assert.equal(reads, EXECUTOR_EXPECTED_RECORDS);
  assert.equal(writes, 0);
});

test('simulacao vazia executa 53 CREATE_ONLY', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  const result = await executeCatalogCreateOnly({
    writer,
    projectId: SEED_PROJECT_ID,
  });

  assert.equal(result.completed, 53);
  assert.equal(result.created, 53);
  assert.equal(result.unchanged, 0);
  assert.equal(result.writerWrites, 53);
  assert.equal(writer.simulatedCreates, 53);
  assert.equal(writer.createOnlyCalls, 53);
});

test('rerun da simulacao converge para 53 unchanged', async () => {
  const writer = createInMemoryCreateOnlyWriter();

  const first = await executeCatalogCreateOnly({
    writer,
    projectId: SEED_PROJECT_ID,
  });

  const second = await executeCatalogCreateOnly({
    writer,
    projectId: SEED_PROJECT_ID,
  });

  assert.equal(first.created, 53);
  assert.equal(second.created, 0);
  assert.equal(second.unchanged, 53);
  assert.equal(writer.simulatedCreates, 53);
  assert.equal(writer.createOnlyCalls, 106);
});

test('executor para na primeira falha operacional', async () => {
  let createCalls = 0;

  const writer = {
    async getExistingContentHash() {
      return {
        exists: false,
        contentHash: null,
      };
    },

    async createOnly() {
      createCalls += 1;

      if (createCalls === 5) {
        throw new Error('SIMULATED_WRITE_FAILURE');
      }

      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  await assert.rejects(
    () =>
      executeCatalogCreateOnly({
        writer,
        projectId: SEED_PROJECT_ID,
      }),
    (error) => {
      assert.equal(
        error.message,
        'BUGRAE002E_EXECUTOR_STOPPED',
      );
      assert.equal(error.details.completed, 4);
      return true;
    },
  );

  assert.equal(createCalls, 5);
});

test('outcome inseguro e bloqueado', async () => {
  let createCalls = 0;

  const writer = {
    async getExistingContentHash() {
      return {
        exists: false,
        contentHash: null,
      };
    },

    async createOnly() {
      createCalls += 1;

      if (createCalls === 3) {
        return {
          outcome: 'changed_pending_review',
          wrote: false,
        };
      }

      return {
        outcome: 'created',
        wrote: true,
      };
    },
  };

  await assert.rejects(
    () =>
      executeCatalogCreateOnly({
        writer,
        projectId: SEED_PROJECT_ID,
      }),
    /BUGRAE002E_EXECUTOR_OUTCOME_BLOCKED/u,
  );

  assert.equal(createCalls, 3);
});

test('modulo executor nao importa REST, ADC ou preflight remoto', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_executor.mjs',
    'utf8',
  );

  assert.equal(source.includes('mig001e3_firestore_rest'), false);
  assert.equal(source.includes('mig001e4_adc'), false);
  assert.equal(source.includes('projeto_catalog_preflight'), false);
  assert.equal(source.includes('fetch('), false);
  assert.equal(source.includes('application-default'), false);
  assert.equal(source.includes('gcloud.cmd'), false);
});
