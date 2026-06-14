extends CharacterBody2D

@export var speed := 150.0

var movement_bounds := Rect2(Vector2(-100000, -100000), Vector2(200000, 200000))


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	position = position.clamp(movement_bounds.position, movement_bounds.end)
	queue_redraw()


func set_movement_bounds(bounds: Rect2) -> void:
	movement_bounds = bounds


func _draw() -> void:
	draw_circle(Vector2.ZERO, 32.0, Color(0.1, 0.95, 0.35))
	draw_circle(Vector2.ZERO, 32.0, Color.WHITE, false, 5.0)
	draw_line(Vector2(-18, 0), Vector2(18, 0), Color(0.02, 0.2, 0.05), 4.0)
	draw_line(Vector2(0, -18), Vector2(0, 18), Color(0.02, 0.2, 0.05), 4.0)
