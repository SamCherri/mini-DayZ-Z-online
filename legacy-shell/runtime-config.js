window.MDZRuntimeConfig = (() => {
  const KEY = "MDZ_WS_URL";

  function inferDefaultWsUrl() {
    if (window.location.protocol === "https:") {
      return `wss://${window.location.host}/ws`;
    }

    if (window.location.protocol === "http:") {
      return `ws://${window.location.host}/ws`;
    }

    return "ws://127.0.0.1:3002";
  }

  function readWsUrl() {
    const injected = window.__MDZ_RUNTIME_CONFIG__?.wsUrl;
    if (typeof injected === "string" && injected.trim()) {
      return injected.trim();
    }

    const fromStorage = window.localStorage?.getItem(KEY);
    if (typeof fromStorage === "string" && fromStorage.trim()) {
      return fromStorage.trim();
    }

    return inferDefaultWsUrl();
  }

  return {
    readWsUrl,
    KEY
  };
})();
