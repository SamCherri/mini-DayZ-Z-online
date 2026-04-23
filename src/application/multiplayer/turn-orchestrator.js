window.MDZApp = window.MDZApp || {};

window.MDZApp.createTurnOrchestrator = function createTurnOrchestrator(deps) {
  let state = deps.initialState || { currentTurn: 1 };
  const commandHandler = deps.commandHandler;
  const eventQueue = deps.eventQueue;
  const onDomainEvent = deps.onDomainEvent;
  const logger = deps.logger;

  function emitEvents(events) {
    for (const event of events || []) {
      eventQueue?.push?.(event);
    }

    eventQueue?.drain?.((event) => {
      onDomainEvent?.(event);
    });
  }

  function execute(command) {
    logger?.info?.("turn_execute_start", { turn: state.currentTurn, commandType: command?.type });

    const result = commandHandler.handle(state, command);
    state = result.state;

    emitEvents(result.events);

    logger?.info?.("turn_execute_end", {
      ok: result.ok,
      reason: result.reason,
      nextTurn: state?.currentTurn,
    });

    return result;
  }

  function getState() {
    return state;
  }

  return {
    execute,
    getState,
  };
};
