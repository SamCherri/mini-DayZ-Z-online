# Camada de Infraestrutura

Implementações técnicas externas ao domínio.

## Alvos
- Adapter de websocket
- Persistência PostgreSQL (Railway)
- Integração com Prisma
- Observabilidade com correlationId

## Implementação atual
- `src/infrastructure/websocket/ws-transport.js`
  - transporte websocket base.
- `src/infrastructure/websocket/reliable-ws-transport.js`
  - ACK/retry/timeout para mensagens críticas.
- `src/infrastructure/observability/logger.js`
  - logger estruturado.
- `src/infrastructure/persistence/prisma-client.ts`
  - client Prisma preparado para `DATABASE_URL`.

## Regra
Nenhuma regra de negócio deve nascer aqui; apenas implementação de portas/interfaces.
