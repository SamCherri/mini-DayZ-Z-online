import test from 'node:test';
import assert from 'node:assert/strict';
import { createAuthoritativeTurnServer } from '../src/server/authoritative-turn-server.mjs';

function msg(type, messageId, payload) {
  return JSON.stringify({
    v: 'v1',
    type,
    messageId,
    timestamp: Date.now(),
    payload,
  });
}

test('servidor autoritativo aceita join e avança turno no move válido', () => {
  const server = createAuthoritativeTurnServer();

  const join = server.handleRawMessage('client-a', msg('join_room', 'join-1', { roomId: 'room-1' }));
  assert.equal(join.outbound.length, 2);

  const move = server.handleRawMessage(
    'client-a',
    msg('move', 'move-1', { roomId: 'room-1', turn: 1, dx: 1, dy: 0 }),
  );

  assert.equal(move.outbound.length, 1);
  assert.equal(move.outbound[0].message.type, 'state_update');

  const snapshot = server.getRoomSnapshot('room-1');
  assert.equal(snapshot.currentTurn, 2);
  assert.equal(snapshot.state.lastMove.turnApplied, 1);
});

test('servidor ignora move duplicado pelo mesmo messageId (idempotência)', () => {
  const server = createAuthoritativeTurnServer();

  server.handleRawMessage('client-a', msg('join_room', 'join-1', { roomId: 'room-2' }));

  const first = server.handleRawMessage(
    'client-a',
    msg('move', 'dup-1', { roomId: 'room-2', turn: 1, dx: 0, dy: 1 }),
  );
  const second = server.handleRawMessage(
    'client-a',
    msg('move', 'dup-1', { roomId: 'room-2', turn: 1, dx: 0, dy: 1 }),
  );

  assert.equal(first.outbound.length, 1);
  assert.equal(second.outbound.length, 0);

  const snapshot = server.getRoomSnapshot('room-2');
  assert.equal(snapshot.currentTurn, 2);
});
