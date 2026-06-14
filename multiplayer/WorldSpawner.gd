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


func _spawn_player(peer_id: int) -> void:
	if _players == null or _spawn_points.is_empty():
		return

	var avatar_name := _avatar_name(peer_id)
	if _players.has_node(avatar_name):
		return

	var avatar := avatar_scene.instantiate() as SimpleAvatar
	if avatar == null:
		push_error("WorldSpawner: a cena configurada não instancia SimpleAvatar.")
		return

	avatar.configure(peer_id)
	avatar.position = _spawn_points[_players.get_child_count() % _spawn_points.size()].position
	_players.add_child(avatar)


func _despawn_player(peer_id: int) -> void:
	if _players == null:
		return

	var avatar := _players.get_node_or_null(_avatar_name(peer_id))
	if avatar != null:
		avatar.queue_free()


func _avatar_name(peer_id: int) -> String:
	return "Peer%d" % peer_id
