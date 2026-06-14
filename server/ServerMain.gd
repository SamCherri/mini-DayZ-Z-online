extends Node

## Ponto de entrada mínimo do servidor dedicado.
##
## Esta fundação aceita conexões ENet e registra os peers ativos. Regras de
## gameplay, spawn de personagens, autenticação e persistência ficam fora
## deste primeiro marco.

const DEFAULT_PORT := 7000
const DEFAULT_MAX_CLIENTS := 8
const DEDICATED_SERVER_ARGUMENT := "--dedicated-server"
const PORT_ARGUMENT := "--port"
const MAX_CLIENTS_ARGUMENT := "--max-clients"

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
	connected_peers[peer_id] = Time.get_unix_time_from_system()
	print(
		"ServerMain: peer %d conectado. Total conectado: %d."
		% [peer_id, connected_peers.size()]
	)


func _on_peer_disconnected(peer_id: int) -> void:
	connected_peers.erase(peer_id)
	print(
		"ServerMain: peer %d desconectado. Total conectado: %d."
		% [peer_id, connected_peers.size()]
	)
