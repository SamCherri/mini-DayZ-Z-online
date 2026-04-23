# Servidor autoritativo (Node)

Camada de execução do estado canônico de partidas por turno.

## Implementação atual
- `authoritative-turn-server.mjs`
  - processamento de `join_room` e `move`.
  - controle de turno por sala.
  - idempotência por `messageId`.
  - emissão de envelopes `joined`, `state_update` e `error`.

## Diretriz
O servidor decide estado de partida. Cliente apenas envia comando e renderiza eventos recebidos.
