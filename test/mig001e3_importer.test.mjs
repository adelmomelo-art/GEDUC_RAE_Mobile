import test from 'node:test';
import assert from 'node:assert/strict';

import {
  ALLOWED_WRITE_ROOTS,
  DENIED_WRITE_ROOTS,
  OFFICIAL_SOURCE,
  SOURCE_FIELDS,
  assertAllowedCollectionPath,
  buildExecutableWriteSet,
  buildHistoricalId,
  buildWritePlan,
  canonicalJson,
  createOnlyDecision,
  parseStrictMetric,
  selectDeterministicPilot,
  sha256Hex,
  transformRecord,
  validateRecordSchema,
} from '../tools/migration/mig001e3_core.mjs';

import { parseArgs } from '../tools/migration/mig001e3_importer.mjs';

function sampleRecord(overrides = {}) {
  const record = {
    'Carimbo de data/hora': '01/02/2026 10:20:30',
    'Endereço de e-mail': 'Pessoa.Exemplo@Example.COM',
    Data: '01/02/2026',
    Turno: 'Manhã',
    Regional: 'SER 1',
    Endereço: 'Rua Exemplo, 100',
    'Nome da Ação': 'Ação Educativa',
    'Tipo de Ação ': 'Blitz Educativa',
    Formação: 'Sim',
    Público: 'Externo',
    'Tipo de Participação': 'Abordagem',
    'Foco Temático': 'Trânsito Seguro',
    'Perfil de Usuário': 'Adultos',
    'Instituição ou Empresa Parceira': 'Instituição X',
    'Pessoas Alcançadas': 10,
    'Veículos Abordados': '20',
    'Credenciais Emitidas': '',
    'Coordenador / Responsável': 'Responsável X',
    'Agentes de Trânsito': 'Equipe Alfa',
    'Equipe Terceirizada': '5 terceirizados',
    'Material Utilizado': 'Folder',
    Observações: 'Sem observações',
  };

  return { ...record, ...overrides };
}

test('schema oficial tem exatamente 22 campos e preserva espaco final de Tipo de Ação', () => {
  assert.equal(SOURCE_FIELDS.length, 22);
  assert.equal(SOURCE_FIELDS[7], 'Tipo de Ação ');
  assert.equal(validateRecordSchema(sampleRecord()), true);
});

test('schema rejeita chave ausente ou extra', () => {
  const missing = sampleRecord();
  delete missing.Turno;

  assert.throws(
    () => validateRecordSchema(missing),
    /MIG001E3_SCHEMA_MISMATCH/u,
  );

  assert.throws(
    () => validateRecordSchema({ ...sampleRecord(), Extra: 'x' }),
    /MIG001E3_SCHEMA_MISMATCH/u,
  );
});

test('ID historico e deterministico e nao usa numero de linha', () => {
  const a = sampleRecord();
  const b = { ...a };

  assert.equal(buildHistoricalId(a), buildHistoricalId(b));
  assert.match(buildHistoricalId(a), /^gf_[a-f0-9]{64}$/u);
});

test('alterar um componente de identidade altera o ID', () => {
  const base = sampleRecord();
  const changed = sampleRecord({ Endereço: 'Outro endereço' });

  assert.notEqual(buildHistoricalId(base), buildHistoricalId(changed));
});

test('documento final nao persiste email bruto e guarda somente hash', () => {
  const transformed = transformRecord(sampleRecord());
  const serialized = JSON.stringify(transformed.document);

  assert.equal(
    transformed.document.migration.rawResponderEmailPersisted,
    false,
  );
  assert.equal(
    typeof transformed.document.source.responderEmailHash,
    'string',
  );
  assert.equal(
    serialized.includes('Pessoa.Exemplo@Example.COM'),
    false,
  );
  assert.equal(transformed.document.numeroRAE, null);
});

test('politica numerica promove apenas inteiro nativo ou texto integralmente numerico', () => {
  assert.deepEqual(parseStrictMetric(12), {
    value: 12,
    known: true,
    raw: null,
    sourceKind: 'native_integer',
  });

  assert.deepEqual(parseStrictMetric(' 12 '), {
    value: 12,
    known: true,
    raw: '12',
    sourceKind: 'numeric_text',
  });

  assert.equal(parseStrictMetric('12 agentes').known, false);
  assert.equal(parseStrictMetric('aprox. 12').known, false);
  assert.equal(parseStrictMetric('1 e 2').known, false);
  assert.equal(parseStrictMetric('').known, false);
});

test('allowlist de escrita exclui explicitamente acoes e contadores', () => {
  assert.ok(ALLOWED_WRITE_ROOTS.includes('acoes_historicas'));
  assert.ok(DENIED_WRITE_ROOTS.includes('acoes'));
  assert.ok(DENIED_WRITE_ROOTS.includes('contadores'));

  assert.equal(
    assertAllowedCollectionPath('acoes_historicas'),
    'acoes_historicas',
  );

  assert.equal(
    assertAllowedCollectionPath('migration_batches/b1/changes'),
    'migration_batches/b1/changes',
  );

  assert.throws(
    () => assertAllowedCollectionPath('acoes'),
    /MIG001E3_DENIED_ROOT:acoes/u,
  );

  assert.throws(
    () => assertAllowedCollectionPath('contadores'),
    /MIG001E3_DENIED_ROOT:contadores/u,
  );

  assert.throws(
    () => assertAllowedCollectionPath('outra_colecao'),
    /MIG001E3_ROOT_NOT_ALLOWLISTED/u,
  );
});

