class_name Space extends Entity


# Public signals

signal spiked(p_character : Character)


# Public enums

enum Type { none = 0, floor, wall, spike, button, gate, trapdoor, character }


# Private constants

const __REGION_NONE : Vector2i = Vector2i(0, 0)
const __REGION_FLOOR_RATIOS : Array[Vector2i] = [
	Vector2i(2, 0), Vector2i(2, 0), Vector2i(2, 0), Vector2i(2, 0),
	Vector2i(1, 0),
	Vector2i(3, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
]
const __REGION_WALL : Vector2i = Vector2i(0, 0)
const __REGION_SPIKE : Array[Vector2i] = [Vector2i(4, 1), Vector2i(4, 0)]
const __REGION_BUTTON : Array[Vector2i] = [Vector2i(0, 4), Vector2i(1, 4)]
const __REGION_GATE : Array[Vector2i] = [Vector2i(2, 1), Vector2i(3, 1)]
const __REGION_TRAPDOOR : Array[Vector2i] = [Vector2i(0, 2), Vector2i(2, 4)]


# Public variables

var type : Type :
	set(p_value):
		type = p_value
		__update_texture()

# none, spike, button, gate
var occupied_by : Character :
	set(p_value):
		occupied_by = p_value
		__update_texture()

# spike, button, gate, trapdoor
var enabled : bool :
	set(p_value):
		enabled = p_value
		__update_texture()

# button
var targets : Array[Space]

var level_id : int :
	set(p_value):
		level_id = p_value
		__update_texture()


# Private variables

@onready var __sprite : Sprite2D = $sprite


# Lifecycle methods

func _ready() -> void:
	__sprite.texture = __sprite.texture.duplicate()


# Public methods

func can_enter() -> bool:
	if type == Type.none:
		return false

	if type == Type.wall:
		return false

	if occupied_by != null:
		return false

	if type == Type.gate && enabled:
		return false

	return true


func enter(
	p_character : Character,
) -> void:
	occupied_by = p_character

	if type == Type.spike && enabled:
		spiked.emit(p_character)

	if type == Type.button:
		enabled = true
		for target : Space in targets:
			target.enabled = true


func exit() -> void:
	occupied_by = null

	if type == Type.button:
		enabled = false
		for target : Space in targets:
			target.enabled = true


func tween_in(
	duration : float,
	p_tween : Tween = create_tween(),
) -> void:
	__sprite.position.y = Constant.SPACE_OFFSCREEN_OFFSET

	var _i : Tweener = p_tween.tween_property(
		__sprite,
		"position:y",
		0.0,
		duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)


func tween_out(
	duration : float,
	p_tween : Tween = create_tween(),
) -> void:
	__sprite.position.y = 0.0

	var _i : Tweener = p_tween.tween_property(
		__sprite,
		"position:y",
		Constant.SPACE_OFFSCREEN_OFFSET,
		duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)


# Private functions

func __update_texture() -> void:
	var atlas_coord : Vector2i
	match type:
		Type.floor:
			seed(hash(coord) ^ level_id)
			atlas_coord = __REGION_FLOOR_RATIOS.pick_random()
		Type.wall:
			atlas_coord = __REGION_WALL
		Type.spike:
			atlas_coord = __REGION_SPIKE[int(enabled)]
		Type.button:
			atlas_coord = __REGION_BUTTON[int(enabled && !occupied_by)]
		Type.gate:
			atlas_coord = __REGION_GATE[int(enabled)]
		Type.trapdoor:
			atlas_coord = __REGION_TRAPDOOR[int(enabled)]
		_:
			atlas_coord = __REGION_NONE

	var texture : AtlasTexture = __sprite.texture
	texture.region.position = atlas_coord * Constant.BOARD_SCALE
