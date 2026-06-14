extends Node

## Ponto de entrada mínimo do servidor dedicado.
##
## Esta fundação aceita conexões ENet, cria sessões temporárias em memória e
## distribui eventos de spawn visual. Contas reais, personagens e persistência
## continuam fora deste marco.

const DEFAULT_PORT := 7000
const DEFAULT_MAX_CLIENTS := 8
const DEDICATED_SERVER_ARGUMENT := "--dedicated-server"
const PORT_ARGUMENT := "--port"
const MAX_CLIENTS_ARGUMENT := "--max-clients"
const SPAWN_ORIGIN := Vector2(160.0, 180.0)
const SPAWN_OFFSET := Vector2(80.0, 0.0)
const MOVEMENT_SPEED := 90.0
const MOVEMENT_STEP_SECONDS := 1.0 / 15.0

var connected_peers: Dictionary = {}
var sessions: Dictionary = {}
var server_port := DEFAULT_PORT
var max_clients := DEFAULT_MAX_CLIENTS


func _ready() -> void:
	var arguments := OS.get_cmdline_user_args()
	if DEDICATED_SERVER_ARGUMENT not in arguments:
		push_error(
			"ServerMain: use %s para iniciar o processo dedicado."
			% DEDICATED_SERVER_ARGUMENT
		)
		get_tree().quit(ERR_INVALID_PARAMETER)
		return

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	SessionProtocol.session_requested.connect(_on_session_requested)
	MovementProtocol.movement_input_received.connect(_on_movement_input_received)

	server_port = _read_positive_integer_argument(
		arguments,
		PORT_ARGUMENT,
		DEFAULT_PORT,
	)
	max_clients = _read_positive_integer_argument(
		arguments,
		MAX_CLIENTS_ARGUMENT,
		DEFAULT_MAX_CLIENTS,
	)
	_start_server()


func _start_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(server_port, max_clients)
	if error != OK:
		push_error(
			"ServerMain: erro ao abrir a porta %d (erro %d)." % [
				server_port,
				error,
			]
		)
		get_tree().quit(error)
		return

	multiplayer.multiplayer_peer = peer
	print(
		"ServerMain: servidor dedicado iniciado na porta %d (máximo de %d clientes)."
		% [server_port, max_clients]
	)


func _read_positive_integer_argument(
	arguments: PackedStringArray,
	argument_name: String,
	default_value: int,
) -> int:
	var argument_index := arguments.find(argument_name)
	if argument_index == -1:
		return default_value
	if argument_index + 1 >= arguments.size():
		push_warning(
			"ServerMain: %s sem valor; usando %d." % [
				argument_name,
				default_value,
			]
		)
		return default_value

	var raw_value := arguments[argument_index + 1]
	if not raw_value.is_valid_int() or raw_value.to_int() <= 0:
		push_warning(
			"ServerMain: valor inválido para %s (%s); usando %d." % [
				argument_name,
				raw_value,
				default_value,
			]
		)
		return default_value

	return raw_value.to_int()


func _on_peer_connected(peer_id: int) -> void:
	connected_peers[peer_id] = {
		"connected_at": Time.get_unix_time_from_system(),
	}
	print(
		"ServerMain: peer %d conectado. Total conectado: %d."
		% [peer_id, connected_peers.size()]
	)


func _on_peer_disconnected(peer_id: int) -> void:
	var had_session := sessions.erase(peer_id)
	connected_peers.erase(peer_id)
	if had_session:
		for remaining_peer_id: int in sessions:
			SpawnProtocol.despawn_peer.rpc_id(remaining_peer_id, peer_id)
	print(
		"ServerMain: peer %d desconectado. Sessão removida: %s. Total conectado: %d."
		% [peer_id, had_session, connected_peers.size()]
	)


func _on_session_requested(peer_id: int, display_name: String) -> void:
	if not connected_peers.has(peer_id):
		SessionProtocol.reject_session.rpc_id(peer_id, "Peer não conectado.")
		return
	if sessions.has(peer_id):
		SessionProtocol.reject_session.rpc_id(peer_id, "Este peer já possui uma sessão.")
		return

	var spawn_position := _temporary_spawn_position(sessions.size())
	sessions[peer_id] = {
		"display_name": display_name,
		"created_at": Time.get_unix_time_from_system(),
	}
	var peer_state: Dictionary = connected_peers[peer_id]
	peer_state["position"] = spawn_position
	connected_peers[peer_id] = peer_state

	SessionProtocol.accept_session.rpc_id(peer_id, peer_id, display_name)
	print(
		"ServerMain: sessão criada para peer %d com nome %s."
		% [peer_id, display_name]
	)

	for existing_peer_id: int in sessions:
		if existing_peer_id == peer_id:
			continue
		var existing_position: Vector2 = connected_peers[existing_peer_id]["position"]
		SpawnProtocol.spawn_peer.rpc_id(peer_id, existing_peer_id, existing_position)
		SpawnProtocol.spawn_peer.rpc_id(existing_peer_id, peer_id, spawn_position)

	SpawnProtocol.spawn_peer.rpc_id(peer_id, peer_id, spawn_position)


func _on_movement_input_received(
	peer_id: int,
	direction: Vector2,
	_sequence: int,
) -> void:
	if not sessions.has(peer_id):
		push_warning("ServerMain: input ignorado para peer %d sem sessão." % peer_id)
		return

	var safe_direction := direction.limit_length(1.0)
	var peer_state: Dictionary = connected_peers[peer_id]
	var current_position: Vector2 = peer_state["position"]
	var new_position := (
		current_position
		+ safe_direction * MOVEMENT_SPEED * MOVEMENT_STEP_SECONDS
	)
	peer_state["position"] = new_position
	connected_peers[peer_id] = peer_state

	for connected_peer_id: int in sessions:
		MovementProtocol.movement_snapshot.rpc_id(
			connected_peer_id,
			peer_id,
			new_position,
		)
	print(
		"ServerMain: movimento do peer %d calculado na posição %s."
		% [peer_id, new_position]
	)


func _temporary_spawn_position(spawn_index: int) -> Vector2:
	return SPAWN_ORIGIN + SPAWN_OFFSET * spawn_index
