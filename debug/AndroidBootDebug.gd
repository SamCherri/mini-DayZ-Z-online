extends Control

const WORLD_PATH := "res://debug/OfflineMvpWorld.tscn"
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
var mobile_controls: CanvasLayer
var load_in_progress := false


func _ready() -> void:
	print("[AndroidBootDebug] boot manual iniciado; aguardando toque")
	status_label.text = "Pronto para carregar o MVP offline\nToque em Carregar mundo"
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
	status_label.text = "Carregando OfflineMvpWorld"
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

	_create_mobile_controls()
	_show_loaded_state()


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
	screen_marker.visible = false
	var summary: Dictionary = world_instance.call("get_debug_summary")
	debug_details.text = "\n".join([
		"MVP OFFLINE carregado",
		"Root: %s (%s)" % [world_instance.name, world_instance.get_class()],
		"Player ativo: %s" % ("sim" if summary.get("player_active", false) else "não"),
		"Câmera ativa: %s" % ("sim" if summary.get("camera_active", false) else "não"),
		"Touch: %s" % ("ativo" if is_instance_valid(mobile_controls) else "falhou"),
		"Objetos criados: %d" % summary.get("object_count", 0),
		"Zumbis fake criados: %d" % summary.get("zombie_count", 0),
	])


func _on_hide_debug_pressed() -> void:
	debug_panel.visible = false
	screen_marker.visible = false
	print("[AndroidBootDebug] overlay debug ocultado pelo usuário")


func _show_load_error(reason: String) -> void:
	status_label.text = "Erro ao carregar OfflineMvpWorld\n%s\nToque para tentar novamente." % reason
	load_button.disabled = false
	load_in_progress = false
	print("[AndroidBootDebug] erro com path %s: %s" % [WORLD_PATH, reason])


func _build_description() -> String:
	var version := Engine.get_version_info()
	return "Versão/build: MVP Offline Android (interno)\nGodot %s | %s" % [
		str(version.get("string", "desconhecida")),
		OS.get_name(),
	]
