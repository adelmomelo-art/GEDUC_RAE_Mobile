import {
  SEED_AUTHORIZATION_PHRASE,
  runProtectedSeedReadiness,
  validateExplicitSeedAuthorization,
} from './projeto_catalog_seed_readiness_runner.mjs';

import {
  assertCreateOnlyWriterSurface,
  executeCatalogCreateOnly,
} from './projeto_catalog_executor.mjs';

export const SEED_EXECUTION_CONFIRMATION_PHRASE =
  'CONFIRMO EXECUCAO REMOTA CREATE_ONLY DOS 53 PROJETOS';

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

export function validateSeedExecutionConfirmation(value) {
  return normalize(value) === SEED_EXECUTION_CONFIRMATION_PHRASE;
}

function assertDoubleAuthorization({
  explicitAuthorization,
  executionConfirmation,
}) {
  if (!validateExplicitSeedAuthorization(explicitAuthorization)) {
    fail('BUGRAE002E_EXECUTION_PRIMARY_AUTHORIZATION_REQUIRED');
  }

  if (!validateSeedExecutionConfirmation(executionConfirmation)) {
    fail('BUGRAE002E_EXECUTION_SECOND_CONFIRMATION_REQUIRED');
  }

  return true;
}

function assertReadinessResult(result) {
  if (!result || typeof result !== 'object') {
    fail('BUGRAE002E_EXECUTION_READINESS_RESULT_REQUIRED');
  }

  if (
    result.mode !== 'protected-seed-readiness' ||
    result.readyForExplicitAuthorization !== true ||
    result.authorizationProvided !== true ||
    result.remoteWriteEnabled !== false ||
    result.seedExecutionAvailable !== false ||
    result.seedExecuted !== false ||
    result.reason !== 'GATES_READY_WRITE_STILL_DISABLED'
  ) {
    fail('BUGRAE002E_EXECUTION_READINESS_BLOCKED');
  }

  if (
    !result.ruleset ||
    result.ruleset.valid !== true ||
    result.ruleset.hashMatches !== true
  ) {
    fail('BUGRAE002E_EXECUTION_RULESET_GATE_BLOCKED');
  }

  if (
    !result.preflight ||
    result.preflight.valid !== true ||
    result.preflight.blockers.length !== 0
  ) {
    fail('BUGRAE002E_EXECUTION_PREFLIGHT_GATE_BLOCKED');
  }

  return true;
}

export async function executeDoubleLockedCatalogSeed({
  readinessArgs,
  writeWriter,
  explicitAuthorization,
  executionConfirmation,
}) {
  assertDoubleAuthorization({
    explicitAuthorization,
    executionConfirmation,
  });

  if (!readinessArgs || typeof readinessArgs !== 'object') {
    fail('BUGRAE002E_EXECUTION_READINESS_ARGS_REQUIRED');
  }

  assertCreateOnlyWriterSurface(writeWriter);

  const readiness =
    await runProtectedSeedReadiness({
      ...readinessArgs,
      explicitAuthorization,
    });

  assertReadinessResult(readiness);

  const execution =
    await executeCatalogCreateOnly({
      writer: writeWriter,
      projectId: readiness.projectId,
    });

  if (
    execution.expected !== 53 ||
    execution.completed !== 53 ||
    execution.preflight?.ready !== true ||
    execution.preflight?.blockers?.length !== 0 ||
    execution.created + execution.unchanged !== 53
  ) {
    fail('BUGRAE002E_EXECUTION_RESULT_INVALID', {
      expected: execution.expected,
      completed: execution.completed,
      created: execution.created,
      unchanged: execution.unchanged,
    });
  }

  return Object.freeze({
    mode: 'double-locked-create-only-seed',
    projectId: readiness.projectId,
    collection: readiness.collection,
    primaryAuthorization:
      explicitAuthorization === SEED_AUTHORIZATION_PHRASE,
    secondConfirmation: true,
    readiness,
    execution: {
      expected: execution.expected,
      completed: execution.completed,
      created: execution.created,
      unchanged: execution.unchanged,
      writerWrites: execution.writerWrites,
    },
    seedExecuted: true,
  });
}
