extends Control

const WORLD_PATH := "res://world.tscn"

@onready var background: ColorRect = $DebugUI/Background
@onready var boot_panel: PanelContainer = $DebugUI/BootPanel
@onready var status_label: Label = $DebugUI/BootPanel/Margin/VBox/Status
@onready var build_label: Label = $DebugUI/BootPanel/Margin/VBox/Build
@onready var load_button: Button = $DebugUI/BootPanel/Margin/VBox/LoadWorld
@onready var world_loaded_badge: Label = $DebugUI/WorldLoadedBadge

var world_instance: Node
var load_in_progress := false


func _ready() -> void:
	print("[AndroidBootDebug] boot iniciado")
	status_label.text = "Boot iniciado"
	build_label.text = _build_description()
	load_button.pressed.connect(_on_load_world_pressed)

	# Give Android one rendered frame with diagnostic UI before loading the world.
	await get_tree().process_frame
	_load_world()


func _on_load_world_pressed() -> void:
	_load_world()


func _load_world() -> void:
	if load_in_progress:
		return

	if is_instance_valid(world_instance):
		status_label.text = "World carregado"
		return

	load_in_progress = true
	load_button.disabled = true
	status_label.text = "Carregando world.tscn"
	print("[AndroidBootDebug] tentativa de load: %s" % WORLD_PATH)

	var world_scene := load(WORLD_PATH) as PackedScene
	if world_scene == null:
		_show_load_error("recurso não encontrado ou inválido")
		return
	print("[AndroidBootDebug] load OK: %s" % WORLD_PATH)

	world_instance = world_scene.instantiate()
	if world_instance == null:
		_show_load_error("não foi possível instanciar a cena")
		return
	print("[AndroidBootDebug] instantiate OK: %s" % WORLD_PATH)

	add_child(world_instance)
	move_child(world_instance, 0)
	print("[AndroidBootDebug] add_child OK: %s" % WORLD_PATH)

	await get_tree().process_frame
	status_label.text = "World carregado"
	world_loaded_badge.visible = true
	boot_panel.visible = false
	background.visible = false
	load_in_progress = false


func _show_load_error(reason: String) -> void:
	var message := "Erro ao carregar world.tscn\n%s" % reason
	status_label.text = message
	load_button.disabled = false
	load_in_progress = false
	print("[AndroidBootDebug] erro com path %s: %s" % [WORLD_PATH, reason])


func _build_description() -> String:
	var version := Engine.get_version_info()
	return "Build: Android offline debug\nGodot %s | %s" % [
		str(version.get("string", "desconhecida")),
		OS.get_name(),
	]
