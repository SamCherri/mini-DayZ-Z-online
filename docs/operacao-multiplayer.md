# Operação Multiplayer (Railway)

## Objetivo
Guia operacional para observabilidade e resposta a incidentes do modo multiplayer por turnos.

## Logs obrigatórios
- `turn_execute_start`
- `turn_execute_end`
- `command_rejected`
- `send_attempt`
- `ack_received`
- `ack_timeout`

## Checklist de incidente
1. Verificar `correlationId` nos logs.
2. Confirmar se há `ack_timeout` acima do normal.
3. Validar `TURN_OUT_OF_SYNC` recorrente (desalinhamento de turno).
4. Conferir disponibilidade do websocket endpoint em Railway.
5. Confirmar conectividade com PostgreSQL via `DATABASE_URL`.
