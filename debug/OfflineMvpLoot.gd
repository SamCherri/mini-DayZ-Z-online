extends Node2D

const AssetCatalog := preload("res://debug/OfflineMvpAssetCatalog.gd")

var highlight := 0.0
var using_real_asset := false
var sprite: Sprite2D


func _ready() -> void:
	var texture := AssetCatalog.load_texture(AssetCatalog.LOOT_SPRITE, "caixa de loot")
	if texture != null:
		sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2(1.8, 1.8)
		add_child(sprite)
		using_real_asset = true
	queue_redraw()


func _process(delta: float) -> void:
	if highlight > 0.0:
		highlight = maxf(highlight - delta, 0.0)
		if using_real_asset:
			sprite.modulate = Color("#ffe36e") if highlight > 0.0 else Color.WHITE
		queue_redraw()


func flash() -> void:
	highlight = 0.6
	queue_redraw()


func _draw() -> void:
	if using_real_asset:
		return
	var color := Color("#ffd95a") if highlight > 0.0 else Color("#a96d32")
	draw_rect(Rect2(-42, -30, 84, 60), color)
	draw_rect(Rect2(-42, -30, 84, 60), Color("#f4d28b"), false, 5.0)
	draw_line(Vector2(-42, -5), Vector2(42, -5), Color("#593719"), 5.0)
	draw_rect(Rect2(-9, -13, 18, 24), Color("#e7c34d"))
	draw_string(ThemeDB.fallback_font, Vector2(-52, -43), "CAIXA", HORIZONTAL_ALIGNMENT_LEFT,
		-1, 18, Color.WHITE)
