window.MDZDomain = window.MDZDomain || {};

window.MDZDomain.createMoveAction = function createMoveAction(dx, dy) {
  return {
    type: "MOVE",
    payload: { dx, dy },
  };
};

window.MDZDomain.validateMoveAction = function validateMoveAction(action) {
  if (!action || action.type !== "MOVE") {
    return { ok: false, reason: "INVALID_ACTION_TYPE" };
  }

  const { dx, dy } = action.payload || {};

  if (!Number.isFinite(dx) || !Number.isFinite(dy)) {
    return { ok: false, reason: "INVALID_MOVE_VECTOR" };
  }

  return { ok: true };
};
