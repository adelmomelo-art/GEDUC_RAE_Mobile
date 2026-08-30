#!/usr/bin/env node

import { readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import {
  OFFICIAL_SOURCE,
  SOURCE_FIELDS,
  buildWritePlan,
  selectDeterministicPilot,
  summarizeMetrics,
  transformRecord,
  validateSourceRecords,
} from './mig001e3_core.mjs';

export function parseArgs(argv) {
  const args = {
    mode: 'dry-run',
    sourcePath: null,
    reportPath: null,
    batchId: 'dry-run-preview',
    pilot: null,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];

    if (token === '--dry-run') {
      args.mode = 'dry-run';
      continue;
    }

    if (token === '--apply') {
      args.mode = 'apply';
      continue;
    }

    if (token === '--source') {
      args.sourcePath = argv[++i] ?? null;
      continue;
    }

    if (token === '--report') {
      args.reportPath = argv[++i] ?? null;
      continue;
    }

    if (token === '--batch-id') {
      args.batchId = argv[++i] ?? null;
      continue;
    }

    if (token === '--pilot') {
      const raw = argv[++i];
      args.pilot = raw === undefined ? Number.NaN : Number(raw);
      continue;
    }

    throw new Error(`MIG001E3_UNKNOWN_ARGUMENT:${token}`);
  }

  if (!args.sourcePath) {
    throw new Error('MIG001E3_SOURCE_REQUIRED');
  }

  if (args.mode === 'apply') {
    // B1 e deliberadamente incapaz de escrever.
    // O writer autenticado/create-only entra somente no MIG-001E3-B2.
    throw new Error('MIG001E3_APPLY_LOCKED_UNTIL_E4');
  }

  if (
    args.pilot !== null &&
    (!Number.isSafeInteger(args.pilot) || args.pilot < 1 || args.pilot > 10)
  ) {
    throw new Error('MIG001E3_INVALID_PILOT_SIZE');
  }

  return args;
}

function sha256Buffer(buffer) {
  return createHash('sha256').update(buffer).digest('hex');
}

export async function runDryRun(args) {
  const sourceBuffer = await readFile(args.sourcePath);
  const sourceSha256 = sha256Buffer(sourceBuffer);

  if (sourceSha256 !== OFFICIAL_SOURCE.expectedSha256) {
    throw new Error(
      `MIG001E3_SOURCE_SHA_MISMATCH:${sourceSha256}`,
    );
  }

  const records = JSON.parse(sourceBuffer.toString('utf8'));

  if (!Array.isArray(records)) {
    throw new Error('MIG001E3_SOURCE_NOT_ARRAY');
  }

  if (records.length !== OFFICIAL_SOURCE.expectedRecords) {
    throw new Error(
      `MIG001E3_SOURCE_COUNT_MISMATCH:${records.length}`,
    );
  }

  validateSourceRecords(records);

  const transformed = records.map((record) => transformRecord(record));
  const uniqueIds = new Set(transformed.map((item) => item.id));

  if (uniqueIds.size !== transformed.length) {
    throw new Error('MIG001E3_DUPLICATE_HISTORICAL_ID');
  }

  const selected =
    args.pilot === null
      ? transformed
      : selectDeterministicPilot(transformed, records, args.pilot);

  const writePlan = buildWritePlan(selected, args.batchId);
  const targetRoots = [
    ...new Set(writePlan.map((item) => item.collectionPath.split('/')[0])),
  ].sort();

  const summary = {
    migration: 'MIG-001E3-B1',
    mode: 'dry-run',
    source: {
      sha256: sourceSha256,
      records: records.length,
      fields: SOURCE_FIELDS.length,
      spreadsheetId: OFFICIAL_SOURCE.spreadsheetId,
      sheetName: OFFICIAL_SOURCE.sheetName,
    },
    transformed: {
      records: transformed.length,
      uniqueHistoricalIds: uniqueIds.size,
      selectedRecords: selected.length,
      rawResponderEmailPersisted: false,
      numeroRAEGenerated: false,
      countersTouched: false,
    },
    metrics: summarizeMetrics(transformed),
    plan: {
      operations: writePlan.length,
      targetRoots,
      applyLocked: true,
      firestoreAccessed: false,
      firestoreWrites: 0,
    },
  };

  if (args.reportPath) {
    await writeFile(
      args.reportPath,
      `${JSON.stringify(summary, null, 2)}\n`,
      'utf8',
    );
  }

  return summary;
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  const summary = await runDryRun(args);
  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
  return summary;
}

const isDirectExecution =
  process.argv[1] &&
  new URL(import.meta.url).pathname
    .replace(/^\/([A-Za-z]:)/u, '$1')
    .replace(/\\/gu, '/')
    .toLowerCase() ===
    process.argv[1].replace(/\\/gu, '/').toLowerCase();

if (isDirectExecution) {
  main().catch((error) => {
    process.stderr.write(`MIG-001E3 ERROR: ${error.message}\n`);
    process.exitCode = 1;
  });
}