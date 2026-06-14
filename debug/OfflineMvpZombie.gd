extends Node2D


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 31.0, Color("#9e2828"))
	draw_circle(Vector2.ZERO, 31.0, Color("#ff8b78"), false, 5.0)
	draw_circle(Vector2(-10, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(10, -5), 4.0, Color.WHITE)
	draw_line(Vector2(-12, 13), Vector2(12, 13), Color("#3b0b0b"), 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(-43, -43), "ZUMBI", HORIZONTAL_ALIGNMENT_LEFT,
		-1, 17, Color("#ffd2cc"))
