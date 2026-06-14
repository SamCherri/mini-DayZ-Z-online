extends Node

## Camada inicial de conexão ENet.
##
## Este autoload não inicia rede sozinho e não altera o mundo offline. A cena
## que futuramente controlar o lobby deve chamar create_host() ou join_host()
## e responder aos sinais de spawn/despawn.

signal connection_state_changed(state: ConnectionState)
signal connection_failed(message: String)
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal player_spawn_requested(peer_id: int)
signal player_despawn_requested(peer_id: int)

enum ConnectionState {
	OFFLINE,
	HOSTING,
	CONNECTING,
	CONNECTED,
}

const DEFAULT_ADDRESS := "127.0.0.1"
const DEFAULT_PORT := 7000
const DEFAULT_MAX_CLIENTS := 8
const SERVER_PEER_ID := 1
const DEDICATED_SERVER_ARGUMENT := "--dedicated-server"
const CONNECT_ARGUMENT := "--connect"
const PORT_ARGUMENT := "--port"
const TEST_NAME_ARGUMENT := "--test-name"
const MAX_PORT := 65535

var connection_state := ConnectionState.OFFLINE


func _ready() -> void:
	if DEDICATED_SERVER_ARGUMENT in OS.get_cmdline_user_args():
		return

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	call_deferred("_start_from_command_line")


func create_host(
	port: int = DEFAULT_PORT,
	max_clients: int = DEFAULT_MAX_CLIENTS,
) -> Error:
	if not _can_start_connection():
		return ERR_ALREADY_IN_USE

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, max_clients)
	if error != OK:
		connection_failed.emit(
			"Não foi possível criar o host local na porta %d (erro %d)." % [port, error]
		)
		return error

	multiplayer.multiplayer_peer = peer
	_set_connection_state(ConnectionState.HOSTING)
	player_spawn_requested.emit(multiplayer.get_unique_id())
	return OK


func join_host(
	address: String = DEFAULT_ADDRESS,
	port: int = DEFAULT_PORT,
) -> Error:
	if not _can_start_connection():
		return ERR_ALREADY_IN_USE

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK:
		connection_failed.emit(
			"Não foi possível iniciar a conexão com %s:%d (erro %d)." % [
				address,
				port,
				error,
			]
		)
		return error

	multiplayer.multiplayer_peer = peer
	_set_connection_state(ConnectionState.CONNECTING)
	return OK


func disconnect_from_session() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_connection_state(ConnectionState.OFFLINE)


func is_session_active() -> bool:
	return connection_state != ConnectionState.OFFLINE


func _start_from_command_line() -> void:
	var arguments := OS.get_cmdline_user_args()
	if "--host" in arguments:
		var error := create_host()
		if error == OK:
			print("NetworkManager: host local iniciado na porta %d." % DEFAULT_PORT)
		return

	var connect_argument_index := arguments.find(CONNECT_ARGUMENT)
	if connect_argument_index == -1:
		return
	if connect_argument_index + 1 >= arguments.size():
		connection_failed.emit("Informe um endereço depois de --connect.")
		return

	var address := arguments[connect_argument_index + 1]
	if address.begins_with("--"):
		connection_failed.emit("Informe um endereço válido depois de --connect.")
		return

	var port := _read_port_argument(arguments)
	var error := join_host(address, port)
	if error == OK:
		print("NetworkManager: conectando a %s:%d." % [address, port])


func _read_port_argument(arguments: PackedStringArray) -> int:
	var port_argument_index := arguments.find(PORT_ARGUMENT)
	if port_argument_index == -1:
		return DEFAULT_PORT
	if port_argument_index + 1 >= arguments.size():
		push_warning(
			"NetworkManager: --port sem valor; usando a porta padrão %d."
			% DEFAULT_PORT
		)
		return DEFAULT_PORT

	var raw_port := arguments[port_argument_index + 1]
	if not raw_port.is_valid_int():
		push_warning(
			"NetworkManager: porta inválida (%s); usando a porta padrão %d."
			% [raw_port, DEFAULT_PORT]
		)
		return DEFAULT_PORT

	var port := raw_port.to_int()
	if port < 1 or port > MAX_PORT:
		push_warning(
			"NetworkManager: porta fora da faixa 1-%d (%s); usando a porta padrão %d."
			% [MAX_PORT, raw_port, DEFAULT_PORT]
		)
		return DEFAULT_PORT

	return port


func _can_start_connection() -> bool:
	if is_session_active():
		connection_failed.emit("Já existe uma sessão de rede ativa.")
		return false
	return true


func _set_connection_state(new_state: ConnectionState) -> void:
	if connection_state == new_state:
		return
	connection_state = new_state
	connection_state_changed.emit(connection_state)


func _on_peer_connected(peer_id: int) -> void:
	print("NetworkManager: peer %d conectado." % peer_id)
	peer_connected.emit(peer_id)
	if multiplayer.is_server():
		player_spawn_requested.emit(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("NetworkManager: peer %d desconectado." % peer_id)
	peer_disconnected.emit(peer_id)
	player_despawn_requested.emit(peer_id)


func _on_connected_to_server() -> void:
	_set_connection_state(ConnectionState.CONNECTED)
	peer_connected.emit(SERVER_PEER_ID)
	player_spawn_requested.emit(SERVER_PEER_ID)
	player_spawn_requested.emit(multiplayer.get_unique_id())
	var display_name := _read_test_name_argument(OS.get_cmdline_user_args())
	SessionProtocol.request_session.rpc_id(SERVER_PEER_ID, display_name)
	print("NetworkManager: solicitando sessão temporária como %s." % display_name)


func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_connection_state(ConnectionState.OFFLINE)
	connection_failed.emit("A conexão com o host falhou.")


func _on_server_disconnected() -> void:
	var local_peer_id := multiplayer.get_unique_id()
	player_despawn_requested.emit(SERVER_PEER_ID)
	if local_peer_id != SERVER_PEER_ID:
		player_despawn_requested.emit(local_peer_id)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_connection_state(ConnectionState.OFFLINE)
	peer_disconnected.emit(SERVER_PEER_ID)
	connection_failed.emit("O host encerrou a sessão.")


func _read_test_name_argument(arguments: PackedStringArray) -> String:
	var name_argument_index := arguments.find(TEST_NAME_ARGUMENT)
	if (
		name_argument_index != -1
		and name_argument_index + 1 < arguments.size()
		and not arguments[name_argument_index + 1].begins_with("--")
	):
		return arguments[name_argument_index + 1]

	return "Guest%d" % multiplayer.get_unique_id()
