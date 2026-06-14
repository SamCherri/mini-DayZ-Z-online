extends Node2D

const MAP_SIZE := Vector2(3000.0, 3000.0)
const PLAYER_START := MAP_SIZE * 0.5
const INTERACTION_DISTANCE := 145.0
const ZOMBIE_WARNING_DISTANCE := 115.0

const TREE_POSITIONS := [
	Vector2(260, 310), Vector2(520, 650), Vector2(820, 280),
	Vector2(1110, 570), Vector2(1420, 260), Vector2(1760, 520),
	Vector2(2140, 300), Vector2(2500, 620), Vector2(2740, 330),
	Vector2(330, 1230), Vector2(690, 1740), Vector2(420, 2570),
	Vector2(1180, 2420), Vector2(1830, 2580), Vector2(2320, 2210),
	Vector2(2700, 2650),
]
const ROCK_POSITIONS := [
	Vector2(720, 1020), Vector2(1180, 920), Vector2(1940, 1080),
	Vector2(2520, 1320), Vector2(920, 2140), Vector2(2050, 1940),
]
const LOOT_POSITIONS := [
	Vector2(1320, 1320), Vector2(1730, 1490), Vector2(1560, 1840),
]
const ZOMBIE_POSITIONS := [
	Vector2(1120, 1580), Vector2(1940, 1370), Vector2(1780, 2110),
]

@onready var player: CharacterBody2D = $OfflineDebugPlayer
@onready var camera: Camera2D = $OfflineDebugPlayer/Camera2D
@onready var feedback_label: Label = $Hud/Root/Feedback
@onready var health_label: Label = $Hud/Root/StatusPanel/Margin/Status

var fake_health := 100
var loot_nodes: Array[Node2D] = []
var zombie_nodes: Array[Node2D] = []
var zombie_warning_cooldown := 0.0


func _ready() -> void:
	player.position = PLAYER_START
	player.set_movement_bounds(Rect2(Vector2(45, 45), MAP_SIZE - Vector2(90, 90)))
	_create_loot()
	_create_zombies()
	queue_redraw()
	_show_feedback("Explore o mapa e aproxime-se de uma caixa")
	print("[OfflineMvpWorld] mapa procedural pronto: %d objetos, %d caixas, %d zumbis" % [
		TREE_POSITIONS.size() + ROCK_POSITIONS.size(),
		loot_nodes.size(),
		zombie_nodes.size(),
	])


func _process(delta: float) -> void:
	zombie_warning_cooldown = maxf(zombie_warning_cooldown - delta, 0.0)
	_move_fake_zombies(delta)
	_check_zombie_proximity()

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("toggle_inventory"):
		_show_feedback("Inventário debug")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("#29452d"))
	_draw_grid()

	# Estradas largas que cruzam o mapa e tornam o deslocamento visível.
	draw_rect(Rect2(0, 1380, MAP_SIZE.x, 240), Color("#6a604d"))
	draw_rect(Rect2(1380, 0, 240, MAP_SIZE.y), Color("#6a604d"))
	draw_rect(Rect2(0, 1472, MAP_SIZE.x, 56), Color("#9b8c68"))
	draw_rect(Rect2(1472, 0, 56, MAP_SIZE.y), Color("#9b8c68"))

	# Clareira/base central.
	draw_circle(PLAYER_START, 310.0, Color("#496b3d"))
	draw_circle(PLAYER_START, 315.0, Color("#b7a36b"), false, 10.0)
	draw_string(ThemeDB.fallback_font, Vector2(PLAYER_START.x - 118, PLAYER_START.y - 240),
		"BASE OFFLINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color.WHITE)

	for position in TREE_POSITIONS:
		_draw_tree(position)
	for position in ROCK_POSITIONS:
		_draw_rock(position)

	draw_rect(Rect2(2140, 780, 360, 250), Color("#343c42"))
	draw_rect(Rect2(2170, 810, 300, 190), Color("#8c734e"))
	draw_string(ThemeDB.fallback_font, Vector2(2210, 925), "ABRIGO", HORIZONTAL_ALIGNMENT_LEFT,
		-1, 30, Color.WHITE)

	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("#d2bd78"), false, 18.0)


