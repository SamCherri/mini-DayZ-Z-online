window.MDZApp = window.MDZApp || {};

window.MDZApp.mapNetworkMessageToTurnEvent = function mapNetworkMessageToTurnEvent(message) {
  if (!window.MDZDomain) {
    throw new Error("MDZDomain não disponível");
  }

  if (message.type === "joined") {
    return window.MDZDomain.createPlayerJoinedEvent({
      playerId: message.playerId,
      roomId: message.roomId,
    });
  }

  if (message.type === "state_update") {
    return window.MDZDomain.createStateUpdatedEvent({
      state: message,
    });
  }

  if (message.type === "error") {
    return window.MDZDomain.createErrorReceivedEvent({
      message: message.message,
    });
  }

  return null;
};
