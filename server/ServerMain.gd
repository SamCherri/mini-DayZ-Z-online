extends Node

## Ponto de entrada mínimo do servidor dedicado.
##
## Esta fundação aceita conexões ENet, registra os peers ativos e distribui
## eventos de spawn visual. Regras de gameplay, personagens, autenticação e
## persistência continuam fora deste marco.

const DEFAULT_PORT := 7000
const DEFAULT_MAX_CLIENTS := 8
const DEDICATED_SERVER_ARGUMENT := "--dedicated-server"
const PORT_ARGUMENT := "--port"
const MAX_CLIENTS_ARGUMENT := "--max-clients"
const SPAWN_ORIGIN := Vector2(160.0, 180.0)
const SPAWN_OFFSET := Vector2(80.0, 0.0)

var connected_peers: Dictionary = {}
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
	var existing_peer_ids := connected_peers.keys()
	var spawn_position := _temporary_spawn_position(connected_peers.size())
	connected_peers[peer_id] = {
		"connected_at": Time.get_unix_time_from_system(),
		"position": spawn_position,
	}

	for existing_peer_id: int in existing_peer_ids:
		var existing_position: Vector2 = connected_peers[existing_peer_id]["position"]
		SpawnProtocol.spawn_peer.rpc_id(peer_id, existing_peer_id, existing_position)
		SpawnProtocol.spawn_peer.rpc_id(existing_peer_id, peer_id, spawn_position)

	SpawnProtocol.spawn_peer.rpc_id(peer_id, peer_id, spawn_position)
	print(
		"ServerMain: peer %d conectado. Total conectado: %d."
		% [peer_id, connected_peers.size()]
	)


func _on_peer_disconnected(peer_id: int) -> void:
	connected_peers.erase(peer_id)
	for remaining_peer_id: int in connected_peers:
		SpawnProtocol.despawn_peer.rpc_id(remaining_peer_id, peer_id)
	print(
		"ServerMain: peer %d desconectado. Total conectado: %d."
		% [peer_id, connected_peers.size()]
	)


func _temporary_spawn_position(spawn_index: int) -> Vector2:
	return SPAWN_ORIGIN + SPAWN_OFFSET * spawn_index
