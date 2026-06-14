class_name OfflineMvpAssetCatalog
extends RefCounted

const PLAYER_SPRITE := "res://asset/images/character/player_skin/player_skin_def_1.png"
const ZOMBIE_SPRITES := [
	"res://asset/images/zed/zed_normal_skin1.png",
	"res://asset/images/zed/zed_fast_skin1.png",
	"res://asset/images/zed/zed_tank_skin.png",
]
const TREE_SPRITES := [
	"res://asset/images/environment/tree_leaves_1.png",
	"res://asset/images/environment/tree_leaves_2.png",
	"res://asset/images/environment/tree_pine_1.png",
	"res://asset/images/environment/tree_pine_2.png",
]
const GROUND_TEXTURES := [
	"res://asset/images/environment/ground_tilemap.png",
	"res://asset/images/environment/ground_enviroment_tilemap.png",
]
const BUILDING_SPRITES := [
	"res://asset/images/building/b_city_house_1-sheet0.png",
	"res://asset/images/building/b_gas_station-sheet0.png",
	"res://asset/images/building/b_shed-sheet0.png",
	"res://asset/images/building/b_hospital-sheet0.png",
]
const OBJECT_SPRITES := [
	"res://asset/images/environment/car/car_regular.png",
	"res://asset/images/environment/obst_barricade-sheet0.png",
]
const LOOT_SPRITE := "res://asset/images/environment/bunker/bunker_lootbox.png"
const UI_ATTACK_BUTTON := "res://asset/images/gui/control/gui_btn_attack-sheet0.png"
const UI_INVENTORY_BUTTON := "res://asset/images/gui/control/gui_btn_inventory-sheet0.png"
const UI_JOYSTICK_BASE := "res://asset/images/gui/control/gui_dpad_field-sheet0.png"
const UI_JOYSTICK_STICK := "res://asset/images/gui/control/gui_dpad_stick-sheet0.png"


static func load_texture(path: String, label: String) -> Texture2D:
	if ResourceLoader.exists(path, "Texture2D"):
		var resource := load(path)
		if resource is Texture2D:
			return resource as Texture2D
	push_warning("[OfflineMvpAssetCatalog] fallback visual: %s (%s)" % [label, path])
	return null


static func load_first_texture(paths: Array, label: String) -> Texture2D:
	for path in paths:
		var texture := load_texture(str(path), label)
		if texture != null:
			return texture
	return null


static func apply_sheet_frame(sprite: Sprite2D, columns: int, rows: int, frame: int = 0) -> void:
	sprite.hframes = maxi(columns, 1)
	sprite.vframes = maxi(rows, 1)
	sprite.frame = clampi(frame, 0, sprite.hframes * sprite.vframes - 1)
