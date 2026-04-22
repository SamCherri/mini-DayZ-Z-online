window.MDZInfra = window.MDZInfra || {};

window.MDZInfra.createWebSocketTransport = function createWebSocketTransport(wsUrl) {
  let socket = null;

  function assertOpen() {
    return socket && socket.readyState === WebSocket.OPEN;
  }

  function connect(handlers) {
    socket = new WebSocket(wsUrl);

    socket.onopen = () => handlers.onOpen?.();

    socket.onmessage = (event) => {
      handlers.onMessage?.(event.data);
    };

    socket.onclose = () => handlers.onClose?.();
    socket.onerror = (err) => handlers.onError?.(err);
  }

  function send(payload) {
    if (!assertOpen()) return false;
    socket.send(payload);
    return true;
  }

  function close() {
    if (socket) {
      socket.close();
    }
  }

  return {
    connect,
    send,
    close,
  };
};
