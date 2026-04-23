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

    if (!window.MDZInfra?.createReliableWsTransport) {
      throw new Error("MDZInfra.createReliableWsTransport não disponível");
    }

    if (!window.MDZInfra?.createLogger) {
      throw new Error("MDZInfra.createLogger não disponível");
    }

    if (!window.MDZApp?.createNetClient) {
      throw new Error("MDZApp.createNetClient não disponível");
    }

    const wsUrl = resolveWsUrl();
    const logger = window.MDZInfra.createLogger({ correlationId: `mdz_${Date.now()}` });
    const baseTransport = window.MDZInfra.createWebSocketTransport(wsUrl);
    const reliableTransport = window.MDZInfra.createReliableWsTransport({
      baseTransport,
      logger,
      retries: 3,
      retryDelayMs: 350,
    });

    return window.MDZApp.createNetClient({
      roomId: "default",
      transport: reliableTransport,
      logger,
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
