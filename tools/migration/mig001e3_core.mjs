import { createHash } from 'node:crypto';

export const SOURCE_FIELDS = Object.freeze([
  'Carimbo de data/hora',
  'Endereço de e-mail',
  'Data',
  'Turno',
  'Regional',
  'Endereço',
  'Nome da Ação',
  'Tipo de Ação ',
  'Formação',
  'Público',
  'Tipo de Participação',
  'Foco Temático',
  'Perfil de Usuário',
  'Instituição ou Empresa Parceira',
  'Pessoas Alcançadas',
  'Veículos Abordados',
  'Credenciais Emitidas',
  'Coordenador / Responsável',
  'Agentes de Trânsito',
  'Equipe Terceirizada',
  'Material Utilizado',
  'Observações',
]);

export const OFFICIAL_SOURCE = Object.freeze({
  spreadsheetId: '1HgTRMpBPItqoAbRKUujQs7481HhjPZfhsuM4s80jYJE',
  sheetName: 'Respostas ao formulário 1',
  expectedSha256:
    '19a80508161dea5a3fe5d610a8a95ee9470e28e9536c56c492840a7bc7a20a00',
  expectedRecords: 1051,
  policyVersion: 'MIG-001D-R4',
});

export const ALLOWED_WRITE_ROOTS = Object.freeze([
  'migration_google_forms_staging',
  'migration_batches',
  'acoes_historicas',
]);

export const DENIED_WRITE_ROOTS = Object.freeze([
  'acoes',
  'contadores',
  'usuarios',
  'equipe_operacional',
  'coordenadores',
  'domains',
  'tipos_acoes',
  'regionais',
  'equipes',
  'projetos',
  'materiais',
]);

function hasOwn(record, field) {
  return Object.prototype.hasOwnProperty.call(record, field);
}

export function sha256Hex(value) {
  return createHash('sha256').update(String(value), 'utf8').digest('hex');
}

export function normalizeText(value) {
  if (value === null || value === undefined) return '';
  return String(value)
    .normalize('NFKC')
    .replace(/\s+/gu, ' ')
    .trim();
}

export function normalizeForIdentity(value) {
  return normalizeText(value).toLocaleLowerCase('pt-BR');
}

