// Verifica o monitor de regras do Firebase CLI usando somente o emulador.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const project = 'demo-geduc-ago001-watch';
const rules = allowed => `rules_version = '2'; service cloud.firestore {
  match /databases/{database}/documents { match /{document=**} {
    allow read: if ${allowed}; allow write: if false;
  } }
}\n`;

async function probe() {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  const file = process.env.AGO001_RULES_WATCH_PATH;
  assert(host && file, 'O teste precisa ser iniciado pelo launcher isolado.');
  const url = `http://${host}/v1/projects/${project}/databases/(default)/documents/watch/probe`;
  const seed = await fetch(url, { method: 'PATCH',
    headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields: { marker: { stringValue: 'isolado' } } }),
    signal: AbortSignal.timeout(5000) });
  assert.equal(seed.status, 200);
  async function expectStatus(expected) {
    const deadline = Date.now() + 20000;
    let actual;
    do {
      const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
      actual = response.status;
      if (actual === expected) return;
      await new Promise(resolve => setTimeout(resolve, 200));
    } while (Date.now() < deadline);
    assert.equal(actual, expected, 'A regra não foi recarregada no prazo.');
  }
  await expectStatus(403);
  console.log('PASS: regra inicial nega leitura.');
  fs.writeFileSync(file, rules(true));
  await expectStatus(200);
  console.log('PASS: Firebase CLI recarrega regra permitindo leitura.');
  fs.writeFileSync(file, rules(false));
  await expectStatus(403);
  console.log('PASS: Firebase CLI recarrega regra negando leitura novamente.');
}

async function main() {
  if (process.argv.includes('--probe')) return probe();
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'ago001-watch-'));
  const file = path.join(temp, 'firestore.rules');
  const config = path.join(temp, 'firebase.json');
  try {
    fs.writeFileSync(file, rules(false));
    fs.writeFileSync(config, JSON.stringify({
      firestore: { rules: file },
      emulators: { firestore: { host: '127.0.0.1', port: 8080 }, ui: { enabled: false } },
    }));
    // O CLI aplica proxy HTTP até a chamadas de loopback. Este processo
    // testa somente o emulador local e precisa alcançá-lo diretamente.
    const env = { ...process.env, AGO001_RULES_WATCH_PATH: file,
      FIREBASE_CLI_DISABLE_TELEMETRY: '1' };
    for (const key of ['HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy']) delete env[key];
    const result = spawnSync(process.execPath, [
      require.resolve('firebase-tools/lib/bin/firebase.js'),
      '--config', config, 'emulators:exec', '--only', 'firestore', '--project', project,
      'node test/security/firestore_cli_watch_test.cjs --probe',
    ], { cwd: path.resolve(__dirname, '../..'), stdio: 'inherit',
      env,
    });
    if (result.error) throw result.error;
    assert.equal(result.status, 0, 'Teste de recarga das regras falhou.');
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
}
main().catch(error => { console.error(error); process.exitCode = 1; });
