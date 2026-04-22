# Auditoria Fase 1 — Shell Web e Pontos de Extensão

## Escopo auditado

Nesta fase, a auditoria focou nos arquivos de bootstrap do jogo dentro de `Mini DayZ rpg.zip`:

- `Mini DayZ rpg/index.html`
- `Mini DayZ rpg/net-client.js`
- `Mini DayZ rpg/zoom.js`

## Achados principais

### 1) Bootstrap do runtime

O `index.html` carrega o runtime exportado de Construct 2 (`c2runtime.js`) e inicia o jogo via `cr_createRuntime("c2canvas")`.

Também acopla scripts adicionais:

- `zoom.js` (controle de zoom visual)
- `runtime-config.js` (configuração de infraestrutura)
- `ws-transport.js` (infraestrutura de transporte)
- `session-client.js` (aplicação)
- `net-client.js` (fachada de compatibilidade)

Esse ponto é ideal para integração incremental, porque permite injetar comportamento sem editar agressivamente `c2runtime.js`.

### 2) Networking atual (desacoplado em camadas)

Situação anterior: `net-client.js` apontava para host fixo (`ws://192.168.0.186:3002`).

Status após ajuste incremental:

- URL websocket é lida de `runtime-config.js`;
- aceita injeção por `window.__MDZ_RUNTIME_CONFIG__.wsUrl`;
- fallback para `localStorage` (`MDZ_WS_URL`);
- fallback final derivado de `window.location` (`/ws`), compatível com Railway;
- protocolo de sessão ficou na camada de aplicação (`session-client.js`);
- transporte websocket ficou na infraestrutura (`ws-transport.js`).

### 3) UI de zoom

`zoom.js` já implementa uma UI mobile-friendly com botões em overlay e listeners de mouse/touch.

Reaproveitamento direto:

- padrão de overlay visual por cena;
- eventos mobile-first;
- estratégia de alteração não invasiva no runtime.

## Direção técnica para próximos commits

1. Definir contratos de domínio para evento por turno (ação, resposta, consequência).
2. Introduzir mapeamento de mensagens de rede -> eventos de aplicação (sem lógica no frontend).
3. Evoluir para persistência PostgreSQL/Prisma com variáveis de plataforma (Railway).
4. Planejar autenticação de sessão multiplayer sem quebrar fluxo legado.

## Não foi feito nesta fase

- Nenhuma remoção de arquivo legado.
- Nenhuma substituição de fluxo existente do jogo.
- Nenhuma alteração em `c2runtime.js`/`data.js`.
