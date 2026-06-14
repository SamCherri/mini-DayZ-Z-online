extends Control

const WORLD_PATH := "res://world.tscn"
const OFFLINE_PLAYER_SCENE := preload("res://debug/OfflineDebugPlayer.tscn")
const MOBILE_CONTROLS_SCENE := preload("res://debug/MobileDebugControls.tscn")

@onready var background: ColorRect = $DebugUI/Background
@onready var boot_panel: PanelContainer = $DebugUI/BootPanel
@onready var status_label: Label = $DebugUI/BootPanel/Margin/VBox/Status
@onready var build_label: Label = $DebugUI/BootPanel/Margin/VBox/Build
@onready var load_button: Button = $DebugUI/BootPanel/Margin/VBox/LoadWorld
@onready var debug_panel: PanelContainer = $DebugUI/DebugPanel
@onready var debug_details: Label = $DebugUI/DebugPanel/Margin/VBox/Details
@onready var hide_debug_button: Button = $DebugUI/DebugPanel/Margin/VBox/HideDebug
@onready var screen_marker: Control = $MarkerLayer/ScreenMarker

var world_instance: Node
var debug_player: CharacterBody2D
var debug_camera: Camera2D
var mobile_controls: CanvasLayer
var load_in_progress := false
var camera_status := "Camera2D pendente"


func _ready() -> void:
	print("[AndroidBootDebug] boot manual iniciado; aguardando toque")
	status_label.text = "Pronto para carregar world.tscn\nToque em Carregar mundo"
	build_label.text = _build_description()
	load_button.pressed.connect(_on_load_world_pressed)
	hide_debug_button.pressed.connect(_on_hide_debug_pressed)


func _on_load_world_pressed() -> void:
	_load_world()


func _load_world() -> void:
	if load_in_progress or is_instance_valid(world_instance):
		return

	load_in_progress = true
	load_button.disabled = true
	status_label.text = "Carregando world.tscn"
	print("[AndroidBootDebug] tentativa de load: %s" % WORLD_PATH)

	var world_scene := load(WORLD_PATH) as PackedScene
	if world_scene == null:
		_show_load_error("recurso não encontrado ou inválido")
		return

	world_instance = world_scene.instantiate()
	if world_instance == null:
		_show_load_error("não foi possível instanciar a cena")
		return

	add_child(world_instance)
	move_child(world_instance, 0)
	print("[AndroidBootDebug] world carregado: %s (%s)" % [
		world_instance.name,
		world_instance.get_class(),
	])

	_create_world_marker(world_instance)
	_create_debug_player(world_instance)
	_ensure_debug_camera(world_instance)
	_create_mobile_controls()
	_show_loaded_state()


func _ensure_debug_camera(loaded_world: Node) -> void:
	var cameras := loaded_world.find_children("*", "Camera2D", true, false)
	for candidate in cameras:
		var camera := candidate as Camera2D
		if camera != null and camera.enabled:
			debug_camera = camera
			camera_status = "Camera2D encontrada"
			print("[AndroidBootDebug] câmera encontrada: %s" % camera.get_path())
			break

	if debug_camera == null:
		debug_camera = Camera2D.new()
		debug_camera.name = "OfflineDebugCamera"
		debug_camera.enabled = true
		debug_camera.zoom = Vector2.ONE
		if loaded_world is Node2D:
			loaded_world.add_child(debug_camera)
		else:
			var camera_host := Node2D.new()
			camera_host.name = "OfflineDebugCameraHost"
			add_child(camera_host)
			move_child(camera_host, 0)
			camera_host.add_child(debug_camera)
		camera_status = "Camera2D criada"
		print("[AndroidBootDebug] câmera debug criada: %s" % debug_camera.get_path())
	else:
		debug_camera.enabled = true

	if is_instance_valid(debug_player):
		debug_camera.reparent(debug_player, false)
		debug_camera.position = Vector2.ZERO
		print("[AndroidBootDebug] câmera seguindo player debug")
	else:
		debug_camera.position = Vector2.ZERO


func _create_world_marker(loaded_world: Node) -> void:
	screen_marker.visible = true
	print("[AndroidBootDebug] marcador canvas criado")
	if loaded_world is Node2D:
		var marker := Node2D.new()
		marker.name = "OfflineWorldOriginMarker"
		marker.position = Vector2.ZERO
		loaded_world.add_child(marker)

		var body := Polygon2D.new()
		body.polygon = PackedVector2Array([
			Vector2(-48, -48), Vector2(48, -48),
			Vector2(48, 48), Vector2(-48, 48),
		])
		body.color = Color(1.0, 0.45, 0.05, 0.75)
		marker.add_child(body)

		var label := Label.new()
		label.position = Vector2(-105, -90)
		label.text = "ORIGEM DO MUNDO"
		label.add_theme_font_size_override("font_size", 22)
		marker.add_child(label)
		print("[AndroidBootDebug] marcador Node2D criado em %s" % marker.position)


func _create_debug_player(loaded_world: Node) -> void:
	debug_player = OFFLINE_PLAYER_SCENE.instantiate() as CharacterBody2D
	if debug_player == null:
		push_error("[AndroidBootDebug] falha ao instanciar player debug")
		return
	debug_player.position = Vector2.ZERO
	if loaded_world is Node2D:
		loaded_world.add_child(debug_player)
	else:
		add_child(debug_player)
		move_child(debug_player, 0)
	print("[AndroidBootDebug] player debug criado em %s" % debug_player.position)


func _create_mobile_controls() -> void:
	mobile_controls = MOBILE_CONTROLS_SCENE.instantiate() as CanvasLayer
	if mobile_controls == null:
		push_error("[AndroidBootDebug] falha ao instanciar controles touch")
		return
	add_child(mobile_controls)
	print("[AndroidBootDebug] overlay touch carregado")


func _show_loaded_state() -> void:
	load_in_progress = false
	background.visible = false
	boot_panel.visible = false
	debug_panel.visible = true
	debug_details.text = "\n".join([
		"DEBUG APK: world carregado",
		"Root: %s (%s)" % [world_instance.name, world_instance.get_class()],
		"Filhos diretos: %d" % world_instance.get_child_count(),
		camera_status,
		"Player/marcador: %s" % ("ativo" if is_instance_valid(debug_player) else "falhou"),
		"Touch: %s" % ("ativo" if is_instance_valid(mobile_controls) else "falhou"),
	])


func _on_hide_debug_pressed() -> void:
	debug_panel.visible = false
	screen_marker.visible = false
	print("[AndroidBootDebug] overlay debug ocultado pelo usuário")


func _show_load_error(reason: String) -> void:
	status_label.text = "Erro ao carregar world.tscn\n%s\nToque para tentar novamente." % reason
	load_button.disabled = false
	load_in_progress = false
	print("[AndroidBootDebug] erro com path %s: %s" % [WORLD_PATH, reason])


func _build_description() -> String:
	var version := Engine.get_version_info()
	return "Versão/build: MVP Offline Android (interno)\nGodot %s | %s" % [
		str(version.get("string", "desconhecida")),
		OS.get_name(),
	]
