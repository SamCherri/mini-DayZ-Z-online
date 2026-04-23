import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import fs from 'node:fs';

const context = { window: {} };
vm.createContext(context);

vm.runInContext(fs.readFileSync('src/application/multiplayer/protocol/v1/messages.js', 'utf8'), context);

test('createEnvelope cria envelope v1 válido', () => {
  const msg = context.window.MDZApp.ProtocolV1.createEnvelope('move', { dx: 1, dy: 0 });
  const validation = context.window.MDZApp.ProtocolV1.validateEnvelope(msg);

  assert.equal(validation.ok, true);
  assert.equal(msg.v, 'v1');
});
