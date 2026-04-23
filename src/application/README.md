# Camada de Aplicação

Orquestra casos de uso, coordenando domínio e infraestrutura.

## Implementação atual
- `multiplayer/protocol/v1/messages.js` (contrato v1)
- `multiplayer/message-mapper.js` (rede -> eventos de domínio)
- `multiplayer/turn-event-queue.js` (fila FIFO)
- `multiplayer/command-handler.js` (aplicação de comandos via domínio)
- `multiplayer/turn-orchestrator.js` (fluxo de turno)
- `multiplayer/session-client.js` (sessão multiplayer)
- `multiplayer/remote-event-handler.js` (eventos remotos sem comando local artificial)

## Diretriz
Toda decisão de fluxo passa pela aplicação; apresentação apenas dispara comandos e renderiza resultados.
