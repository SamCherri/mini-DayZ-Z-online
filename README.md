# mini-DayZ-Z-online

## Estado atual

Base incremental do game mode com separação por camadas, bridge legado e preparação para multiplayer confiável.

## Componentes principais

### Domínio
- `src/domain/multiplayer/turn-events.js`
- `src/domain/multiplayer/turn-action.js`
- `src/domain/multiplayer/turn-rules.js`
- `src/domain/rp/reputation.js`
- `src/domain/rp/interaction-scene.js`

### Aplicação
- `src/application/multiplayer/protocol/v1/messages.js`
- `src/application/multiplayer/command-handler.js`
- `src/application/multiplayer/turn-orchestrator.js`
- `src/application/multiplayer/session-client.js`
- `src/application/multiplayer/remote-event-handler.js`

### Infraestrutura
- `src/infrastructure/websocket/ws-transport.js`
- `src/infrastructure/websocket/reliable-ws-transport.js`
- `src/infrastructure/observability/logger.js`
- `src/infrastructure/persistence/prisma-client.ts`
- `prisma/schema.prisma`

### Servidor autoritativo (Node)
- `src/server/authoritative-turn-server.mjs`

### Apresentação/Bridge legado
- `legacy-shell/index.html`
- `legacy-shell/net-client.js`
- `legacy-shell/runtime-config.js`
- `legacy-shell/zoom.js`

## Auditoria e operação
- `docs/preparacao-mod-roleplay.md`
- `docs/auditoria-fase-1.md`
- `docs/operacao-multiplayer.md`
- `docs/etapas-conclusao-gamemod.md`

## Ferramentas

```bash
python tools/inventory_zip.py "Mini DayZ rpg.zip"
python tools/extract_legacy_shell.py "Mini DayZ rpg.zip" --output-dir legacy-shell
```

## Testes

```bash
node --test tests/*.test.mjs
```
