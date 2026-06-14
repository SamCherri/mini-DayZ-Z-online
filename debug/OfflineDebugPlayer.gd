extends CharacterBody2D

@export var speed := 150.0


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 28.0, Color(0.1, 0.95, 0.35))
	draw_circle(Vector2.ZERO, 28.0, Color.WHITE, false, 4.0)
	draw_line(Vector2(-18, 0), Vector2(18, 0), Color(0.02, 0.2, 0.05), 4.0)
	draw_line(Vector2(0, -18), Vector2(0, 18), Color(0.02, 0.2, 0.05), 4.0)
