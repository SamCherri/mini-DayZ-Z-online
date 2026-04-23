window.MDZApp = window.MDZApp || {};

window.MDZApp.createNetClient = function createNetClient(options) {
  const roomId = options.roomId || "default";
  const transport = options.transport;
  const onTurnEvent = typeof options.onTurnEvent === "function" ? options.onTurnEvent : null;
  const queue = window.MDZApp.createTurnEventQueue
    ? window.MDZApp.createTurnEventQueue()
    : null;

  let playerId = null;
  let latestState = { players: [] };

  function publishTurnEvent(event) {
    if (!event || !onTurnEvent) return;
    onTurnEvent(event);
  }

  function publishQueuedEvents() {
    if (!queue) return;
    queue.drain((event) => {
      publishTurnEvent(event);
    });
  }

  function handleIncoming(rawData) {
    const msg = JSON.parse(rawData);

    const mappedEvent = window.MDZApp.mapNetworkMessageToTurnEvent
      ? window.MDZApp.mapNetworkMessageToTurnEvent(msg)
      : null;

    if (queue) {
      queue.push(mappedEvent);
      publishQueuedEvents();
    } else {
      publishTurnEvent(mappedEvent);
    }

    if (msg.type === "joined") {
      playerId = msg.playerId;
    }

    if (msg.type === "state_update") {
      latestState = msg;
    }

    if (msg.type === "error") {
      console.error("[MDZNet] erro:", msg.message);
    }
  }

  function connect() {
    transport.connect({
      onOpen() {
        transport.send(JSON.stringify({ type: "join_room", roomId }));
      },
      onMessage: handleIncoming,
      onClose() {
        console.log("[MDZNet] conexão fechada");
      },
      onError(err) {
        console.error("[MDZNet] websocket erro", err);
      },
    });
  }

  function move(dx, dy) {
    const moveAction = window.MDZDomain?.createMoveAction
      ? window.MDZDomain.createMoveAction(dx, dy)
      : { type: "MOVE", payload: { dx, dy } };

    const validation = window.MDZDomain?.validateMoveAction
      ? window.MDZDomain.validateMoveAction(moveAction)
      : { ok: true };

    if (!validation.ok) {
      console.error("[MDZNet] movimento inválido:", validation.reason);
      return;
    }

    transport.send(JSON.stringify({
      type: "move",
      dx: moveAction.payload.dx,
      dy: moveAction.payload.dy,
    }));
  }

  function getState() {
    return latestState;
  }

  function getPlayerId() {
    return playerId;
  }

  return {
    connect,
    move,
    getState,
    getPlayerId,
  };
};
