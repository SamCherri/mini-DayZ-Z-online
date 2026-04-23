window.MDZApp = window.MDZApp || {};

window.MDZApp.createNetClient = function createNetClient(options) {
  const roomId = options.roomId || "default";
  const transport = options.transport;
  const onTurnEvent = typeof options.onTurnEvent === "function" ? options.onTurnEvent : null;
  const logger = options.logger;

  const eventQueue = window.MDZApp.createTurnEventQueue
    ? window.MDZApp.createTurnEventQueue()
    : null;

  const commandHandler = window.MDZApp.createCommandHandler
    ? window.MDZApp.createCommandHandler({ logger })
    : null;

  const orchestrator = window.MDZApp.createTurnOrchestrator
    ? window.MDZApp.createTurnOrchestrator({
      initialState: { currentTurn: 1 },
      commandHandler,
      eventQueue,
      onDomainEvent: onTurnEvent,
      logger,
    })
    : null;

  const remoteEventHandler = window.MDZApp.createRemoteEventHandler
    ? window.MDZApp.createRemoteEventHandler({ onTurnEvent, logger })
    : null;

  let playerId = null;
  let latestState = { players: [] };

  function handleIncoming(rawData) {
    const msg = JSON.parse(rawData);

    const envelopeValidation = window.MDZApp.ProtocolV1?.validateEnvelope
      ? window.MDZApp.ProtocolV1.validateEnvelope(msg)
      : { ok: true };

    if (!envelopeValidation.ok && msg.type !== "joined" && msg.type !== "state_update" && msg.type !== "error") {
      logger?.warn?.("protocol_invalid", { reason: envelopeValidation.reason });
      return;
    }

    if (msg.messageId && typeof transport.ack === "function") {
      transport.ack(msg.messageId);
    }

    const payload = msg.payload || msg;

    if (payload.type === "joined" || msg.type === "joined") {
      playerId = payload.playerId || msg.playerId;
      logger?.info?.("player_joined", { playerId, roomId: payload.roomId || msg.roomId });
    }

    if (payload.type === "state_update" || msg.type === "state_update") {
      latestState = payload.state || msg;
    }

    if (payload.type === "error" || msg.type === "error") {
      logger?.error?.("server_error", { message: payload.message || msg.message });
    }

    const mappedEvent = window.MDZApp.mapNetworkMessageToTurnEvent
      ? window.MDZApp.mapNetworkMessageToTurnEvent(payload.type ? payload : msg)
      : null;

    if (mappedEvent && remoteEventHandler) {
      remoteEventHandler.handle(mappedEvent);
    } else if (mappedEvent && onTurnEvent) {
      onTurnEvent(mappedEvent);
    }
  }

  function connect() {
    transport.connect({
      onOpen() {
        const joinMessage = window.MDZApp.ProtocolV1?.createEnvelope
          ? window.MDZApp.ProtocolV1.createEnvelope("join_room", { type: "joined_request", roomId })
          : { type: "join_room", roomId };

        if (typeof transport.sendWithRetry === "function") {
          transport.sendWithRetry(joinMessage);
        } else {
          transport.send(JSON.stringify({ type: "join_room", roomId }));
        }
      },
      onMessage: handleIncoming,
      onClose() {
        logger?.warn?.("connection_closed", { roomId });
      },
      onError(err) {
        logger?.error?.("connection_error", { roomId, error: String(err) });
      },
    });
  }

  function move(dx, dy) {
    const turn = orchestrator ? orchestrator.getState().currentTurn : 1;
    const moveAction = window.MDZDomain?.createMoveAction
      ? window.MDZDomain.createMoveAction(dx, dy)
      : { type: "MOVE", payload: { dx, dy } };

    moveAction.turn = turn;

    const validation = window.MDZDomain?.validateTurnCommand
      ? window.MDZDomain.validateTurnCommand({ currentTurn: turn }, moveAction)
      : { ok: true };

    if (!validation.ok) {
      logger?.warn?.("move_invalid", { reason: validation.reason, dx, dy, turn });
      return;
    }

    orchestrator?.execute(moveAction);

    const envelope = window.MDZApp.ProtocolV1?.createEnvelope
      ? window.MDZApp.ProtocolV1.createEnvelope("move", {
        type: "move",
        dx: moveAction.payload.dx,
        dy: moveAction.payload.dy,
        turn,
      })
      : { type: "move", dx, dy, turn };

    if (typeof transport.sendWithRetry === "function") {
      transport.sendWithRetry(envelope);
    } else {
      transport.send(JSON.stringify(envelope));
    }
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
