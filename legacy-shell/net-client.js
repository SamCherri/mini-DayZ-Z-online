window.MDZNet = (() => {
  function resolveWsUrl() {
    if (!window.MDZRuntimeConfig || typeof window.MDZRuntimeConfig.readWsUrl !== "function") {
      throw new Error("MDZRuntimeConfig.readWsUrl não disponível");
    }

    const wsUrl = window.MDZRuntimeConfig.readWsUrl();

    if (!/^wss?:\/\//.test(wsUrl)) {
      throw new Error(`[MDZNet] URL websocket inválida: ${wsUrl}`);
    }

    return wsUrl;
  }

  function createClient() {
    if (!window.MDZInfra?.createWebSocketTransport) {
      throw new Error("MDZInfra.createWebSocketTransport não disponível");
    }

    if (!window.MDZApp?.createNetClient) {
      throw new Error("MDZApp.createNetClient não disponível");
    }

    const wsUrl = resolveWsUrl();
    const transport = window.MDZInfra.createWebSocketTransport(wsUrl);

    return window.MDZApp.createNetClient({
      roomId: "default",
      transport,
    });
  }

  const client = createClient();

  return {
    connect: client.connect,
    move: client.move,
    getState: client.getState,
    getPlayerId: client.getPlayerId,
  };
})();
