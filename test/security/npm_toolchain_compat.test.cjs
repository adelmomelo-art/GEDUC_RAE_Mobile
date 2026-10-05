const { test } = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const net = require('node:net');
const { createRequire } = require('node:module');

test('Gaxios mantém requisição multipart com UUID atualizado', { timeout: 10000 }, async () => {
  const { Gaxios } = require('gaxios');
  const server = http.createServer(async (request, response) => {
    let body = '';
    for await (const chunk of request) body += chunk;
    assert.match(request.headers['content-type'], /multipart/);
    assert.match(body, /compatibilidade/);
    response.setHeader('Content-Type', 'application/json');
    response.end('{"ok":true}');
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try {
    const result = await new Gaxios().request({
      url: `http://127.0.0.1:${server.address().port}/`, method: 'POST',
      noProxy: ['127.0.0.1'], timeout: 5000,
      multipart: [{ headers: { 'Content-Type': 'text/plain' }, content: 'compatibilidade' }],
    });
    assert.equal(result.data.ok, true);
  } finally { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
});

test('get-uri usa o cliente FTP corrigido para obter arquivo local', { timeout: 10000 }, async () => {
  const { getUri } = require('get-uri');
  const sockets = new Set();
  let dataServer;
  const server = net.createServer(socket => {
    sockets.add(socket);
    socket.on('close', () => sockets.delete(socket));
    socket.setEncoding('utf8');
    socket.write('220 local test\r\n');
    let buffer = '', dataSocket;
    socket.on('data', chunk => {
      buffer += chunk;
      let index;
      while ((index = buffer.indexOf('\r\n')) >= 0) {
        const command = buffer.slice(0, index).split(' ')[0].toUpperCase();
        buffer = buffer.slice(index + 2);
        if (command === 'USER') socket.write('331 password\r\n');
        else if (command === 'PASS') socket.write('230 ok\r\n');
        else if (command === 'FEAT') socket.write('211-Features\r\n EPSV\r\n UTF8\r\n211 End\r\n');
        else if (command === 'MDTM') socket.write('213 20261004000000\r\n');
        else if (command === 'EPSV') {
          dataServer = net.createServer(data => { dataSocket = data; sockets.add(data);
            data.on('close', () => sockets.delete(data)); });
          dataServer.listen(0, '127.0.0.1', () => socket.write(`229 (|||${dataServer.address().port}|)\r\n`));
        } else if (command === 'RETR') {
          socket.write('150 opening\r\n');
          dataSocket.end('arquivo isolado', () => socket.write('226 done\r\n'));
        } else if (command === 'QUIT') socket.end('221 bye\r\n');
        else socket.write('200 ok\r\n');
      }
    });
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try {
    const stream = await getUri(`ftp://test:test@127.0.0.1:${server.address().port}/arquivo.txt`);
    let content = '';
    for await (const chunk of stream) content += chunk;
    assert.equal(content, 'arquivo isolado');
  } finally {
    for (const socket of sockets) socket.destroy();
    if (dataServer) await new Promise(resolve => dataServer.close(resolve));
    await new Promise(resolve => server.close(resolve));
  }
});

test('Firebase CLI carrega PubSub atualizado e mantém APIs de tópicos', { timeout: 10000 }, async () => {
  const fromCli = createRequire(require.resolve('firebase-tools/package.json'));
  const { PubSub } = fromCli('@google-cloud/pubsub');
  const client = new PubSub({ projectId: 'demo-geduc-compat', apiEndpoint: '127.0.0.1:8681' });
  try {
    const topic = client.topic('isolado');
    assert.match(topic.name, /topics\/isolado$/);
    assert.equal(typeof topic.create, 'function');
    assert.equal(typeof topic.createSubscription, 'function');
    assert.equal(typeof topic.subscription('isolada').on, 'function');
  } finally { await client.close(); }
});
