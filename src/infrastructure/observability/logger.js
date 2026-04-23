window.MDZInfra = window.MDZInfra || {};

window.MDZInfra.createLogger = function createLogger(context) {
  const correlationId = context?.correlationId || `corr_${Date.now()}`;

  function format(level, event, data) {
    return {
      level,
      event,
      correlationId,
      timestamp: new Date().toISOString(),
      data: data || {},
    };
  }

  return {
    info(event, data) {
      console.log("[MDZ]", format("info", event, data));
    },
    warn(event, data) {
      console.warn("[MDZ]", format("warn", event, data));
    },
    error(event, data) {
      console.error("[MDZ]", format("error", event, data));
    },
    correlationId,
  };
};
