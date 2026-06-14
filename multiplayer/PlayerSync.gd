class_name PlayerSync
extends Node

## Componente inicial para sincronização visual de um Node2D.
##
## Ainda não é anexado a player.tscn: a cena atual possui input, câmera,
## inventário e PlayerStatus globais que precisam ser separados entre jogador
## local e remoto antes que múltiplas instâncias sejam seguras.

@export var target_path: NodePath = NodePath("..")
@export_range(1.0, 60.0, 1.0) var updates_per_second := 15.0
@export_range(0.0, 30.0, 0.5) var interpolation_speed := 12.0

var _target: Node2D
var _remote_position := Vector2.ZERO
var _remote_rotation := 0.0
var _send_accumulator := 0.0
var _has_remote_snapshot := false
var _server_authoritative := false


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node2D
	if _target == null:
		push_warning("PlayerSync precisa apontar para um Node2D válido.")
		set_process(false)
		return

	_remote_position = _target.global_position
	_remote_rotation = _target.global_rotation


func configure_authority(peer_id: int) -> void:
	set_multiplayer_authority(peer_id)


func configure_server_authoritative(enabled: bool) -> void:
	_server_authoritative = enabled


func apply_server_snapshot(position: Vector2) -> void:
	_remote_position = position
	_has_remote_snapshot = true


func _process(delta: float) -> void:
	if is_multiplayer_authority() and not _server_authoritative:
		_send_accumulator += delta
		var update_interval := 1.0 / updates_per_second
		if _send_accumulator >= update_interval:
			_send_accumulator = fmod(_send_accumulator, update_interval)
			_receive_snapshot.rpc(_target.global_position, _target.global_rotation)
		return

	if not _has_remote_snapshot:
		return

	var weight := clampf(interpolation_speed * delta, 0.0, 1.0)
	_target.global_position = _target.global_position.lerp(_remote_position, weight)
	_target.global_rotation = lerp_angle(
		_target.global_rotation,
		_remote_rotation,
		weight,
	)


@rpc("authority", "call_remote", "unreliable_ordered")
func _receive_snapshot(position: Vector2, rotation: float) -> void:
	_remote_position = position
	_remote_rotation = rotation
	_has_remote_snapshot = true
