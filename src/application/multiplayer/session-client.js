window.MDZApp = window.MDZApp || {};

window.MDZApp.createNetClient = function createNetClient(options) {
  const roomId = options.roomId || "default";
  const transport = options.transport;

  let playerId = null;
  let latestState = { players: [] };

  function handleIncoming(rawData) {
    const msg = JSON.parse(rawData);

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
    transport.send(JSON.stringify({ type: "move", dx, dy }));
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
