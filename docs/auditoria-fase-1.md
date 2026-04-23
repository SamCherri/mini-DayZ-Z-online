# Auditoria Fase 1 — Shell Web e Pontos de Extensão

## Status consolidado

A base já está segmentada em camadas e ligada ao shell legado sem alterar `c2runtime.js`/`data.js`.

### Camadas em uso
- Domínio: eventos, ações, regras de turno, reputação e interação por cena.
- Aplicação: protocolo v1, command handler, orquestrador de turno e sessão multiplayer.
- Infraestrutura: websocket base + confiável (ack/retry), observabilidade e persistência Prisma.
- Apresentação: bridge em `legacy-shell`.

### Avanços implementados
1. Regras de turno no domínio.
2. Orquestrador e command handler.
3. Transporte confiável com ack/retry.
4. Persistência preparada com Prisma/PostgreSQL.
5. Domínio RP inicial (reputação + interação em cena).
6. Contrato versionado de protocolo (`v1`).
7. Observabilidade com correlationId e guia de operação.
8. Testes automatizados de domínio/protocolo.
9. Eventos remotos agora são tratados na aplicação sem gerar `MOVE` sintético.

## Limites desta fase
- Servidor websocket autoritativo inicial implementado em `src/server/authoritative-turn-server.mjs` (ainda sem adapter de rede em produção).
- Persistência Prisma foi preparada, mas não integrada em runtime de produção.
- Fluxo visual legado permanece como bridge, sem redesign de UI.
