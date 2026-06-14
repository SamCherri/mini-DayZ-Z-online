class_name SimpleAvatar
extends CharacterBody2D

## Representação visual temporária usada somente pelo smoke test multiplayer.
##
## Não contém câmera, HUD, inventário, status ou regras de gameplay. O input
## simples existe apenas para confirmar visualmente a autoridade e o PlayerSync.

@export_range(10.0, 300.0, 1.0) var movement_speed := 90.0
@export_range(1.0, 30.0, 1.0) var input_updates_per_second := 15.0

@onready var body: Polygon2D = $Body
@onready var peer_label: Label = $PeerLabel
@onready var player_sync: PlayerSync = $PlayerSync

var peer_id := 0
var _input_accumulator := 0.0
var _input_sequence := 0
var _server_authoritative_mode := false
var _test_move_enabled := false


func configure(new_peer_id: int) -> void:
	peer_id = new_peer_id
	name = "Peer%d" % peer_id
	set_multiplayer_authority(peer_id)


func _ready() -> void:
	if peer_id <= 0:
		peer_id = get_multiplayer_authority()

	player_sync.configure_authority(peer_id)
	_server_authoritative_mode = (
		NetworkManager.connection_state == NetworkManager.ConnectionState.CONNECTED
		and not multiplayer.is_server()
	)
	player_sync.configure_server_authoritative(_server_authoritative_mode)
	_test_move_enabled = "--test-move" in OS.get_cmdline_user_args()
	peer_label.text = "Peer %d" % peer_id
	body.color = Color("4fc3f7") if is_multiplayer_authority() else Color("ffb74d")


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		velocity = Vector2.ZERO
		return

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down",
	)
	if _test_move_enabled and input_direction.is_zero_approx():
		input_direction = Vector2.RIGHT

	if _server_authoritative_mode:
		velocity = Vector2.ZERO
		_input_accumulator += delta
		var input_interval := 1.0 / input_updates_per_second
		if _input_accumulator >= input_interval:
			_input_accumulator = fmod(_input_accumulator, input_interval)
			_input_sequence += 1
			MovementProtocol.submit_movement_input.rpc_id(
				MovementProtocol.SERVER_PEER_ID,
				input_direction,
				_input_sequence,
			)
		return

	velocity = input_direction * movement_speed
	move_and_slide()


func apply_server_snapshot(snapshot_position: Vector2) -> void:
	player_sync.apply_server_snapshot(snapshot_position)
