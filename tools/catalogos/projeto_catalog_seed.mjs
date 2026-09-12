import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

export const SEED_PROJECT_ID = 'geduc-rae-mobile';
export const SEED_COLLECTION = 'projetos';
export const EXPECTED_MANIFEST_VERSION = 'BUG-RAE-002E.2D.2A-v1';
export const EXPECTED_MANIFEST_SHA256 =
  'c109703987a86b6d22c34cb0c1072ce434bb1e1cfaf6f01a43d40630edb2a43c';
export const EXPECTED_RECORDS = 53;
export const DEFAULT_MANIFEST_PATH =
  'tools/catalogos/projetos_institucionais_2026.json';

const CATEGORY_COUNTS = Object.freeze({
  'Ação Educativa': 8,
  'Comando Educativo': 14,
  Curso: 6,
  Palestra: 16,
  'Roda de Conversa': 1,
  'Treinamento Institucional': 6,
  Workshop: 2,
});

function fail(code, details = null) {
  const error = new Error(code);
  if (details !== null) error.details = details;
  throw error;
}

export function sha256Hex(value) {
  return createHash('sha256').update(value).digest('hex');
}

export function canonicalize(value) {
  if (Array.isArray(value)) return value.map(canonicalize);

  if (value && typeof value === 'object') {
    const out = {};
    for (const key of Object.keys(value).sort()) {
      out[key] = canonicalize(value[key]);
    }
    return out;
  }

  return value;
}

export function canonicalJson(value) {
  return JSON.stringify(canonicalize(value));
}

function assertString(value, code, { nonEmpty = false } = {}) {
  if (typeof value !== 'string') fail(code);
  if (nonEmpty && value.trim() === '') fail(code);
}

function assertStringArray(value, code) {
  if (!Array.isArray(value) || value.some((item) => typeof item !== 'string')) {
    fail(code);
  }
}

function validateProject(project, index) {
  if (!project || typeof project !== 'object' || Array.isArray(project)) {
    fail('BUGRAE002E_SEED_PROJECT_NOT_OBJECT', { index });
  }

  assertString(project.id, 'BUGRAE002E_SEED_PROJECT_ID_INVALID', {
    nonEmpty: true,
  });
  assertString(project.nome, 'BUGRAE002E_SEED_PROJECT_NAME_INVALID', {
    nonEmpty: true,
  });
  assertString(project.codigo, 'BUGRAE002E_SEED_PROJECT_CODE_INVALID', {
    nonEmpty: true,
  });
  assertString(project.categoria, 'BUGRAE002E_SEED_PROJECT_CATEGORY_INVALID', {
    nonEmpty: true,
  });
  assertString(project.descricao, 'BUGRAE002E_SEED_PROJECT_DESCRIPTION_INVALID');
  assertString(project.objetivo, 'BUGRAE002E_SEED_PROJECT_OBJECTIVE_INVALID');
  assertString(project.publicoAlvo, 'BUGRAE002E_SEED_PROJECT_AUDIENCE_INVALID');

  assertStringArray(
    project.palavrasChave,
    'BUGRAE002E_SEED_PROJECT_KEYWORDS_INVALID',
  );
  assertStringArray(project.aliases, 'BUGRAE002E_SEED_PROJECT_ALIASES_INVALID');
  assertStringArray(
    project.regionalIds,
    'BUGRAE002E_SEED_PROJECT_REGIONALS_INVALID',
  );
  assertStringArray(project.equipeIds, 'BUGRAE002E_SEED_PROJECT_TEAMS_INVALID');

  if (project.regionalIds.length !== 0 || project.equipeIds.length !== 0) {
    fail('BUGRAE002E_SEED_STATIC_OPERATIONAL_LINK_FORBIDDEN', {
      id: project.id,
    });
  }

  if (!Number.isSafeInteger(project.ordem) || project.ordem !== index + 1) {
    fail('BUGRAE002E_SEED_PROJECT_ORDER_INVALID', {
      id: project.id,
      expected: index + 1,
      actual: project.ordem,
    });
  }

  if (project.ativo !== true) {
    fail('BUGRAE002E_SEED_PROJECT_ACTIVE_INVALID', { id: project.id });
  }

  return true;
}

export function validateManifestObject(manifest) {
  if (!manifest || typeof manifest !== 'object' || Array.isArray(manifest)) {
    fail('BUGRAE002E_SEED_MANIFEST_NOT_OBJECT');
  }

  if (manifest.manifestVersion !== EXPECTED_MANIFEST_VERSION) {
    fail('BUGRAE002E_SEED_MANIFEST_VERSION_MISMATCH');
  }

  if (manifest.expectedCount !== EXPECTED_RECORDS) {
    fail('BUGRAE002E_SEED_EXPECTED_COUNT_MISMATCH');
  }

  if (!Array.isArray(manifest.projetos)) {
    fail('BUGRAE002E_SEED_PROJECTS_NOT_ARRAY');
  }

  if (manifest.projetos.length !== EXPECTED_RECORDS) {
    fail('BUGRAE002E_SEED_PROJECT_COUNT_MISMATCH', {
      actual: manifest.projetos.length,
    });
  }

  const ids = new Set();
  const codes = new Set();
  const categories = {};

  manifest.projetos.forEach((project, index) => {
    validateProject(project, index);

    if (ids.has(project.id)) {
      fail('BUGRAE002E_SEED_DUPLICATE_ID', { id: project.id });
    }

    if (codes.has(project.codigo)) {
      fail('BUGRAE002E_SEED_DUPLICATE_CODE', { codigo: project.codigo });
    }

    ids.add(project.id);
    codes.add(project.codigo);
    categories[project.categoria] = (categories[project.categoria] ?? 0) + 1;
  });

  if (canonicalJson(categories) !== canonicalJson(CATEGORY_COUNTS)) {
    fail('BUGRAE002E_SEED_CATEGORY_COUNTS_MISMATCH', { categories });
  }

  return true;
}

