window.MDZApp = window.MDZApp || {};

window.MDZApp.createCommandHandler = function createCommandHandler(deps) {
  const logger = deps.logger;

  function handle(state, command) {
    const result = window.MDZDomain.applyTurnCommand
      ? window.MDZDomain.applyTurnCommand(state, command)
      : { ok: false, reason: "TURN_RULES_NOT_AVAILABLE", state, events: [] };

    if (!result.ok) {
      logger?.warn?.("command_rejected", {
        reason: result.reason,
        command,
        currentTurn: state?.currentTurn,
      });
    }

    return result;
  }

  return { handle };
};
