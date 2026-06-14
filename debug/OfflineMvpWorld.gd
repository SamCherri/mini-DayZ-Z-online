extends Node2D

const AssetCatalog := preload("res://debug/OfflineMvpAssetCatalog.gd")
const ZombieScene := preload("res://debug/OfflineMvpZombie.tscn")

const MAP_SIZE := Vector2(3000.0, 3000.0)
const PLAYER_START := MAP_SIZE * 0.5
const INTERACTION_DISTANCE := 145.0
const ZOMBIE_WARNING_DISTANCE := 125.0

const TREE_POSITIONS := [
	Vector2(180, 230), Vector2(380, 510), Vector2(610, 210), Vector2(820, 690),
	Vector2(1050, 320), Vector2(1260, 620), Vector2(1430, 210), Vector2(1720, 430),
	Vector2(2020, 210), Vector2(2290, 540), Vector2(2580, 260), Vector2(2810, 680),
	Vector2(240, 1060), Vector2(560, 1260), Vector2(880, 1120), Vector2(2180, 1160),
	Vector2(2600, 1050), Vector2(2820, 1380), Vector2(210, 1820), Vector2(510, 2090),
	Vector2(810, 1760), Vector2(1120, 2240), Vector2(260, 2670), Vector2(720, 2760),
	Vector2(1320, 2660), Vector2(1790, 2780), Vector2(2240, 2470), Vector2(2730, 2740),
]
const DIRT_PATCHES := [
	[Vector2(420, 880), Vector2(260, 150)],
	[Vector2(2350, 1880), Vector2(360, 220)],
	[Vector2(850, 2440), Vector2(280, 170)],
]
const LOOT_POSITIONS := [
	Vector2(1320, 1320), Vector2(1730, 1490), Vector2(1560, 1840),
]
const ZOMBIE_POSITIONS := [
	Vector2(1120, 1580), Vector2(1940, 1370), Vector2(1780, 2110),
	Vector2(920, 920), Vector2(2440, 1760),
]
const BUILDINGS := [
	{"path": "res://asset/images/building/b_city_house_1-sheet0.png", "position": Vector2(480, 1450), "label": "CASA", "scale": 0.85},
	{"path": "res://asset/images/building/b_gas_station-sheet0.png", "position": Vector2(2360, 1430), "label": "POSTO", "scale": 1.55},
	{"path": "res://asset/images/building/b_shed-sheet0.png", "position": Vector2(2190, 760), "label": "GALPÃO", "scale": 1.0},
	{"path": "res://asset/images/building/b_hospital-sheet0.png", "position": Vector2(700, 700), "label": "HOSPITAL", "scale": 0.8},
]
const OBJECTS := [
	{"path": "res://asset/images/environment/car/car_regular.png", "position": Vector2(1640, 1280), "scale": 0.5},
	{"path": "res://asset/images/environment/obst_barricade-sheet0.png", "position": Vector2(1380, 1670), "scale": 1.0},
]

@onready var player: CharacterBody2D = $OfflineDebugPlayer
@onready var camera: Camera2D = $OfflineDebugPlayer/Camera2D
@onready var feedback_label: Label = $Hud/Root/Feedback
@onready var health_label: Label = $Hud/Root/StatusPanel/Margin/Status
@onready var asset_label: Label = $Hud/Root/AssetStatus

var fake_health := 100
var loot_nodes: Array[Node2D] = []
var zombie_nodes: Array[Node2D] = []
var zombie_warning_cooldown := 0.0
var real_tree_count := 0
var real_building_count := 0


func _ready() -> void:
	player.position = PLAYER_START
	player.set_movement_bounds(Rect2(Vector2(45, 45), MAP_SIZE - Vector2(90, 90)))
	_create_visual_scenery()
	_create_loot()
	_create_zombies()
	queue_redraw()
	_update_asset_status()
	_show_feedback("Explore o mapa e aproxime-se de uma caixa")
	print("[OfflineMvpWorld] cenário visual pronto: %d árvores, %d construções, %d caixas, %d zumbis" % [
		real_tree_count, real_building_count, loot_nodes.size(), zombie_nodes.size(),
	])


func _process(delta: float) -> void:
	zombie_warning_cooldown = maxf(zombie_warning_cooldown - delta, 0.0)
	_move_fake_zombies(delta)
	_check_zombie_proximity()
	_show_nearby_loot_hint()

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("toggle_inventory"):
		_show_feedback("Inventário debug: mochila offline vazia")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("#263b27"))
	for patch in DIRT_PATCHES:
		draw_rect(Rect2(patch[0], patch[1]), Color("#544c35"))
	# Estradas em cruz e acostamentos mantêm a leitura mesmo se o atlas não importar.
	draw_rect(Rect2(0, 1360, MAP_SIZE.x, 280), Color("#3d3b36"))
	draw_rect(Rect2(1360, 0, 280, MAP_SIZE.y), Color("#3d3b36"))
	draw_rect(Rect2(0, 1390, MAP_SIZE.x, 220), Color("#696050"))
	draw_rect(Rect2(1390, 0, 220, MAP_SIZE.y), Color("#696050"))
	for x in range(20, int(MAP_SIZE.x), 180):
		draw_rect(Rect2(x, 1492, 95, 16), Color("#b9a779"))
	for y in range(20, int(MAP_SIZE.y), 180):
		draw_rect(Rect2(1492, y, 16, 95), Color("#b9a779"))
	draw_circle(PLAYER_START, 270.0, Color("#405b35"))
	draw_arc(PLAYER_START, 275.0, 0.0, TAU, 64, Color("#ac9560"), 10.0)
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("#a88f58"), false, 18.0)


