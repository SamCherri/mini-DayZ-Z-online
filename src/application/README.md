# Camada de Aplicação

Orquestra casos de uso, coordenando domínio e infraestrutura.

## Implementação atual
- `src/application/multiplayer/session-client.js`
  - encapsula fluxo de sessão multiplayer (`join_room`, `move`, estado do jogador).
  - depende apenas de um `transport` injetado.

## Exemplos de casos de uso futuros
- EntrarEmCena
- InteragirComNPC
- RegistrarAcaoSocial
- SincronizarEstadoMultiplayer
