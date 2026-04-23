import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

function load(context, file) {
  vm.runInContext(fs.readFileSync(file, 'utf8'), context);
}

test('mensagem remota mapeada dispara callback sem executar MOVE artificial', () => {
  const context = {
    window: {},
    WebSocket: function FakeWebSocket() {},
    setTimeout,
    clearTimeout,
    console,
    Date,
    Math,
    JSON,
  };
  vm.createContext(context);

  context.window.MDZDomain = {
    createPlayerJoinedEvent(payload) {
      return { type: 'PLAYER_JOINED', payload };
    },
  };

  load(context, 'src/application/multiplayer/protocol/v1/messages.js');
  load(context, 'src/application/multiplayer/message-mapper.js');
  load(context, 'src/application/multiplayer/remote-event-handler.js');
  load(context, 'src/application/multiplayer/session-client.js');

  let capturedHandlers = null;
  const transport = {
    connect(handlers) {
      capturedHandlers = handlers;
      handlers.onOpen?.();
    },
    send() {},
    sendWithRetry() {},
  };

  const receivedEvents = [];
  const client = context.window.MDZApp.createNetClient({
    roomId: 'sala-1',
    transport,
    onTurnEvent(event) {
      receivedEvents.push(event);
    },
  });

  client.connect();

  const incoming = JSON.stringify({
    v: 'v1',
    messageId: 'msg_srv_1',
    timestamp: Date.now(),
    type: 'joined',
    payload: { type: 'joined', playerId: 'player_1', roomId: 'sala-1' },
  });

  capturedHandlers.onMessage(incoming);

  assert.equal(receivedEvents.length, 1);
  assert.equal(receivedEvents[0].type, 'PLAYER_JOINED');
});
