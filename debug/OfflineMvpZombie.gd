extends Node2D

const AssetCatalog := preload("res://debug/OfflineMvpAssetCatalog.gd")

@onready var sprite: Sprite2D = $Visual
@onready var fallback_label: Label = $FallbackLabel

var using_real_asset := false


func _ready() -> void:
	var variant := int(get_meta("variant", 0)) % AssetCatalog.ZOMBIE_SPRITES.size()
	var texture := AssetCatalog.load_texture(AssetCatalog.ZOMBIE_SPRITES[variant], "zumbi")
	if texture != null:
		sprite.texture = texture
		var rows := 13 if variant == 1 else 14
		if variant == 2:
			rows = 10
		AssetCatalog.apply_sheet_frame(sprite, 4, rows, 0)
		sprite.scale = Vector2(1.65, 1.65)
		sprite.visible = true
		using_real_asset = true
	fallback_label.visible = not using_real_asset
	queue_redraw()


func _draw() -> void:
	if using_real_asset:
		return
	draw_circle(Vector2.ZERO, 31.0, Color("#9e2828"))
	draw_circle(Vector2.ZERO, 31.0, Color("#ff8b78"), false, 5.0)
	draw_circle(Vector2(-10, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(10, -5), 4.0, Color.WHITE)
	draw_line(Vector2(-12, 13), Vector2(12, 13), Color("#3b0b0b"), 4.0)

func face_direction(direction: Vector2) -> void:
	if using_real_asset and absf(direction.x) > 0.05:
		sprite.flip_h = direction.x < 0.0


func get_asset_status() -> String:
	return "real" if using_real_asset else "fallback"
