window.MDZApp = window.MDZApp || {};
window.MDZApp.ProtocolV1 = window.MDZApp.ProtocolV1 || {};

window.MDZApp.ProtocolV1.createEnvelope = function createEnvelope(type, payload) {
  return {
    v: "v1",
    messageId: `msg_${Date.now()}_${Math.random().toString(16).slice(2, 8)}`,
    timestamp: Date.now(),
    type,
    payload,
  };
};

window.MDZApp.ProtocolV1.validateEnvelope = function validateEnvelope(message) {
  if (!message || message.v !== "v1") return { ok: false, reason: "PROTOCOL_VERSION_INVALID" };
  if (!message.messageId) return { ok: false, reason: "MESSAGE_ID_REQUIRED" };
  if (!message.type) return { ok: false, reason: "TYPE_REQUIRED" };
  return { ok: true };
};
