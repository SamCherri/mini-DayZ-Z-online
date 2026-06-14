extends Node

## Fachada lazy do ItemActionTable.
##
## Evita carregar receitas, classes e recursos de inventário durante o boot do
## servidor dedicado. No jogo normal, a implementação original é criada apenas
## quando a interface de inventário realmente solicita uma operação.

const DEDICATED_SERVER_ARGUMENT := "--dedicated-server"
const IMPLEMENTATION_PATH := "res://item/item_action_table.gd"

var _implementation: Node


func setup(inventory, show_spin_box: Callable) -> void:
	var implementation := _get_implementation()
	if implementation == null:
		return
	implementation.setup(inventory, show_spin_box)


func create_options(item) -> Array:
	var implementation := _get_implementation()
	if implementation == null:
		return []
	return implementation.create_options(item)


func create_reload_options(ammo) -> Array:
	var implementation := _get_implementation()
	if implementation == null:
		return []
	return implementation.create_reload_options(ammo)


func get_recipes(item1, item2) -> Array:
	var implementation := _get_implementation()
	if implementation == null:
		return []
	return implementation.get_recipes(item1, item2)


func create_crafting_options(instance1_id: int, instance2_id: int) -> Array:
	var implementation := _get_implementation()
	if implementation == null:
		return []
	return implementation.create_crafting_options(instance1_id, instance2_id)


func _get_implementation():
	if DEDICATED_SERVER_ARGUMENT in OS.get_cmdline_user_args():
		return null
	if is_instance_valid(_implementation):
		return _implementation

	var implementation_script = load(IMPLEMENTATION_PATH)
	if implementation_script == null:
		push_error("ItemActionTable: não foi possível carregar a implementação.")
		return null

	_implementation = implementation_script.new()
	_implementation.name = "Implementation"
	add_child(_implementation)
	return _implementation