export function loadManifestBuffer(buffer) {
  if (!Buffer.isBuffer(buffer)) {
    fail('BUGRAE002E_SEED_MANIFEST_BUFFER_REQUIRED');
  }

  const sha256 = sha256Hex(buffer);

  if (sha256 !== EXPECTED_MANIFEST_SHA256) {
    fail('BUGRAE002E_SEED_MANIFEST_HASH_MISMATCH', {
      expected: EXPECTED_MANIFEST_SHA256,
      actual: sha256,
    });
  }

  let manifest;
  try {
    manifest = JSON.parse(buffer.toString('utf8'));
  } catch {
    fail('BUGRAE002E_SEED_MANIFEST_JSON_INVALID');
  }

  validateManifestObject(manifest);

  return {
    manifest,
    sha256,
  };
}

export function assertSeedProjectId(projectId) {
  if (typeof projectId !== 'string' || projectId.trim() !== SEED_PROJECT_ID) {
    fail('BUGRAE002E_SEED_PROJECT_CONFIRMATION_MISMATCH');
  }

  return SEED_PROJECT_ID;
}

function payloadWithoutId(project) {
  const {
    id: _id,
    ...payload
  } = project;

  return payload;
}

export function buildSeedPlan({ manifest, projectId }) {
  assertSeedProjectId(projectId);
  validateManifestObject(manifest);

  return manifest.projetos.map((project) => {
    const basePayload = payloadWithoutId(project);
    const contentHash = sha256Hex(canonicalJson(basePayload));
    const payload = {
      ...basePayload,
      contentHash,
    };

    return Object.freeze({
      operation: 'CREATE_ONLY',
      collectionPath: SEED_COLLECTION,
      documentId: project.id,
      intendedContentHash: contentHash,
      payload: Object.freeze(payload),
    });
  });
}

export function summarizeSeedPlan(plan, manifestSha256) {
  if (!Array.isArray(plan) || plan.length !== EXPECTED_RECORDS) {
    fail('BUGRAE002E_SEED_PLAN_SIZE_INVALID');
  }

  if (
    typeof manifestSha256 !== 'string' ||
    manifestSha256 !== EXPECTED_MANIFEST_SHA256
  ) {
    fail('BUGRAE002E_SEED_PLAN_MANIFEST_HASH_INVALID');
  }

  const ids = plan.map((item) => item.documentId).sort();
  const hashes = plan.map((item) => item.intendedContentHash).sort();

  for (const item of plan) {
    if (
      item.operation !== 'CREATE_ONLY' ||
      item.collectionPath !== SEED_COLLECTION ||
      typeof item.documentId !== 'string' ||
      typeof item.intendedContentHash !== 'string' ||
      item.payload?.contentHash !== item.intendedContentHash
    ) {
      fail('BUGRAE002E_SEED_PLAN_ITEM_INVALID');
    }
  }

  return Object.freeze({
    mode: 'dry-run',
    projectId: SEED_PROJECT_ID,
    collection: SEED_COLLECTION,
    records: plan.length,
    manifestSha256,
    idSetSha256: sha256Hex(ids.join('\n')),
    contentSetSha256: sha256Hex(hashes.join('\n')),
    writesAvailable: false,
    firestoreReads: 0,
    firestoreWrites: 0,
    adcInvoked: false,
    gcloudInvoked: false,
  });
}

export function parseArgs(argv) {
  const args = {
    mode: 'dry-run',
    manifestPath: DEFAULT_MANIFEST_PATH,
    projectId: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];

    if (token === '--dry-run') {
      args.mode = 'dry-run';
      continue;
    }

    if (token === '--apply') {
      fail('BUGRAE002E_SEED_APPLY_NOT_AVAILABLE');
    }

    if (token === '--project-id') {
      const value = argv[index + 1];
      if (!value || value.startsWith('--')) {
        fail('BUGRAE002E_SEED_PROJECT_ID_ARGUMENT_REQUIRED');
      }
      args.projectId = value;
      index += 1;
      continue;
    }

    if (token === '--manifest') {
      const value = argv[index + 1];
      if (!value || value.startsWith('--')) {
        fail('BUGRAE002E_SEED_MANIFEST_ARGUMENT_REQUIRED');
      }
      args.manifestPath = value;
      index += 1;
      continue;
    }

    fail('BUGRAE002E_SEED_UNKNOWN_ARGUMENT', { token });
  }

  assertSeedProjectId(args.projectId);

  return Object.freeze(args);
}

export async function executeDryRun({
  manifestPath = DEFAULT_MANIFEST_PATH,
  projectId,
  readFileFn = readFile,
} = {}) {
  assertSeedProjectId(projectId);

  if (typeof readFileFn !== 'function') {
    fail('BUGRAE002E_SEED_READ_FILE_FN_REQUIRED');
  }

  const buffer = await readFileFn(manifestPath);
  const loaded = loadManifestBuffer(Buffer.from(buffer));
  const plan = buildSeedPlan({
    manifest: loaded.manifest,
    projectId,
  });

  return {
    plan,
    summary: summarizeSeedPlan(plan, loaded.sha256),
  };
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);

  const result = await executeDryRun({
    manifestPath: args.manifestPath,
    projectId: args.projectId,
  });

  process.stdout.write(`${JSON.stringify(result.summary, null, 2)}\n`);
  return result.summary;
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
