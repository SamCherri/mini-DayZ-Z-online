extends Node

## Contrato compartilhado para eventos visuais autorizados pelo servidor.
##
## O peer servidor (ID 1) é a autoridade deste autoload. Clientes apenas
## recebem os RPCs e convertem as mensagens em sinais locais para o mundo.

signal spawn_peer_received(peer_id: int, position: Vector2)
signal despawn_peer_received(peer_id: int)

const SERVER_PEER_ID := 1


@rpc("authority", "call_remote", "reliable")
func spawn_peer(peer_id: int, position: Vector2) -> void:
	if not _is_valid_server_message(peer_id):
		return
	spawn_peer_received.emit(peer_id, position)


@rpc("authority", "call_remote", "reliable")
func despawn_peer(peer_id: int) -> void:
	if not _is_valid_server_message(peer_id):
		return
	despawn_peer_received.emit(peer_id)


func _is_valid_server_message(peer_id: int) -> bool:
	if multiplayer.is_server():
		push_warning("SpawnProtocol: o servidor não deve receber seus próprios eventos.")
		return false
	if multiplayer.get_remote_sender_id() != SERVER_PEER_ID:
		push_warning("SpawnProtocol: evento rejeitado porque não veio do servidor.")
		return false
	if peer_id <= 0:
		push_warning("SpawnProtocol: evento rejeitado por conter peer inválido.")
		return false
	return true
