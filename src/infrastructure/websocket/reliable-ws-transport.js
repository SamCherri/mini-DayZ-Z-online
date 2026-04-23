window.MDZInfra = window.MDZInfra || {};

window.MDZInfra.createReliableWsTransport = function createReliableWsTransport(options) {
  const base = options.baseTransport;
  const logger = options.logger;
  const retries = options.retries ?? 3;
  const retryDelayMs = options.retryDelayMs ?? 400;
  const pending = new Map();

  function connect(handlers) {
    base.connect({
      onOpen: handlers.onOpen,
      onClose: handlers.onClose,
      onError: handlers.onError,
      onMessage(raw) {
        let parsed = null;
        try {
          parsed = JSON.parse(raw);
        } catch (_) {
          handlers.onMessage?.(raw);
          return;
        }

        if (parsed?.type === "ack" && parsed?.messageId) {
          pending.delete(parsed.messageId);
          logger?.info?.("ack_received", { messageId: parsed.messageId });
          return;
        }

        handlers.onMessage?.(raw);
      },
    });
  }

  function sendWithRetry(envelope) {
    const messageId = envelope.messageId;
    pending.set(messageId, { envelope, attempts: 0 });

    function attempt() {
      const record = pending.get(messageId);
      if (!record) return;

      if (record.attempts >= retries) {
        logger?.error?.("ack_timeout", { messageId, retries });
        pending.delete(messageId);
        return;
      }

      record.attempts += 1;
      base.send(JSON.stringify(record.envelope));
      logger?.info?.("send_attempt", { messageId, attempt: record.attempts });

      setTimeout(() => {
        if (pending.has(messageId)) attempt();
      }, retryDelayMs);
    }

    attempt();
  }

  function ack(messageId) {
    base.send(JSON.stringify({ v: "v1", type: "ack", messageId, timestamp: Date.now() }));
  }

  return {
    connect,
    sendWithRetry,
    ack,
    close: base.close,
  };
};
