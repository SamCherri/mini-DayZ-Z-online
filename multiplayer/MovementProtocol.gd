extends Node

## Contrato compartilhado do primeiro movimento autorizado pelo servidor.
##
## Clientes enviam somente direção/intenção. O servidor identifica o autor
## pelo remote sender, calcula a posição e devolve snapshots aos clientes.

signal movement_input_received(peer_id: int, direction: Vector2, sequence: int)
signal movement_snapshot_received(peer_id: int, position: Vector2)

const SERVER_PEER_ID := 1
const MAX_INPUT_LENGTH := 1.0


@rpc("any_peer", "call_remote", "unreliable_ordered")
func submit_movement_input(direction: Vector2, sequence: int = 0) -> void:
	if not multiplayer.is_server():
		push_warning("MovementProtocol: input rejeitado fora do servidor.")
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= SERVER_PEER_ID:
		push_warning("MovementProtocol: input rejeitado por sender inválido.")
		return
	if not direction.is_finite():
		push_warning("MovementProtocol: input não finito rejeitado para peer %d." % sender_id)
		return

	var safe_direction := direction
	if safe_direction.length() > MAX_INPUT_LENGTH:
		safe_direction = safe_direction.normalized()

	movement_input_received.emit(sender_id, safe_direction, sequence)


@rpc("authority", "call_remote", "reliable")
func movement_snapshot(peer_id: int, position: Vector2) -> void:
	if multiplayer.is_server():
		push_warning("MovementProtocol: servidor não deve receber o próprio snapshot.")
		return
	if multiplayer.get_remote_sender_id() != SERVER_PEER_ID:
		push_warning("MovementProtocol: snapshot rejeitado porque não veio do servidor.")
		return
	if peer_id <= 0 or not position.is_finite():
		push_warning("MovementProtocol: snapshot rejeitado por dados inválidos.")
		return

	print(
		"MovementProtocol: snapshot recebido para peer %d na posição %s."
		% [peer_id, position]
	)
	movement_snapshot_received.emit(peer_id, position)
