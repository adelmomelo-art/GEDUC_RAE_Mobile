import { pathToFileURL } from 'node:url';

import {
  SEED_AUTHORIZATION_PHRASE,
} from './projeto_catalog_seed_readiness_runner.mjs';

import {
  SEED_EXECUTION_CONFIRMATION_PHRASE,
} from './projeto_catalog_seed_execution_guard.mjs';

export const ENTRYPOINT_PROJECT_ID = 'geduc-rae-mobile';
export const ENTRYPOINT_COLLECTION = 'projetos';
export const ENTRYPOINT_EXPECTED = 53;
export const ENTRYPOINT_REMOTE_EXECUTION_AVAILABLE = false;

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

export function parseEntrypointArgs(argv) {
  const args = {
    mode: null,
    projectId: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];

    if (token === '--status') {
      if (args.mode !== null) {
        fail('BUGRAE002E_ENTRYPOINT_MULTIPLE_MODES');
      }

      args.mode = 'status';
      continue;
    }

    if (
      token === '--execute-remote' ||
      token === '--apply' ||
      token === '--seed'
    ) {
      fail('BUGRAE002E_ENTRYPOINT_REMOTE_EXECUTION_DISABLED');
    }

    if (token === '--project-id') {
      const value = argv[index + 1];

      if (!value || value.startsWith('--')) {
        fail('BUGRAE002E_ENTRYPOINT_PROJECT_ID_REQUIRED');
      }

      args.projectId = value;
      index += 1;
      continue;
    }

    fail('BUGRAE002E_ENTRYPOINT_UNKNOWN_ARGUMENT', {
      token,
    });
  }

  if (args.mode !== 'status') {
    fail('BUGRAE002E_ENTRYPOINT_STATUS_MODE_REQUIRED');
  }

  if (normalize(args.projectId) !== ENTRYPOINT_PROJECT_ID) {
    fail('BUGRAE002E_ENTRYPOINT_PROJECT_MISMATCH');
  }

  return Object.freeze(args);
}

export function buildEntrypointStatus() {
  return Object.freeze({
    mode: 'seed-entrypoint-status',
    projectId: ENTRYPOINT_PROJECT_ID,
    collection: ENTRYPOINT_COLLECTION,
    expected: ENTRYPOINT_EXPECTED,
    primaryAuthorizationPhraseDefined:
      normalize(SEED_AUTHORIZATION_PHRASE) !== '',
    secondConfirmationPhraseDefined:
      normalize(SEED_EXECUTION_CONFIRMATION_PHRASE) !== '',
    doubleLockImplemented: true,
    readinessRunnerImplemented: true,
    createOnlyExecutorImplemented: true,
    remoteExecutionAvailable:
      ENTRYPOINT_REMOTE_EXECUTION_AVAILABLE,
    adcInvoked: false,
    networkInvoked: false,
    firestoreReads: 0,
    firestoreWrites: 0,
    seedExecuted: false,
  });
}

export async function runEntrypoint(argv) {
  const args = parseEntrypointArgs(argv);

  if (args.mode !== 'status') {
    fail('BUGRAE002E_ENTRYPOINT_MODE_NOT_IMPLEMENTED');
  }

  return buildEntrypointStatus();
}

export async function main(argv = process.argv.slice(2)) {
  const result = await runEntrypoint(argv);

  process.stdout.write(
    `${JSON.stringify(result, null, 2)}\n`,
  );

  return result;
}

const direct =
  process.argv[1] &&
  import.meta.url === pathToFileURL(process.argv[1]).href;

if (direct) {
  main().catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
