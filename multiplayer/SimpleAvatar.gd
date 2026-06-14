class_name SimpleAvatar
extends CharacterBody2D

## Representação visual temporária usada somente pelo smoke test multiplayer.
##
## Não contém câmera, HUD, inventário, status ou regras de gameplay. O input
## simples existe apenas para confirmar visualmente a autoridade e o PlayerSync.

@export_range(10.0, 300.0, 1.0) var movement_speed := 90.0

@onready var body: Polygon2D = $Body
@onready var peer_label: Label = $PeerLabel
@onready var player_sync: PlayerSync = $PlayerSync

var peer_id := 0


func configure(new_peer_id: int) -> void:
	peer_id = new_peer_id
	name = "Peer%d" % peer_id
	set_multiplayer_authority(peer_id)


func _ready() -> void:
	if peer_id <= 0:
		peer_id = get_multiplayer_authority()

	player_sync.configure_authority(peer_id)
	peer_label.text = "Peer %d" % peer_id
	body.color = Color("4fc3f7") if is_multiplayer_authority() else Color("ffb74d")


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		velocity = Vector2.ZERO
		return

	velocity = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down",
	) * movement_speed
	move_and_slide()