export function canonicalize(value) {
  if (Array.isArray(value)) {
    return value.map(canonicalize);
  }

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

export function parseStrictMetric(value) {
  if (typeof value === 'number') {
    if (Number.isSafeInteger(value) && value >= 0) {
      return { value, known: true, raw: null, sourceKind: 'native_integer' };
    }

    return {
      value: null,
      known: false,
      raw: String(value),
      sourceKind: 'non_integer_number',
    };
  }

  if (value === null || value === undefined) {
    return { value: null, known: false, raw: null, sourceKind: 'missing' };
  }

  const raw = normalizeText(value);

  if (raw === '') {
    return { value: null, known: false, raw: null, sourceKind: 'missing' };
  }

  // Somente texto integralmente numerico e inequívoco e promovido.
  // Nao converte "10 agentes", "aprox. 20", "1 e 2", nomes ou empresas.
  if (/^\d+$/u.test(raw)) {
    const parsed = Number(raw);

    if (Number.isSafeInteger(parsed) && parsed >= 0) {
      return {
        value: parsed,
        known: true,
        raw,
        sourceKind: 'numeric_text',
      };
    }
  }

  return { value: null, known: false, raw, sourceKind: 'semantic_or_ambiguous' };
}

export function validateRecordSchema(record) {
  if (!record || typeof record !== 'object' || Array.isArray(record)) {
    throw new Error('MIG001E3_SCHEMA_RECORD_NOT_OBJECT');
  }

  const keys = Object.keys(record);
  const missing = SOURCE_FIELDS.filter((field) => !hasOwn(record, field));
  const extra = keys.filter((key) => !SOURCE_FIELDS.includes(key));

  if (missing.length > 0 || extra.length > 0) {
    const error = new Error('MIG001E3_SCHEMA_MISMATCH');
    error.details = { missing, extra };
    throw error;
  }

  return true;
}

export function validateSourceRecords(records) {
  if (!Array.isArray(records)) {
    throw new Error('MIG001E3_SOURCE_NOT_ARRAY');
  }

  records.forEach(validateRecordSchema);
  return true;
}

function value(record, field) {
  return record[field];
}

export function sourceIdentityMaterial(record, source = OFFICIAL_SOURCE) {
  validateRecordSchema(record);

  return [
    source.spreadsheetId,
    source.sheetName,
    normalizeForIdentity(value(record, 'Carimbo de data/hora')),
    normalizeForIdentity(value(record, 'Endereço de e-mail')),
    normalizeForIdentity(value(record, 'Data')),
    normalizeForIdentity(value(record, 'Nome da Ação')),
    normalizeForIdentity(value(record, 'Endereço')),
  ].join('\u001f');
}

export function buildSourceIdentityHash(record, source = OFFICIAL_SOURCE) {
  return sha256Hex(sourceIdentityMaterial(record, source));
}

export function buildHistoricalId(record, source = OFFICIAL_SOURCE) {
  return `gf_${buildSourceIdentityHash(record, source)}`;
}

function metricBundle(record) {
  return {
    pessoasAlcancadas: parseStrictMetric(value(record, 'Pessoas Alcançadas')),
    veiculosAbordados: parseStrictMetric(value(record, 'Veículos Abordados')),
    credenciaisEmitidas: parseStrictMetric(value(record, 'Credenciais Emitidas')),
    agentesTransito: parseStrictMetric(value(record, 'Agentes de Trânsito')),
    equipeTerceirizada: parseStrictMetric(value(record, 'Equipe Terceirizada')),
  };
}

function sourceFieldsWithoutRawEmail(record) {
  return {
    submittedAtRaw: normalizeText(value(record, 'Carimbo de data/hora')),
    dataAcaoRaw: normalizeText(value(record, 'Data')),
    turnoRaw: normalizeText(value(record, 'Turno')),
    regionalRaw: normalizeText(value(record, 'Regional')),
    enderecoRaw: normalizeText(value(record, 'Endereço')),
    nomeAcaoRaw: normalizeText(value(record, 'Nome da Ação')),
    tipoAcaoRaw: normalizeText(value(record, 'Tipo de Ação ')),
    formacaoRaw: normalizeText(value(record, 'Formação')),
    publicoRaw: normalizeText(value(record, 'Público')),
    tipoParticipacaoRaw: normalizeText(value(record, 'Tipo de Participação')),
    focoTematicoRaw: normalizeText(value(record, 'Foco Temático')),
    perfilUsuarioRaw: normalizeText(value(record, 'Perfil de Usuário')),
    instituicaoParceiraRaw: normalizeText(
      value(record, 'Instituição ou Empresa Parceira'),
    ),
    coordenadorResponsavelRaw: normalizeText(
      value(record, 'Coordenador / Responsável'),
    ),
    materialUtilizadoRaw: normalizeText(value(record, 'Material Utilizado')),
    observacoesRaw: normalizeText(value(record, 'Observações')),
  };
}

export function transformRecord(record, source = OFFICIAL_SOURCE) {
  validateRecordSchema(record);

  const sourceIdentityHash = buildSourceIdentityHash(record, source);
  const historicalId = `gf_${sourceIdentityHash}`;
  const responderEmailNormalized = normalizeForIdentity(
    value(record, 'Endereço de e-mail'),
  );
  const responderEmailHash =
    responderEmailNormalized === '' ? null : sha256Hex(responderEmailNormalized);

  const rawFields = sourceFieldsWithoutRawEmail(record);
  const metrics = metricBundle(record);

  const baseDocument = {
    schemaVersion: 1,
    recordType: 'historico_google_forms',
    readOnly: true,
    numeroRAE: null,
    source: {
      system: 'google_forms',
      spreadsheetId: source.spreadsheetId,
      sheetName: source.sheetName,
      sourceIdentityHash,
      responderEmailHash,
    },
    raw: rawFields,
    metrics,
    migration: {
      policyVersion: source.policyVersion,
      persistenceEligible: true,
      sourceRowNumberUsedAsIdentity: false,
      rawResponderEmailPersisted: false,
    },
  };

  const contentHash = sha256Hex(canonicalJson(baseDocument));
  const document = {
    ...baseDocument,
    contentHash,
  };

  const stagingBaseDocument = {
    schemaVersion: 1,
    recordType: 'migration_staging_google_forms',
    sourceIdentityHash,
    responderEmailHash,
    raw: rawFields,
    metrics,
    migration: {
      policyVersion: source.policyVersion,
      persistenceEligible: true,
      rawResponderEmailPersisted: false,
    },
  };

  const stagingContentHash = sha256Hex(
    canonicalJson(stagingBaseDocument),
  );

  const stagingDocument = {
    ...stagingBaseDocument,
    contentHash: stagingContentHash,
  };

  return {
    id: historicalId,
    sourceIdentityHash,
    contentHash,
    stagingContentHash,
    document,
    stagingDocument,
  };
}

export function summarizeMetrics(transformedRecords) {
  const names = [
    'pessoasAlcancadas',
    'veiculosAbordados',
    'credenciaisEmitidas',
    'agentesTransito',
    'equipeTerceirizada',
  ];

  const summary = {};

  for (const name of names) {
    let known = 0;
    let unknown = 0;

    for (const item of transformedRecords) {
      if (item.document.metrics[name].known) known += 1;
      else unknown += 1;
    }

    summary[name] = { known, unknown };
  }

  return summary;
}

export function assertAllowedCollectionPath(collectionPath) {
  const normalized = normalizeText(collectionPath).replace(/\\/gu, '/');
  const segments = normalized.split('/').filter(Boolean);

  if (segments.length === 0 || segments.length % 2 === 0) {
    throw new Error('MIG001E3_INVALID_COLLECTION_PATH');
  }

  const root = segments[0];

  if (DENIED_WRITE_ROOTS.includes(root)) {
    throw new Error(`MIG001E3_DENIED_ROOT:${root}`);
  }

  if (!ALLOWED_WRITE_ROOTS.includes(root)) {
    throw new Error(`MIG001E3_ROOT_NOT_ALLOWLISTED:${root}`);
  }

  if (segments.some((segment) => segment === '.' || segment === '..')) {
    throw new Error('MIG001E3_INVALID_COLLECTION_PATH_SEGMENT');
  }

  return normalized;
}

export function buildWritePlan(transformedRecords, batchId) {
  const safeBatchId = normalizeText(batchId);

  if (!/^[A-Za-z0-9][A-Za-z0-9_-]{2,79}$/u.test(safeBatchId)) {
    throw new Error('MIG001E3_INVALID_BATCH_ID');
  }

  const plan = [];

  for (const item of transformedRecords) {
    const stagingPath = assertAllowedCollectionPath(
      'migration_google_forms_staging',
    );
    const historyPath = assertAllowedCollectionPath('acoes_historicas');
    const changesPath = assertAllowedCollectionPath(
      `migration_batches/${safeBatchId}/changes`,
    );

    plan.push({
      operation: 'CREATE_ONLY',
      collectionPath: stagingPath,
      documentId: item.id,
      contentHash: item.contentHash,
    });

    plan.push({
      operation: 'CREATE_ONLY',
      collectionPath: historyPath,
      documentId: item.id,
      contentHash: item.contentHash,
    });

    plan.push({
      operation: 'JOURNAL_CREATE_ONLY',
      collectionPath: changesPath,
      documentId: `${item.id}_history`,
      targetCollection: historyPath,
      targetDocumentId: item.id,
      contentHash: item.contentHash,
    });
  }

  return plan;
}

export function createOnlyDecision(existingContentHash, intendedContentHash) {
  if (existingContentHash === null || existingContentHash === undefined) {
    return 'create';
  }

  if (existingContentHash === intendedContentHash) {
    return 'unchanged';
  }

  return 'changed_pending_review';
}

function yearBucket(rawDate) {
  const text = normalizeText(rawDate);
  const years = text.match(/\b20\d{2}\b/gu);
  return years?.[0] ?? 'unknown-year';
}

export function selectDeterministicPilot(transformedRecords, originalRecords, n) {
  if (!Number.isSafeInteger(n) || n < 1 || n > 10) {
    throw new Error('MIG001E3_INVALID_PILOT_SIZE');
  }

  if (transformedRecords.length !== originalRecords.length) {
    throw new Error('MIG001E3_PILOT_INPUT_LENGTH_MISMATCH');
  }

  const rows = transformedRecords.map((item, index) => ({
    item,
    stratum: [
      normalizeForIdentity(originalRecords[index]['Tipo de Ação ']) ||
        'unknown-type',
      yearBucket(originalRecords[index].Data),
    ].join('|'),
  }));

  const groups = new Map();

  for (const row of rows) {
    if (!groups.has(row.stratum)) groups.set(row.stratum, []);
    groups.get(row.stratum).push(row.item);
  }

  for (const items of groups.values()) {
    items.sort((a, b) => a.id.localeCompare(b.id));
  }

  const strata = [...groups.keys()].sort();
  const selected = [];
  let round = 0;

  while (selected.length < n) {
    let progressed = false;

    for (const stratum of strata) {
      const candidate = groups.get(stratum)[round];

      if (candidate) {
        selected.push(candidate);
        progressed = true;

        if (selected.length === n) break;
      }
    }

    if (!progressed) break;
    round += 1;
  }

  return selected;
}
export function buildExecutableWriteSet(transformedRecords, batchId) {
  const safeBatchId = normalizeText(batchId);

  if (!/^[A-Za-z0-9][A-Za-z0-9_-]{2,79}$/u.test(safeBatchId)) {
    throw new Error('MIG001E3_INVALID_BATCH_ID');
  }

  const idsSorted = transformedRecords
    .map((item) => item.id)
    .sort();

  const contentsSorted = transformedRecords
    .map((item) => item.contentHash)
    .sort();

  const batchBase = {
    schemaVersion: 1,
    recordType: 'migration_batch_google_forms',
    batchId: safeBatchId,
    policyVersion: OFFICIAL_SOURCE.policyVersion,
    sourceSha256: OFFICIAL_SOURCE.expectedSha256,
    expectedRecords: transformedRecords.length,
    mode: 'historical_import',
    createOnly: true,
    idSetHash: sha256Hex(idsSorted.join('\n')),
    contentSetHash: sha256Hex(contentsSorted.join('\n')),
  };

  const batchPayload = {
    ...batchBase,
    contentHash: sha256Hex(canonicalJson(batchBase)),
  };

  const writes = [
    {
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath('migration_batches'),
      documentId: safeBatchId,
      payload: batchPayload,
    },
  ];

  for (const item of transformedRecords) {
    writes.push({
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath(
        'migration_google_forms_staging',
      ),
      documentId: item.id,
      payload: item.stagingDocument,
    });

    writes.push({
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath('acoes_historicas'),
      documentId: item.id,
      payload: item.document,
    });

    const journalBase = {
      schemaVersion: 1,
      recordType: 'migration_change_journal',
      operation: 'CREATE',
      targetCollection: 'acoes_historicas',
      targetDocumentId: item.id,
      sourceIdentityHash: item.sourceIdentityHash,
      targetContentHash: item.contentHash,
      rollbackEligible: true,
    };

    writes.push({
      operation: 'CREATE_ONLY',
      collectionPath: assertAllowedCollectionPath(
        `migration_batches/${safeBatchId}/changes`,
      ),
      documentId: `${item.id}_history`,
      payload: {
        ...journalBase,
        contentHash: sha256Hex(canonicalJson(journalBase)),
      },
    });
  }

  return writes;
}