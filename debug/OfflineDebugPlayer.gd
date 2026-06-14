extends CharacterBody2D

const AssetCatalog := preload("res://debug/OfflineMvpAssetCatalog.gd")

@export var speed := 175.0

@onready var sprite: Sprite2D = $Visual
@onready var fallback_label: Label = $FallbackLabel

var movement_bounds := Rect2(Vector2(-100000, -100000), Vector2(200000, 200000))
var using_real_asset := false


func _ready() -> void:
	var texture := AssetCatalog.load_texture(AssetCatalog.PLAYER_SPRITE, "player")
	if texture != null:
		sprite.texture = texture
		AssetCatalog.apply_sheet_frame(sprite, 4, 11, 0)
		sprite.scale = Vector2(1.8, 1.8)
		sprite.visible = true
		using_real_asset = true
	fallback_label.visible = not using_real_asset
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	position = position.clamp(movement_bounds.position, movement_bounds.end)
	if absf(direction.x) > 0.05 and using_real_asset:
		sprite.flip_h = direction.x < 0.0


func set_movement_bounds(bounds: Rect2) -> void:
	movement_bounds = bounds


func get_asset_status() -> String:
	return "real" if using_real_asset else "fallback"


func _draw() -> void:
	if using_real_asset:
		return
	draw_circle(Vector2.ZERO, 32.0, Color(0.1, 0.95, 0.35))
	draw_circle(Vector2.ZERO, 32.0, Color.WHITE, false, 5.0)
	draw_line(Vector2(-18, 0), Vector2(18, 0), Color(0.02, 0.2, 0.05), 4.0)
	draw_line(Vector2(0, -18), Vector2(0, 18), Color(0.02, 0.2, 0.05), 4.0)
