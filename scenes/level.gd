class_name Level extends Node2D

# Private constants

const __SCENE_CHARACTER : PackedScene = preload("res://scenes/character.tscn")


# Private variables

@onready var __parent_characters : Node2D = $parent_characters
@onready var __characters : Array[Character]

@onready var __board : Board = $board


# Lifecycle methods

func _ready() -> void:
	await __board.tween_out().finished
	load_level(Constant.LEVEL_01)


# Public methods

func load_level(
	p_level : Array[int],
) -> void:
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

	__characters[0].set_offscreen()

	await __board.tween_in().finished
	await __characters[0].tween_in(0.5).finished
