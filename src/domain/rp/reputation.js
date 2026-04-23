window.MDZDomain = window.MDZDomain || {};

window.MDZDomain.createReputation = function createReputation(initialValue) {
  return {
    value: Number.isFinite(initialValue) ? initialValue : 0,
  };
};

window.MDZDomain.applyReputationDelta = function applyReputationDelta(reputation, delta) {
  const current = reputation?.value ?? 0;
  const next = current + (Number.isFinite(delta) ? delta : 0);

  return {
    value: Math.max(-100, Math.min(100, next)),
  };
};
