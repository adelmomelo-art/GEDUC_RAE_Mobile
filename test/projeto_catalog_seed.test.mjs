import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

import {
  DEFAULT_MANIFEST_PATH,
  EXPECTED_MANIFEST_SHA256,
  EXPECTED_RECORDS,
  SEED_COLLECTION,
  SEED_PROJECT_ID,
  buildSeedPlan,
  executeDryRun,
  loadManifestBuffer,
  parseArgs,
  summarizeSeedPlan,
} from '../tools/catalogos/projeto_catalog_seed.mjs';

async function officialBuffer() {
  return readFile(DEFAULT_MANIFEST_PATH);
}

test('CLI exige project-id explicito e correto', () => {
  assert.throws(
    () => parseArgs(['--dry-run']),
    /BUGRAE002E_SEED_PROJECT_CONFIRMATION_MISMATCH/u,
  );

  assert.throws(
    () => parseArgs(['--project-id', 'outro-projeto']),
    /BUGRAE002E_SEED_PROJECT_CONFIRMATION_MISMATCH/u,
  );

  const args = parseArgs([
    '--dry-run',
    '--project-id',
    SEED_PROJECT_ID,
  ]);

  assert.equal(args.mode, 'dry-run');
  assert.equal(args.projectId, SEED_PROJECT_ID);
  assert.equal(args.manifestPath, DEFAULT_MANIFEST_PATH);
});

test('--apply permanece indisponivel nesta etapa', () => {
  assert.throws(
    () =>
      parseArgs([
        '--project-id',
        SEED_PROJECT_ID,
        '--apply',
      ]),
    /BUGRAE002E_SEED_APPLY_NOT_AVAILABLE/u,
  );
});

test('manifesto oficial exige hash imutavel e exatamente 53 registros', async () => {
  const loaded = loadManifestBuffer(await officialBuffer());

  assert.equal(loaded.sha256, EXPECTED_MANIFEST_SHA256);
  assert.equal(loaded.manifest.projetos.length, EXPECTED_RECORDS);
});

test('qualquer alteracao de bytes no manifesto falha fechado', async () => {
  const original = await officialBuffer();
  const changed = Buffer.concat([original, Buffer.from(' ')]);

  assert.throws(
    () => loadManifestBuffer(changed),
    /BUGRAE002E_SEED_MANIFEST_HASH_MISMATCH/u,
  );
});

test('plano contem somente 53 CREATE_ONLY para projetos', async () => {
  const { manifest, sha256 } = loadManifestBuffer(await officialBuffer());
  const plan = buildSeedPlan({
    manifest,
    projectId: SEED_PROJECT_ID,
  });

  assert.equal(plan.length, 53);
  assert.equal(
    plan.every(
      (item) =>
        item.operation === 'CREATE_ONLY' &&
        item.collectionPath === SEED_COLLECTION &&
        item.payload.contentHash === item.intendedContentHash,
    ),
    true,
  );

  const summary = summarizeSeedPlan(plan, sha256);

  assert.equal(summary.records, 53);
  assert.equal(summary.writesAvailable, false);
  assert.equal(summary.firestoreReads, 0);
  assert.equal(summary.firestoreWrites, 0);
});

test('contentHash e plano sao deterministicos', async () => {
  const { manifest } = loadManifestBuffer(await officialBuffer());

  const first = buildSeedPlan({
    manifest,
    projectId: SEED_PROJECT_ID,
  });

  const second = buildSeedPlan({
    manifest,
    projectId: SEED_PROJECT_ID,
  });

  assert.deepEqual(first, second);
});

test('documentId nao e persistido dentro do payload', async () => {
  const { manifest } = loadManifestBuffer(await officialBuffer());
  const plan = buildSeedPlan({
    manifest,
    projectId: SEED_PROJECT_ID,
  });

  for (const item of plan) {
    assert.equal(Object.hasOwn(item.payload, 'id'), false);
    assert.equal(item.documentId.length > 0, true);
  }
});

test('dry-run usa somente reader injetado e nao oferece writer', async () => {
  const buffer = await officialBuffer();
  const calls = [];

  const result = await executeDryRun({
    manifestPath: 'virtual.json',
    projectId: SEED_PROJECT_ID,
    readFileFn: async (path) => {
      calls.push(path);
      return buffer;
    },
  });

  assert.deepEqual(calls, ['virtual.json']);
  assert.equal(result.summary.mode, 'dry-run');
  assert.equal(result.summary.firestoreReads, 0);
  assert.equal(result.summary.firestoreWrites, 0);
  assert.equal(result.summary.adcInvoked, false);
  assert.equal(result.summary.gcloudInvoked, false);
  assert.equal(typeof result.writer, 'undefined');
});

test('modulo local nao importa infraestrutura remota ou ADC', async () => {
  const source = await readFile(
    'tools/catalogos/projeto_catalog_seed.mjs',
    'utf8',
  );

  assert.equal(source.includes('mig001e3_firestore_rest'), false);
  assert.equal(source.includes('mig001e4_adc'), false);
  assert.equal(source.includes('fetch('), false);
  assert.equal(source.includes('application-default'), false);
  assert.equal(source.includes('gcloud'), true); // apenas flags de resumo, sem invocacao.
});
