window.MDZDomain = window.MDZDomain || {};

window.MDZDomain.TurnEventType = {
  PLAYER_JOINED: "PLAYER_JOINED",
  STATE_UPDATED: "STATE_UPDATED",
  ERROR_RECEIVED: "ERROR_RECEIVED",
};

window.MDZDomain.createPlayerJoinedEvent = function createPlayerJoinedEvent(payload) {
  return {
    type: window.MDZDomain.TurnEventType.PLAYER_JOINED,
    payload,
    createdAt: Date.now(),
  };
};

window.MDZDomain.createStateUpdatedEvent = function createStateUpdatedEvent(payload) {
  return {
    type: window.MDZDomain.TurnEventType.STATE_UPDATED,
    payload,
    createdAt: Date.now(),
  };
};

window.MDZDomain.createErrorReceivedEvent = function createErrorReceivedEvent(payload) {
  return {
    type: window.MDZDomain.TurnEventType.ERROR_RECEIVED,
    payload,
    createdAt: Date.now(),
  };
};
