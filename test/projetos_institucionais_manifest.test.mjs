import fs from 'node:fs';
import test from 'node:test';
import assert from 'node:assert/strict';

const path = 'tools/catalogos/projetos_institucionais_2026.json';
const manifest = JSON.parse(fs.readFileSync(path, 'utf8'));
const projetos = manifest.projetos;

const expectedCategories = {
  'Ação Educativa': 8,
  'Comando Educativo': 14,
  'Curso': 6,
  'Palestra': 16,
  'Roda de Conversa': 1,
  'Treinamento Institucional': 6,
  'Workshop': 2,
};

test('manifesto possui exatamente 53 projetos institucionais', () => {
  assert.equal(manifest.expectedCount, 53);
  assert.equal(projetos.length, 53);
});

test('ids e codigos sao unicos e category-aware', () => {
  assert.equal(new Set(projetos.map((p) => p.id)).size, 53);
  assert.equal(new Set(projetos.map((p) => p.codigo)).size, 53);

  for (const p of projetos) {
    assert.match(p.id, /^(ae|ce|cur|pal|rc|ti|ws)-[a-z0-9-]+$/);
    assert.match(p.codigo, /^(AE|CE|CUR|PAL|RC|TI|WS)-\d{3}$/);
  }
});

test('categorias preservam a contagem institucional 8+14+6+16+1+6+2', () => {
  const counts = {};
  for (const p of projetos) counts[p.categoria] = (counts[p.categoria] ?? 0) + 1;
  assert.deepEqual(counts, expectedCategories);
  assert.deepEqual(manifest.categoryCounts, expectedCategories);
});

test('contrato do Firestore esta completo e tipado', () => {
  projetos.forEach((p, index) => {
    assert.ok(p.nome.trim());
    assert.ok(p.codigo.trim());
    assert.ok(p.categoria.trim());
    assert.equal(typeof p.descricao, 'string');
    assert.equal(typeof p.objetivo, 'string');
    assert.equal(typeof p.publicoAlvo, 'string');
    assert.ok(Array.isArray(p.palavrasChave));
    assert.ok(Array.isArray(p.aliases));
    assert.ok(Array.isArray(p.regionalIds));
    assert.ok(Array.isArray(p.equipeIds));
    assert.equal(p.regionalIds.length, 0);
    assert.equal(p.equipeIds.length, 0);
    assert.equal(p.ordem, index + 1);
    assert.equal(p.ativo, true);
  });
});

test('colisoes nominais entre categorias possuem ids e codigos distintos', () => {
  const nomesDuplicadosEsperados = [
    'AMC nas Escolas',
    'Ciclista Seguro',
    'Comportamento Seguro',
    'Técnicas de Canalização e Sinalização',
  ];

  for (const nome of nomesDuplicadosEsperados) {
    const itens = projetos.filter((p) => p.nome === nome);
    assert.equal(itens.length, 2, nome);
    assert.notEqual(itens[0].categoria, itens[1].categoria, nome);
    assert.notEqual(itens[0].id, itens[1].id, nome);
    assert.notEqual(itens[0].codigo, itens[1].codigo, nome);
  }
});

test('aliases somente onde explicitamente documentados', () => {
  const aliases = Object.fromEntries(
    projetos.filter((p) => p.aliases.length).map((p) => [p.codigo, p.aliases]),
  );

  assert.deepEqual(aliases, {
    'AE-005': ['Minicircuito', 'Tabuleiro'],
    'CUR-001': ['CPSC'],
    'CUR-002': ['CPSM'],
    'WS-002': ['Dinâmica dos Óculos'],
  });
});
