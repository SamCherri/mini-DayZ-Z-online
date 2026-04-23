# Camada de Aplicação

Orquestra casos de uso, coordenando domínio e infraestrutura.

## Implementação atual
- `src/application/multiplayer/message-mapper.js`
  - traduz mensagens de rede para eventos de domínio de turno.
- `src/application/multiplayer/turn-event-queue.js`
  - mantém fila FIFO para processamento ordenado dos eventos de turno.
- `src/application/multiplayer/session-client.js`
  - encapsula fluxo de sessão multiplayer (`join_room`, `move`, estado do jogador).
  - depende de `transport` injetado e publica eventos de turno opcionalmente.
  - valida ação de movimento através da camada de domínio.

## Exemplos de casos de uso futuros
- EntrarEmCena
- InteragirComNPC
- RegistrarAcaoSocial
- SincronizarEstadoMultiplayer
