window.MDZDomain = window.MDZDomain || {};

window.MDZDomain.validateTurnCommand = function validateTurnCommand(state, command) {
  if (!command || !command.type) {
    return { ok: false, reason: "COMMAND_REQUIRED" };
  }

  if (!state || typeof state.currentTurn !== "number") {
    return { ok: false, reason: "STATE_INVALID" };
  }

  if (command.turn !== state.currentTurn) {
    return { ok: false, reason: "TURN_OUT_OF_SYNC" };
  }

  if (command.type === "MOVE") {
    return window.MDZDomain.validateMoveAction
      ? window.MDZDomain.validateMoveAction(command)
      : { ok: true };
  }

  return { ok: false, reason: "COMMAND_NOT_SUPPORTED" };
};

window.MDZDomain.applyTurnCommand = function applyTurnCommand(state, command) {
  const validation = window.MDZDomain.validateTurnCommand(state, command);
  if (!validation.ok) {
    return {
      ok: false,
      reason: validation.reason,
      state,
      events: [],
    };
  }

  const nextState = {
    ...state,
    currentTurn: state.currentTurn + 1,
    lastCommand: command,
  };

  return {
    ok: true,
    state: nextState,
    events: [
      window.MDZDomain.createStateUpdatedEvent
        ? window.MDZDomain.createStateUpdatedEvent({ state: nextState })
        : { type: "STATE_UPDATED", payload: { state: nextState } },
    ],
  };
};
