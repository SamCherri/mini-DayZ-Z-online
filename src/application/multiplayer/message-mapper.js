window.MDZApp = window.MDZApp || {};

window.MDZApp.mapNetworkMessageToTurnEvent = function mapNetworkMessageToTurnEvent(message) {
  if (!window.MDZDomain) {
    throw new Error("MDZDomain não disponível");
  }

  const normalized = message?.payload?.type ? message.payload : message;

  if (normalized.type === "joined") {
    return window.MDZDomain.createPlayerJoinedEvent({
      playerId: normalized.playerId,
      roomId: normalized.roomId,
    });
  }

  if (normalized.type === "state_update") {
    return window.MDZDomain.createStateUpdatedEvent({
      state: normalized.state || normalized,
    });
  }

  if (normalized.type === "error") {
    return window.MDZDomain.createErrorReceivedEvent({
      message: normalized.message,
    });
  }

  return null;
};