func _create_visual_scenery() -> void:
	for index in TREE_POSITIONS.size():
		var path: String = AssetCatalog.TREE_SPRITES[index % AssetCatalog.TREE_SPRITES.size()]
		var tree := _create_sprite(path, "árvore", TREE_POSITIONS[index], 0.72)
		if tree != null:
			tree.z_index = int(tree.position.y / 10.0)
			real_tree_count += 1
		else:
			_create_fallback_marker(TREE_POSITIONS[index], "ÁRVORE", Color("#275b2b"), Vector2(80, 80))

	for building in BUILDINGS:
		var sprite := _create_sprite(
			building.path, "construção %s" % building.label,
			building.position, building.scale
		)
		if sprite != null:
			sprite.z_index = 35
			real_building_count += 1
		else:
			_create_fallback_marker(building.position, building.label, Color("#786044"), Vector2(250, 170))

	for object_data in OBJECTS:
		var sprite := _create_sprite(
			object_data.path, "objeto de cenário", object_data.position, object_data.scale
		)
		if sprite != null:
			sprite.z_index = 45


func _create_sprite(path: String, label: String, at: Vector2, scale_value: float) -> Sprite2D:
	var texture := AssetCatalog.load_texture(path, label)
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = at
	sprite.scale = Vector2(scale_value, scale_value)
	$Scenery.add_child(sprite)
	return sprite


func _create_fallback_marker(at: Vector2, label_text: String, color: Color, size: Vector2) -> void:
	var marker := Polygon2D.new()
	marker.position = at
	marker.polygon = PackedVector2Array([
		-size * 0.5, Vector2(size.x * 0.5, -size.y * 0.5),
		size * 0.5, Vector2(-size.x * 0.5, size.y * 0.5),
	])
	marker.color = color
	$Scenery.add_child(marker)
	var label := Label.new()
	label.text = label_text
	label.position = at - Vector2(size.x * 0.5, size.y * 0.7)
	label.add_theme_font_size_override("font_size", 16)
	$Scenery.add_child(label)


func _create_loot() -> void:
	for index in LOOT_POSITIONS.size():
		var loot := Node2D.new()
		loot.name = "FakeLootBox%d" % (index + 1)
		loot.position = LOOT_POSITIONS[index]
		loot.z_index = 60
		loot.set_script(preload("res://debug/OfflineMvpLoot.gd"))
		$Objects.add_child(loot)
		loot_nodes.append(loot)


func _create_zombies() -> void:
	for index in ZOMBIE_POSITIONS.size():
		var zombie := ZombieScene.instantiate() as Node2D
		if zombie == null:
			continue
		zombie.name = "FakeZombie%d" % (index + 1)
		zombie.position = ZOMBIE_POSITIONS[index]
		zombie.set_meta("origin", ZOMBIE_POSITIONS[index])
		zombie.set_meta("phase", float(index) * 2.1)
		zombie.set_meta("variant", index % AssetCatalog.ZOMBIE_SPRITES.size())
		$Objects.add_child(zombie)
		zombie_nodes.append(zombie)


func _move_fake_zombies(delta: float) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0
	for zombie in zombie_nodes:
		var origin: Vector2 = zombie.get_meta("origin")
		var phase: float = zombie.get_meta("phase")
		var patrol_target := origin + Vector2(cos(elapsed * 0.45 + phase), sin(elapsed * 0.32 + phase)) * 75.0
		var target := player.position if zombie.position.distance_to(player.position) < 300.0 else patrol_target
		var old_position := zombie.position
		zombie.position = zombie.position.move_toward(target, 32.0 * delta)
		zombie.call("face_direction", zombie.position - old_position)


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
		_show_feedback("Interagiu com caixa: item fake encontrado")
		print("[OfflineMvpWorld] interação com %s" % nearest.name)
	else:
		_show_feedback("Nenhuma caixa por perto")


func _show_nearby_loot_hint() -> void:
	if feedback_label.text.begins_with("Interagiu") or feedback_label.text.begins_with("Zumbi"):
		return
	for loot in loot_nodes:
		if player.position.distance_to(loot.position) <= INTERACTION_DISTANCE:
			_show_feedback("Caixa próxima — toque em Ação")
			return


func _check_zombie_proximity() -> void:
	if zombie_warning_cooldown > 0.0:
		return
	for zombie in zombie_nodes:
		if player.position.distance_to(zombie.position) <= ZOMBIE_WARNING_DISTANCE:
			fake_health = maxi(fake_health - 3, 0)
			health_label.text = "VIDA %d   FOME 82   SEDE 74" % fake_health
			_show_feedback("Zumbi próximo! Vida fake -3")
			zombie_warning_cooldown = 1.5
			return


func _update_asset_status() -> void:
	var zombie_status := "fallback"
	if not zombie_nodes.is_empty():
		zombie_status = zombie_nodes[0].call("get_asset_status")
	asset_label.text = "Player asset: %s | Zumbis: %s | Cenário real: %d sprites" % [
		player.call("get_asset_status"), zombie_status, real_tree_count + real_building_count,
	]


func _show_feedback(message: String) -> void:
	feedback_label.text = message


func get_debug_summary() -> Dictionary:
	return {
		"player_active": is_instance_valid(player),
		"camera_active": is_instance_valid(camera) and camera.enabled,
		"player_asset": player.call("get_asset_status"),
		"object_count": TREE_POSITIONS.size() + BUILDINGS.size() + OBJECTS.size() + loot_nodes.size(),
		"zombie_count": zombie_nodes.size(),
		"visual_asset_count": real_tree_count + real_building_count,
	}
