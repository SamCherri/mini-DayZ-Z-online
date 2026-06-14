extends Node

## Converte os sinais do NetworkManager em avatares visuais temporários.
##
## Este script pertence somente à cena cliente/host do smoke test. O servidor
## dedicado usa server/server_main.tscn e não carrega este mundo ou avatares.

const DEDICATED_SERVER_ARGUMENT := "--dedicated-server"

@export var avatar_scene: PackedScene
@export var players_path := NodePath("../Players")
@export var spawn_points_path := NodePath("../SpawnPoints")

var _players: Node2D
var _spawn_points: Array[Node2D] = []
var _dedicated_protocol_active := false


func _ready() -> void:
	if DEDICATED_SERVER_ARGUMENT in OS.get_cmdline_user_args():
		return

	_players = get_node_or_null(players_path) as Node2D
	var spawn_points := get_node_or_null(spawn_points_path)
	if _players == null or spawn_points == null or avatar_scene == null:
		push_error("WorldSpawner: configuração de mundo incompleta.")
		return

	for child in spawn_points.get_children():
		if child is Node2D:
			_spawn_points.append(child)

	if _spawn_points.is_empty():
		push_error("WorldSpawner: nenhum ponto de spawn foi configurado.")
		return

	NetworkManager.player_spawn_requested.connect(_spawn_player)
	NetworkManager.player_despawn_requested.connect(_despawn_player)
	SpawnProtocol.spawn_peer_received.connect(_spawn_authorized_peer)
	SpawnProtocol.despawn_peer_received.connect(_despawn_player)


func _spawn_player(peer_id: int) -> void:
	if _players == null or _spawn_points.is_empty():
		return
	var spawn_position := _spawn_points[
		_players.get_child_count() % _spawn_points.size()
	].position
	_spawn_player_at(peer_id, spawn_position)


func _spawn_authorized_peer(peer_id: int, position: Vector2) -> void:
	if not _dedicated_protocol_active:
		_dedicated_protocol_active = true
		for child in _players.get_children():
			_players.remove_child(child)
			child.queue_free()
	_spawn_player_at(peer_id, position)


func _spawn_player_at(peer_id: int, position: Vector2) -> void:
	if _players == null or _spawn_points.is_empty():
		return

	var avatar_name := _avatar_name(peer_id)
	if _players.has_node(avatar_name):
		var existing_avatar := _players.get_node(avatar_name) as Node2D
		existing_avatar.position = position
		return

	var avatar := avatar_scene.instantiate() as SimpleAvatar
	if avatar == null:
		push_error("WorldSpawner: a cena configurada não instancia SimpleAvatar.")
		return

	avatar.configure(peer_id)
	avatar.position = position
	_players.add_child(avatar)


func _despawn_player(peer_id: int) -> void:
	if _players == null:
		return

	var avatar := _players.get_node_or_null(_avatar_name(peer_id))
	if avatar != null:
		avatar.queue_free()


func _avatar_name(peer_id: int) -> String:
	return "Peer%d" % peer_id
