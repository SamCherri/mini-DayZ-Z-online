# Camada de Infraestrutura

Implementações técnicas externas ao domínio.

## Alvos
- Adapter de websocket
- Persistência PostgreSQL (Railway)
- Integração com Prisma

## Implementação atual
- `src/infrastructure/websocket/ws-transport.js`
  - fornece transporte websocket com callbacks (`onOpen`, `onMessage`, `onClose`, `onError`).

## Regra
Nenhuma regra de negócio deve nascer aqui; apenas implementação de portas/interfaces.
