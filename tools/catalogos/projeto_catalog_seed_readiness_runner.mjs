export const SEED_READINESS_PROJECT_ID = 'geduc-rae-mobile';
export const SEED_READINESS_COLLECTION = 'projetos';
export const SEED_READINESS_EXPECTED_DOCUMENTS = 53;
export const SEED_READINESS_EXPECTED_BRANCH =
  'fix/bug-rae-002-acl-operacional-dinamica';

export const SEED_READINESS_MANIFEST_SHA256 =
  'C109703987A86B6D22C34CB0C1072CE434BB1E1CFAF6F01A43D40630EDB2A43C';

export const SEED_READINESS_RULES_SHA256 =
  '4546EE8797F6120FFCFEE9ACD2B0A8DA695F3C8E2DCA341A5612F97B95D6769F';

export const SEED_AUTHORIZATION_PHRASE =
  'AUTORIZO SEED CREATE_ONLY DOS 53 PROJETOS';

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

function normalize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function normalizeHash(value) {
  return normalize(value).toUpperCase();
}

export function assertStaticSeedReadinessInputs({
  projectId,
  collection,
  branch,
  head,
  expectedHead,
  workingTreeClean,
  manifestSha256,
}) {
  if (normalize(projectId) !== SEED_READINESS_PROJECT_ID) {
    fail('BUGRAE002E_READINESS_PROJECT_MISMATCH');
  }

  if (normalize(collection) !== SEED_READINESS_COLLECTION) {
    fail('BUGRAE002E_READINESS_COLLECTION_MISMATCH');
  }

  if (normalize(branch) !== SEED_READINESS_EXPECTED_BRANCH) {
    fail('BUGRAE002E_READINESS_BRANCH_MISMATCH');
  }

  if (
    normalize(head) === '' ||
    normalize(expectedHead) === '' ||
    normalize(head) !== normalize(expectedHead)
  ) {
    fail('BUGRAE002E_READINESS_HEAD_MISMATCH');
  }

  if (workingTreeClean !== true) {
    fail('BUGRAE002E_READINESS_WORKTREE_DIRTY');
  }

  if (
    normalizeHash(manifestSha256) !==
    SEED_READINESS_MANIFEST_SHA256
  ) {
    fail('BUGRAE002E_READINESS_MANIFEST_HASH_MISMATCH');
  }

  return true;
}

export function classifyReadOnlyPreflight(preflight) {
  if (!preflight || typeof preflight !== 'object') {
    fail('BUGRAE002E_READINESS_PREFLIGHT_REQUIRED');
  }

  const blockers = Array.isArray(preflight.blockers)
    ? preflight.blockers
    : [];

  const valid =
    preflight.mode === 'remote-read-only-composition' &&
    preflight.projectId === SEED_READINESS_PROJECT_ID &&
    preflight.collection === SEED_READINESS_COLLECTION &&
    preflight.expected === SEED_READINESS_EXPECTED_DOCUMENTS &&
    preflight.checked === SEED_READINESS_EXPECTED_DOCUMENTS &&
    preflight.ready === true &&
    blockers.length === 0 &&
    preflight.remoteWriteEnabled === false &&
    preflight.firestoreWrites === 0;

  return Object.freeze({
    valid,
    blockers,
    missing:
      Number.isInteger(preflight.missing)
        ? preflight.missing
        : null,
    unchanged:
      Number.isInteger(preflight.unchanged)
        ? preflight.unchanged
        : null,
  });
}

export function classifyRulesetAudit(ruleset) {
  if (!ruleset || typeof ruleset !== 'object') {
    fail('BUGRAE002E_READINESS_RULESET_REQUIRED');
  }

  const projectMatches =
    normalize(ruleset.projectId) ===
    SEED_READINESS_PROJECT_ID;

  const hashMatches =
    normalizeHash(ruleset.normalizedSha256) ===
    SEED_READINESS_RULES_SHA256;

  const activeRulesetPresent =
    normalize(ruleset.rulesetName) !== '';

  return Object.freeze({
    valid:
      projectMatches &&
      hashMatches &&
      activeRulesetPresent,
    projectMatches,
    hashMatches,
    activeRulesetPresent,
    rulesetName:
      normalize(ruleset.rulesetName) || null,
    normalizedSha256:
      normalizeHash(ruleset.normalizedSha256) || null,
  });
}

export function validateExplicitSeedAuthorization(value) {
  return normalize(value) === SEED_AUTHORIZATION_PHRASE;
}

export async function runProtectedSeedReadiness({
  projectId,
  collection,
  branch,
  head,
  expectedHead,
  workingTreeClean,
  manifestSha256,
  readActiveRuleset,
  readOnlyComposition,
  explicitAuthorization = null,
}) {
  assertStaticSeedReadinessInputs({
    projectId,
    collection,
    branch,
    head,
    expectedHead,
    workingTreeClean,
    manifestSha256,
  });

  if (typeof readActiveRuleset !== 'function') {
    fail('BUGRAE002E_READINESS_RULESET_READER_REQUIRED');
  }

  if (
    !readOnlyComposition ||
    typeof readOnlyComposition.runReadOnlyPreflight !== 'function'
  ) {
    fail('BUGRAE002E_READINESS_COMPOSITION_REQUIRED');
  }

  if (readOnlyComposition.remoteWriteEnabled !== false) {
    fail('BUGRAE002E_READINESS_COMPOSITION_WRITE_NOT_DISABLED');
  }

  const ruleset =
    classifyRulesetAudit(
      await readActiveRuleset(),
    );

  if (!ruleset.valid) {
    return Object.freeze({
      mode: 'protected-seed-readiness',
      projectId,
      collection,
      readyForExplicitAuthorization: false,
      authorizationProvided:
        validateExplicitSeedAuthorization(
          explicitAuthorization,
        ),
      remoteWriteEnabled: false,
      seedExecutionAvailable: false,
      seedExecuted: false,
      reason: 'RULESET_GATE_BLOCKED',
      ruleset,
      preflight: null,
    });
  }

  const preflight =
    classifyReadOnlyPreflight(
      await readOnlyComposition.runReadOnlyPreflight(),
    );

  const authorizationProvided =
    validateExplicitSeedAuthorization(
      explicitAuthorization,
    );

  return Object.freeze({
    mode: 'protected-seed-readiness',
    projectId,
    collection,
    readyForExplicitAuthorization:
      preflight.valid,
    authorizationProvided,
    remoteWriteEnabled: false,
    seedExecutionAvailable: false,
    seedExecuted: false,
    reason:
      preflight.valid
        ? 'GATES_READY_WRITE_STILL_DISABLED'
        : 'PREFLIGHT_GATE_BLOCKED',
    ruleset,
    preflight,
  });
}
