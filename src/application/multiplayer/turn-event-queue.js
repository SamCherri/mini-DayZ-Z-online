window.MDZApp = window.MDZApp || {};

window.MDZApp.createTurnEventQueue = function createTurnEventQueue() {
  const queue = [];

  function push(event) {
    if (!event) return;
    queue.push(event);
  }

  function drain(handler) {
    while (queue.length > 0) {
      const event = queue.shift();
      handler(event);
    }
  }

  function size() {
    return queue.length;
  }

  return {
    push,
    drain,
    size,
  };
};