test('plano de escrita usa somente staging, batch changes e historico', () => {
  const transformed = [transformRecord(sampleRecord())];
  const plan = buildWritePlan(transformed, 'pilot_001');

  assert.equal(plan.length, 3);

  const roots = new Set(
    plan.map((item) => item.collectionPath.split('/')[0]),
  );

  assert.deepEqual(
    [...roots].sort(),
    [
      'acoes_historicas',
      'migration_batches',
      'migration_google_forms_staging',
    ].sort(),
  );

  assert.equal([...roots].includes('acoes'), false);
  assert.equal([...roots].includes('contadores'), false);
});

test('create-only classifica create, unchanged e changed_pending_review', () => {
  assert.equal(createOnlyDecision(null, 'abc'), 'create');
  assert.equal(createOnlyDecision('abc', 'abc'), 'unchanged');
  assert.equal(
    createOnlyDecision('old', 'new'),
    'changed_pending_review',
  );
});

test('CLI e dry-run por padrao e --apply permanece bloqueado ate E4', () => {
  const parsed = parseArgs(['--source', 'fonte.json']);
  assert.equal(parsed.mode, 'dry-run');

  assert.throws(
    () => parseArgs(['--source', 'fonte.json', '--apply']),
    /MIG001E3_APPLY_LOCKED_UNTIL_E4/u,
  );
});

test('pilot e deterministico e limitado a no maximo 10', () => {
  const records = [
    sampleRecord({ 'Tipo de Ação ': 'A', Data: '01/01/2025' }),
    sampleRecord({
      'Carimbo de data/hora': '02/01/2026 10:20:30',
      'Tipo de Ação ': 'B',
      Data: '02/01/2026',
    }),
    sampleRecord({
      'Carimbo de data/hora': '03/01/2026 10:20:30',
      'Tipo de Ação ': 'A',
      Data: '03/01/2026',
    }),
  ];

  const transformed = records.map((record) => transformRecord(record));

  const first = selectDeterministicPilot(transformed, records, 2);
  const second = selectDeterministicPilot(transformed, records, 2);

  assert.deepEqual(
    first.map((item) => item.id),
    second.map((item) => item.id),
  );

  assert.throws(
    () => selectDeterministicPilot(transformed, records, 11),
    /MIG001E3_INVALID_PILOT_SIZE/u,
  );
});

test('metadados oficiais da fonte permanecem fixos no B1', () => {
  assert.equal(
    OFFICIAL_SOURCE.spreadsheetId,
    '1HgTRMpBPItqoAbRKUujQs7481HhjPZfhsuM4s80jYJE',
  );
  assert.equal(
    OFFICIAL_SOURCE.sheetName,
    'Respostas ao formulário 1',
  );
  assert.equal(OFFICIAL_SOURCE.expectedRecords, 1051);
});
test('batch document possui contentHash deterministico e fingerprints do conjunto', () => {
  const records = [
    sampleRecord(),
    sampleRecord({
      'Carimbo de data/hora': '02/02/2026 10:20:30',
      'Pessoas Alcançadas': 20,
    }),
  ];

  const transformed = records.map((record) => transformRecord(record));
  const first = buildExecutableWriteSet(transformed, 'batch_001');
  const second = buildExecutableWriteSet(transformed, 'batch_001');

  assert.equal(first.length, 1 + transformed.length * 3);

  const batch = first[0];

  assert.equal(batch.collectionPath, 'migration_batches');
  assert.equal(batch.documentId, 'batch_001');
  assert.equal(typeof batch.payload.idSetHash, 'string');
  assert.equal(typeof batch.payload.contentSetHash, 'string');
  assert.equal(typeof batch.payload.contentHash, 'string');
  assert.match(batch.payload.idSetHash, /^[a-f0-9]{64}$/u);
  assert.match(batch.payload.contentSetHash, /^[a-f0-9]{64}$/u);
  assert.match(batch.payload.contentHash, /^[a-f0-9]{64}$/u);

  assert.equal(
    first[0].payload.contentHash,
    second[0].payload.contentHash,
  );

  const changed = records.map((record) => transformRecord(record));
  changed[1] = transformRecord({
    ...records[1],
    'Pessoas Alcançadas': 21,
  });

  const third = buildExecutableWriteSet(changed, 'batch_001');

  assert.notEqual(
    first[0].payload.contentSetHash,
    third[0].payload.contentSetHash,
  );
  assert.notEqual(
    first[0].payload.contentHash,
    third[0].payload.contentHash,
  );
});
test('cada payload persistivel possui contentHash proprio e verificavel', () => {
  const transformed = [
    transformRecord(sampleRecord()),
    transformRecord(
      sampleRecord({
        'Carimbo de data/hora': '02/02/2026 10:20:30',
        'Pessoas Alcançadas': 20,
      }),
    ),
  ];

  const writes = buildExecutableWriteSet(transformed, 'batch_hash_001');

  assert.equal(writes.length, 1 + transformed.length * 3);

  for (const write of writes) {
    const payload = write.payload;

    assert.equal(typeof payload.contentHash, 'string');
    assert.match(payload.contentHash, /^[a-f0-9]{64}$/u);

    const { contentHash, ...withoutHash } = payload;
    const calculated = sha256Hex(canonicalJson(withoutHash));

    assert.equal(
      contentHash,
      calculated,
      `${write.collectionPath}/${write.documentId}`,
    );
  }

  const staging = writes.find(
    (write) =>
      write.collectionPath === 'migration_google_forms_staging',
  );

  const history = writes.find(
    (write) => write.collectionPath === 'acoes_historicas',
  );

  const journal = writes.find(
    (write) => write.collectionPath.endsWith('/changes'),
  );

  assert.notEqual(
    staging.payload.contentHash,
    history.payload.contentHash,
  );

  assert.equal(
    journal.payload.targetContentHash,
    history.payload.contentHash,
  );

  assert.notEqual(
    journal.payload.contentHash,
    journal.payload.targetContentHash,
  );
});