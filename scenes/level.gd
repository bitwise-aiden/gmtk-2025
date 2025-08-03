class_name Level extends Node2D

# Private constants

const __SCENE_CHARACTER : PackedScene = preload("res://scenes/character/character.tscn")


# Private variables

@onready var __parent_characters : Node2D = $parent_characters
@onready var __characters : Array[Character]

@onready var __board : Board = $board
var __targets : Array[Vector2i]

var __playing : bool
var __elapsed : float
var __move_index : int


# Lifecycle methods

func _ready() -> void:
	load_level(Constant.LEVEL_01)


func _process(
	p_delta: float,
) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		__playing = true

	if !__playing:
		return

	__elapsed += p_delta

	if __elapsed > Constant.LEVEL_MOVE_DURATION:
		__elapsed -= Constant.LEVEL_MOVE_DURATION

		for character : Character in __characters:
			var direction : Vector2i = character.direction(__move_index)
			var prev : Vector2i = character.coord
			var next : Vector2i = prev + direction

			if __board.can_enter(next):
				__board.exit(prev)
				__board.enter(next, character)
				character.coord = next

		var all : bool = true

		for target : Vector2i in __targets:
			all = all && __board.is_occupied(target)

		if all:
			__playing = false

			var tween : Tween = create_tween()
			var _ignore : Variant

			_ignore = tween.tween_interval(1.0)

			for target : Vector2i in __targets:
				_ignore = tween.tween_callback(func() -> void: __board.enable(target))

				var character_tween : Tween = create_tween().set_parallel()
				var character : Character = __board.get_occupied(target)

				_ignore = character_tween.tween_property(
					character,
					"scale",
					Vector2.ZERO,
					1.0
				)
				_ignore = character_tween.tween_property(
					character,
					"rotation",
					TAU * 2.0,
					1.0
				).set_ease(Tween.EASE_IN)

				_ignore = tween.tween_subtween(character_tween)

			await tween.finished
			load_level(Constant.LEVEL_02)

		__move_index += 0

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
	__targets.clear()

	for x : int in Constant.BOARD_SIZE:
		for y : int in Constant.BOARD_SIZE:
			var coord : Vector2i = Vector2i(x, y)

			var index : int = y * Constant.BOARD_SIZE + x
			var type : Space.Type = p_level[index] as Space.Type

			match type:
				Space.Type.character:
					type = Space.Type.floor

					var character : Character = __SCENE_CHARACTER.instantiate()
					__parent_characters.add_child(character)
					__characters.append(character)

					character.coord = coord
				Space.Type.trapdoor:
					__targets.append(coord)

			__board.set_space_type(coord, type)

	__move_index = 0

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
