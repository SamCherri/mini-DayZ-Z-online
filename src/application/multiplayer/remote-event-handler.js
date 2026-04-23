window.MDZApp = window.MDZApp || {};

window.MDZApp.createRemoteEventHandler = function createRemoteEventHandler(options) {
  const onTurnEvent = typeof options?.onTurnEvent === "function" ? options.onTurnEvent : null;
  const logger = options?.logger;

  function handle(event) {
    if (!event) return;

    logger?.info?.("remote_event_received", { type: event.type });
    onTurnEvent?.(event);
  }

  return {
    handle,
  };
};
