# mini-DayZ-Z-online

## Estado atual

Preparação inicial para evolução do mod roleplay com foco em mudanças pequenas e seguras sobre base legada exportada.

## Documentação

- Preparação macro: `docs/preparacao-mod-roleplay.md`
- Auditoria fase 1 (shell web): `docs/auditoria-fase-1.md`

## Ferramentas de auditoria

Inventário do pacote ZIP:

```bash
python tools/inventory_zip.py "Mini DayZ rpg.zip"
```

Extração de shell legado (index/net-client/zoom) para análise versionada:

```bash
python tools/extract_legacy_shell.py "Mini DayZ rpg.zip" --output-dir legacy-shell
```

## Configuração de websocket (infraestrutura)

O shell legado resolve URL websocket sem hardcode:

1. `window.__MDZ_RUNTIME_CONFIG__.wsUrl`
2. `localStorage["MDZ_WS_URL"]`
3. fallback por `window.location` (`ws(s)://<host>/ws`)

Exemplo de injeção antes de carregar `net-client.js`:

```html
<script>
  window.__MDZ_RUNTIME_CONFIG__ = {
    wsUrl: "wss://seu-dominio-railway/ws"
  };
</script>
```

## Estrutura incremental (clean architecture)

- `src/domain/`
- `src/application/`
  - `multiplayer/session-client.js`
- `src/infrastructure/`
  - `websocket/ws-transport.js`
- `src/presentation/`

`legacy-shell/net-client.js` permanece apenas como ponte de compatibilidade para o runtime legado.
