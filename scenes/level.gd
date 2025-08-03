class_name Level extends Node2D

# Private constants

const __SCENE_CHARACTER : PackedScene = preload("res://scenes/character/character.tscn")


# Private variables

var __current_level : Array[int]

@onready var __parent_characters : Node2D = $parent_characters
@onready var __characters : Array[Character]

@onready var __board : Board = $board
var __targets : Array[Vector2i]

var __playing : bool
var __elapsed : float
var __move_index : int

@onready var __button_home : TextureButton = $ui/button_home
@onready var __button_play : TextureButton = $ui/controls/button_play
@onready var __button_stop : TextureButton = $ui/controls/button_stop
@onready var __button_restart : TextureButton = $ui/controls/button_restart



# Lifecycle methods

func _ready() -> void:
	var _ignore : Variant

	load_level(Constant.LEVEL_01)

	_ignore = __button_home.pressed.connect(func() -> void: load_level(__current_level))
	_ignore = __button_play.pressed.connect(func() -> void: __playing = true)
	_ignore = __button_stop.pressed.connect(func() -> void: __playing = false)
	_ignore = __button_restart.pressed.connect(func() -> void: load_level(__current_level))


func _process(
	p_delta: float,
) -> void:
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
			_ignore = tween.tween_callback(func() -> void: pass)

			for target : Vector2i in __targets:
				var target_tween : Tween = create_tween().set_parallel()

				_ignore = target_tween.tween_callback(func() -> void: __board.enable(target))

				var character : Character = __board.get_occupied(target)
				character.fall(target_tween)

				_ignore = tween.parallel().tween_subtween(target_tween)

			await tween.finished
			load_level(Constant.LEVEL_02)

		__move_index += 1


# Public methods

func load_level(
	p_level : Array[int],
) -> void:
	await tween_out().finished

	for character : Character in __characters:
		character.queue_free()

	__characters.clear()
	__targets.clear()

	__current_level = p_level

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
