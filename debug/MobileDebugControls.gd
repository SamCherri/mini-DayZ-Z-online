extends CanvasLayer

const MOVEMENT_ACTIONS := ["move_left", "move_right", "move_up", "move_down"]

@onready var joystick_area: Control = $UI/JoystickArea
@onready var joystick_knob: Control = $UI/JoystickArea/Knob
@onready var action_button: Button = $UI/ActionButton
@onready var inventory_button: Button = $UI/InventoryButton
@onready var feedback_label: Label = $UI/Feedback

var touch_index := -1
var joystick_center := Vector2.ZERO
var joystick_radius := 80.0
var last_logged_direction := Vector2.ZERO


func _ready() -> void:
	_ensure_action("interact")
	_ensure_action("toggle_inventory")
	joystick_area.gui_input.connect(_on_joystick_input)
	action_button.button_down.connect(_on_action_down)
	action_button.button_up.connect(_on_action_up)
	inventory_button.button_down.connect(_on_inventory_down)
	inventory_button.button_up.connect(_on_inventory_up)
	joystick_center = joystick_area.size * 0.5
	joystick_knob.position = joystick_center - joystick_knob.size * 0.5
	print("[MobileDebugControls] overlay touch carregado")


func _exit_tree() -> void:
	_release_movement()
	Input.action_release(_action_name())
	Input.action_release("toggle_inventory")


func _on_joystick_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_update_joystick(event.position)
			joystick_area.accept_event()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_reset_joystick()
			joystick_area.accept_event()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_joystick(event.position)
		joystick_area.accept_event()
	elif event is InputEventMouseButton:
		if event.pressed:
			touch_index = -2
			_update_joystick(event.position)
		else:
			touch_index = -1
			_reset_joystick()
	elif event is InputEventMouseMotion and touch_index == -2:
		_update_joystick(event.position)


func _update_joystick(local_position: Vector2) -> void:
	var offset := local_position - joystick_center
	var direction := offset.limit_length(joystick_radius) / joystick_radius
	joystick_knob.position = joystick_center + direction * joystick_radius - joystick_knob.size * 0.5
	_apply_direction(direction)
	if direction.distance_to(last_logged_direction) >= 0.25:
		last_logged_direction = direction
		print("[MobileDebugControls] joystick direção: %s" % direction)


func _apply_direction(direction: Vector2) -> void:
	_set_action_strength("move_left", maxf(-direction.x, 0.0))
	_set_action_strength("move_right", maxf(direction.x, 0.0))
	_set_action_strength("move_up", maxf(-direction.y, 0.0))
	_set_action_strength("move_down", maxf(direction.y, 0.0))


func _set_action_strength(action: StringName, strength: float) -> void:
	if strength > 0.12:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _reset_joystick() -> void:
	joystick_knob.position = joystick_center - joystick_knob.size * 0.5
	last_logged_direction = Vector2.ZERO
	_release_movement()


func _release_movement() -> void:
	for action in MOVEMENT_ACTIONS:
		Input.action_release(action)


func _on_action_down() -> void:
	var action := _action_name()
	Input.action_press(action)
	feedback_label.text = "Ação: %s" % action
	print("[MobileDebugControls] ação pressionada: %s" % action)


func _on_action_up() -> void:
	Input.action_release(_action_name())


func _on_inventory_down() -> void:
	Input.action_press("toggle_inventory")
	feedback_label.text = "Inventário pressionado"
	print("[MobileDebugControls] inventário pressionado")


func _on_inventory_up() -> void:
	Input.action_release("toggle_inventory")


func _action_name() -> StringName:
	return &"attack" if InputMap.has_action("attack") else &"interact"


func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
