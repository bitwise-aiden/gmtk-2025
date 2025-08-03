class_name Board extends Node2D


# Private constants

const __SCENE_SPACE : PackedScene = preload("res://scenes/board/space.tscn")


# Private variables

@onready var __parent_spaces : Node = $parent_spaces
var __spaces : Dictionary[Vector2i, Space]


# Lifecycle methods

func _ready() -> void:
	var last_index : int = Constant.BOARD_SIZE - 1

	for x : int in Constant.BOARD_SIZE:
		for y : int in Constant.BOARD_SIZE:
			var coord : Vector2i = Vector2i(x, y)

			var space : Space = __SCENE_SPACE.instantiate()
			__parent_spaces.add_child(space)
			__spaces[coord] = space

			space.coord = coord

			match [coord.x, coord.y]:
				[0, _], [_, 0], [last_index, _], [_, last_index]:
					space.type = Space.Type.wall
				_:
					space.type = Space.Type.floor


# Public methods

func set_space_type(
	coord : Vector2i,
	type : Space.Type,
) -> void:
	__spaces[coord].type = type


func tween_in(
	p_tween : Tween = create_tween()
) -> Tween:
	var board_tween : Tween = create_tween().set_parallel()
	var _ignore : Variant

	for space : Space in __spaces.values():
		if space.type == Space.Type.wall:
			continue

		var space_tween : Tween = create_tween()
		_ignore = space_tween.tween_interval(randf() * 0.3)
		space.tween_in(0.5 + randf() * 0.2, space_tween)

		_ignore = board_tween.tween_subtween(space_tween)

	_ignore = p_tween.tween_subtween(board_tween)

	return p_tween


func tween_out(
	p_tween : Tween = create_tween()
) -> Tween:
	var board_tween : Tween = create_tween().set_parallel()
	var _ignore : Variant

	for space : Space in __spaces.values():
		if space.type == Space.Type.wall:
			continue

		var space_tween : Tween = create_tween()
		_ignore = space_tween.tween_interval(randf() * 0.3)
		space.tween_out(0.5 + randf() * 0.2, space_tween)

		_ignore = board_tween.tween_subtween(space_tween)

	_ignore = p_tween.tween_subtween(board_tween)

	return p_tween
