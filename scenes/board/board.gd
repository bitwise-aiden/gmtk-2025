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

func can_enter(
	p_coord : Vector2i,
) -> bool:
	return __spaces[p_coord].can_enter()


func disable(
	p_coord : Vector2i,
) -> void:
	__spaces[p_coord].enabled = false


func enable(
	p_coord : Vector2i,
) -> void:
	__spaces[p_coord].enabled = true


func enter(
	p_coord : Vector2i,
	p_character : Character,
) -> void:
	__spaces[p_coord].enter(p_character)


func exit(
	p_coord: Vector2i,
) -> void:
	__spaces[p_coord].exit()


func get_occupied(
	p_coord : Vector2i,
) -> Character:
	return __spaces[p_coord].occupied_by


func is_occupied(
	p_coord : Vector2i,
) -> bool:
	return __spaces[p_coord].occupied_by != null


func set_space_type(
	p_coord : Vector2i,
	p_type : Space.Type,
	p_level_id : int,
) -> void:
	__spaces[p_coord].type = p_type
	__spaces[p_coord].enabled = false
	__spaces[p_coord].targets.clear()
	__spaces[p_coord].level_id = p_level_id


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