func _draw_grid() -> void:
	for x in range(0, int(MAP_SIZE.x) + 1, 150):
		draw_line(Vector2(x, 0), Vector2(x, MAP_SIZE.y), Color(0.15, 0.25, 0.16, 0.45), 3.0)
	for y in range(0, int(MAP_SIZE.y) + 1, 150):
		draw_line(Vector2(0, y), Vector2(MAP_SIZE.x, y), Color(0.15, 0.25, 0.16, 0.45), 3.0)


func _draw_tree(position: Vector2) -> void:
	draw_circle(position + Vector2(0, 18), 34.0, Color("#3a281a"))
	draw_circle(position, 66.0, Color("#15351d"))
	draw_circle(position - Vector2(20, 18), 38.0, Color("#24703a"))
	draw_circle(position + Vector2(26, -10), 34.0, Color("#2f8546"))


func _draw_rock(position: Vector2) -> void:
	var points := PackedVector2Array([
		position + Vector2(-48, 24), position + Vector2(-25, -38),
		position + Vector2(30, -45), position + Vector2(54, 18),
		position + Vector2(12, 45),
	])
	draw_colored_polygon(points, Color("#59636a"))
	draw_polyline(points, Color("#a7b0b3"), 5.0)
	draw_line(points[-1], points[0], Color("#a7b0b3"), 5.0)


func _create_loot() -> void:
	for index in LOOT_POSITIONS.size():
		var loot := Node2D.new()
		loot.name = "FakeLootBox%d" % (index + 1)
		loot.position = LOOT_POSITIONS[index]
		loot.set_script(preload("res://debug/OfflineMvpLoot.gd"))
		$Objects.add_child(loot)
		loot_nodes.append(loot)


func _create_zombies() -> void:
	for index in ZOMBIE_POSITIONS.size():
		var zombie := Node2D.new()
		zombie.name = "FakeZombie%d" % (index + 1)
		zombie.position = ZOMBIE_POSITIONS[index]
		zombie.set_meta("origin", ZOMBIE_POSITIONS[index])
		zombie.set_meta("phase", float(index) * 2.1)
		zombie.set_script(preload("res://debug/OfflineMvpZombie.gd"))
		$Objects.add_child(zombie)
		zombie_nodes.append(zombie)


func _move_fake_zombies(delta: float) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0
	for zombie in zombie_nodes:
		var origin: Vector2 = zombie.get_meta("origin")
		var phase: float = zombie.get_meta("phase")
		var target := origin + Vector2(cos(elapsed * 0.45 + phase), sin(elapsed * 0.32 + phase)) * 70.0
		zombie.position = zombie.position.move_toward(target, 28.0 * delta)


func _try_interact() -> void:
	var nearest: Node2D
	var nearest_distance := INF
	for loot in loot_nodes:
		var distance := player.position.distance_to(loot.position)
		if distance < nearest_distance:
			nearest = loot
			nearest_distance = distance

	if nearest != null and nearest_distance <= INTERACTION_DISTANCE:
		nearest.call("flash")
		_show_feedback("Interagiu com caixa")
		print("[OfflineMvpWorld] interação com %s" % nearest.name)
	else:
		_show_feedback("Ação debug: nenhuma caixa por perto")


func _check_zombie_proximity() -> void:
	if zombie_warning_cooldown > 0.0:
		return
	for zombie in zombie_nodes:
		if player.position.distance_to(zombie.position) <= ZOMBIE_WARNING_DISTANCE:
			fake_health = maxi(fake_health - 5, 0)
			health_label.text = "VIDA %d   FOME 82   SEDE 74" % fake_health
			_show_feedback("Zumbi próximo! Vida fake -5")
			zombie_warning_cooldown = 1.5
			return


func _show_feedback(message: String) -> void:
	feedback_label.text = message


func get_debug_summary() -> Dictionary:
	return {
		"player_active": is_instance_valid(player),
		"camera_active": is_instance_valid(camera) and camera.enabled,
		"object_count": TREE_POSITIONS.size() + ROCK_POSITIONS.size() + loot_nodes.size() + 1,
		"zombie_count": zombie_nodes.size(),
	}
