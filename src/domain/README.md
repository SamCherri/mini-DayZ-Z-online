# Camada de Domínio

Responsável por regras centrais do modo roleplay.

## Diretrizes
- Sem dependências de framework/UI.
- Entidades e regras puras.
- Preparado para multiplayer futuro (consistência de estado e eventos de domínio).

## Implementação atual
- `src/domain/multiplayer/turn-events.js`
  - define tipos de eventos de turno para multiplayer.
- `src/domain/multiplayer/turn-action.js`
  - define ação de movimento e valida invariantes básicas (`dx`/`dy` numéricos).

## Próximas entidades
- PersonagemRP
- Reputacao
- InteracaoSocial
- CenaRP
