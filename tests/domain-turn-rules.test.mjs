import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import fs from 'node:fs';

const context = { window: {} };
vm.createContext(context);

for (const file of [
  'src/domain/multiplayer/turn-action.js',
  'src/domain/multiplayer/turn-events.js',
  'src/domain/multiplayer/turn-rules.js',
]) {
  vm.runInContext(fs.readFileSync(file, 'utf8'), context);
}

test('validateTurnCommand aceita comando MOVE no turno correto', () => {
  const result = context.window.MDZDomain.validateTurnCommand(
    { currentTurn: 1 },
    { type: 'MOVE', turn: 1, payload: { dx: 1, dy: 0 } }
  );

  assert.equal(result.ok, true);
});

test('applyTurnCommand avança turno', () => {
  const result = context.window.MDZDomain.applyTurnCommand(
    { currentTurn: 1 },
    { type: 'MOVE', turn: 1, payload: { dx: 1, dy: 0 } }
  );

  assert.equal(result.ok, true);
  assert.equal(result.state.currentTurn, 2);
});
