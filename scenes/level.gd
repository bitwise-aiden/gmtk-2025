class_name Level extends Node2D

# Private constants

const __SCENE_CHARACTER : PackedScene = preload("res://scenes/character/character.tscn")


# Private variables

@onready var __parent_characters : Node2D = $parent_characters
@onready var __characters : Array[Character]

@onready var __board : Board = $board


# Lifecycle methods

func _ready() -> void:
	load_level(Constant.LEVEL_01)

#
#var elapsed : float
#func _process(
	#p_delta: float,
#) -> void:
	#elapsed += p_delta
#
	#if elapsed > 0.5:
		#for space : Space in __board.__spaces.values():
			#if space.type != Space.Type.floor:
				#space.enabled = !space.enabled
		#elapsed = 0.0
#
	#if Input.is_action_just_pressed("click"):
		#load_level(Constant.LEVEL_01)


# Public methods

func load_level(
	p_level : Array[int],
) -> void:
	await tween_out().finished

	for character : Character in __characters:
		character.queue_free()
	__characters.clear()

	for x : int in Constant.BOARD_SIZE:
		for y : int in Constant.BOARD_SIZE:
			var coord : Vector2i = Vector2i(x, y)

			var index : int = y * Constant.BOARD_SIZE + x
			var type : Space.Type = p_level[index] as Space.Type

			if type == Space.Type.character:
				type = Space.Type.floor

				var character : Character = __SCENE_CHARACTER.instantiate()
				__parent_characters.add_child(character)
				__characters.append(character)

				character.coord = coord

			__board.set_space_type(coord, type)

	await tween_in().finished


func tween_in(
	p_tween : Tween = create_tween(),
) -> Tween:
	var level_tween : Tween = create_tween()
	var _ignore : Variant

	_ignore = __board.tween_in(level_tween)
	for character : Character in __characters:
		_ignore = character.tween_in(0.5, level_tween)

	_ignore = p_tween.tween_subtween(level_tween)

	return p_tween


func tween_out(
	p_tween : Tween = create_tween(),
) -> Tween:
	var level_tween : Tween = create_tween()
	var _ignore : Variant

	for character : Character in __characters:
		_ignore = character.tween_out(0.2, level_tween)
	_ignore = __board.tween_out(level_tween)

	_ignore = p_tween.tween_subtween(level_tween)

	return p_tween
