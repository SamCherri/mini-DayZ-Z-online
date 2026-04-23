window.MDZDomain = window.MDZDomain || {};

window.MDZDomain.createInteractionScene = function createInteractionScene(sceneId, minReputation) {
  return {
    sceneId,
    minReputation: Number.isFinite(minReputation) ? minReputation : 0,
  };
};

window.MDZDomain.canInteractInScene = function canInteractInScene(scene, reputation) {
  const repValue = reputation?.value ?? 0;
  return repValue >= (scene?.minReputation ?? 0);
};
