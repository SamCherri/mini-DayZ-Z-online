function createEnvelope(type, payload, messageIdFactory) {
  return {
    v: "v1",
    type,
    messageId: messageIdFactory(),
    timestamp: Date.now(),
    payload,
  };
}

function createDefaultMessageIdFactory() {
  return () => `srv_${Date.now()}_${Math.random().toString(16).slice(2, 10)}`;
}

function validateMovePayload(payload) {
  if (!payload || typeof payload.turn !== "number") {
    return { ok: false, reason: "TURN_REQUIRED" };
  }

  if (!Number.isFinite(payload.dx) || !Number.isFinite(payload.dy)) {
    return { ok: false, reason: "INVALID_MOVE_VECTOR" };
  }

  return { ok: true };
}

function ensureRoom(rooms, roomId) {
  if (!rooms.has(roomId)) {
    rooms.set(roomId, {
      roomId,
      currentTurn: 1,
      playersByClient: new Map(),
      processedMessageIds: new Set(),
      state: { players: [], lastMove: null, currentTurn: 1 },
    });
  }

  return rooms.get(roomId);
}

export function createAuthoritativeTurnServer(options = {}) {
  const rooms = new Map();
  const makeMessageId = options.createMessageId || createDefaultMessageIdFactory();

  function joinRoom(clientId, roomId) {
    const room = ensureRoom(rooms, roomId);

    if (!room.playersByClient.has(clientId)) {
      const playerId = `player_${room.playersByClient.size + 1}`;
      room.playersByClient.set(clientId, playerId);
      room.state.players = Array.from(room.playersByClient.values());
    }

    const playerId = room.playersByClient.get(clientId);

    return {
      room,
      outbound: [
        {
          scope: "client",
          clientId,
          roomId,
          message: createEnvelope("joined", { type: "joined", roomId, playerId }, makeMessageId),
        },
        {
          scope: "room",
          roomId,
          message: createEnvelope(
            "state_update",
            { type: "state_update", state: room.state },
            makeMessageId,
          ),
        },
      ],
    };
  }

  function applyMove(clientId, roomId, envelope) {
    const room = ensureRoom(rooms, roomId);
    const payload = envelope.payload || {};

    if (!room.playersByClient.has(clientId)) {
      return {
        room,
        outbound: [
          {
            scope: "client",
            clientId,
            roomId,
            message: createEnvelope("error", { type: "error", message: "PLAYER_NOT_IN_ROOM" }, makeMessageId),
          },
        ],
      };
    }

    if (room.processedMessageIds.has(envelope.messageId)) {
      return { room, outbound: [] };
    }

    room.processedMessageIds.add(envelope.messageId);

    const validation = validateMovePayload(payload);
    if (!validation.ok) {
      return {
        room,
        outbound: [
          {
            scope: "client",
            clientId,
            roomId,
            message: createEnvelope("error", { type: "error", message: validation.reason }, makeMessageId),
          },
        ],
      };
    }

    if (payload.turn !== room.currentTurn) {
      return {
        room,
        outbound: [
          {
            scope: "client",
            clientId,
            roomId,
            message: createEnvelope("error", { type: "error", message: "TURN_OUT_OF_SYNC" }, makeMessageId),
          },
        ],
      };
    }

    room.currentTurn += 1;
    room.state = {
      ...room.state,
      currentTurn: room.currentTurn,
      lastMove: {
        playerId: room.playersByClient.get(clientId),
        dx: payload.dx,
        dy: payload.dy,
        turnApplied: payload.turn,
      },
    };

    return {
      room,
      outbound: [
        {
          scope: "room",
          roomId,
          message: createEnvelope(
            "state_update",
            { type: "state_update", state: room.state },
            makeMessageId,
          ),
        },
      ],
    };
  }

  function handleEnvelope(clientId, envelope) {
    const roomId = envelope?.payload?.roomId || envelope?.roomId || "default";

    if (envelope?.type === "join_room") {
      return joinRoom(clientId, roomId);
    }

    if (envelope?.type === "move") {
      return applyMove(clientId, roomId, envelope);
    }

    return {
      room: ensureRoom(rooms, roomId),
      outbound: [
        {
          scope: "client",
          clientId,
          roomId,
          message: createEnvelope("error", { type: "error", message: "COMMAND_NOT_SUPPORTED" }, makeMessageId),
        },
      ],
    };
  }

  function handleRawMessage(clientId, rawData) {
    let parsed;

    try {
      parsed = typeof rawData === "string" ? JSON.parse(rawData) : rawData;
    } catch (_) {
      return {
        room: ensureRoom(rooms, "default"),
        outbound: [
          {
            scope: "client",
            clientId,
            roomId: "default",
            message: createEnvelope("error", { type: "error", message: "MALFORMED_JSON" }, makeMessageId),
          },
        ],
      };
    }

    return handleEnvelope(clientId, parsed);
  }

  function getRoomSnapshot(roomId) {
    const room = rooms.get(roomId);
    if (!room) return null;

    return {
      roomId: room.roomId,
      currentTurn: room.currentTurn,
      players: Array.from(room.playersByClient.values()),
      state: room.state,
    };
  }

  return {
    handleRawMessage,
    getRoomSnapshot,
  };
}
