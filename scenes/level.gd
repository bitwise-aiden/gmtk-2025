class_name Level extends Node2D

# Public signals

signal complete_or_timeout(p_levels : Array[LevelData])


# Private constants

const __SCENE_CHARACTER : PackedScene = preload("res://scenes/character/character.tscn")
const __LEVEL_DATA_URI : String = "https://raw.githubusercontent.com/bitwise-aiden/gmtk-2025/refs/heads/main/assets/level.data"


# Private variables

@onready var __parent_characters : Node2D = $parent_characters
@onready var __characters : Array[Character]

@onready var __board : Board = $board
var __targets : Array[Vector2i]

var __playing : bool
var __elapsed : float
var __move_index : int
var __winning : bool
var __home : bool
var __can_start : bool

@onready var __button_home : TextureButton = $ui/button_home
@onready var __button_play : TextureButton = $ui/controls/button_play
@onready var __button_restart : TextureButton = $ui/controls/button_restart
@onready var __buttons : Array[TextureButton] = [
	__button_home,
	__button_play,
	__button_restart,
]

@onready var __level_screen : Control = $ui/level_screen
@onready var __level_congrats : Label = $"ui/level_screen/level_congrats"
@onready var __level_data : Label = $ui/level_screen/level_data
@onready var __button_finish : TextureButton = $ui/level_screen/controls/button_finish
@onready var __button_next : TextureButton = $ui/level_screen/controls/button_next
@onready var __button_replay : TextureButton = $ui/level_screen/controls/button_replay

@onready var __menu_screen : Control = $ui/menu_screen


var __levels : Array[LevelData] = [
	LevelData.new("2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,2,2,0,0,0,1,1,1,0,0,0,2,2,0,0,0,1,6,1,0,0,0,2,2,0,0,0,1,1,1,0,7,0,2,2,0,0,0,1,1,1,0,0,0,2,2,0,0,0,1,1,1,0,0,0,2,2,0,0,0,1,7,1,0,0,0,2,2,0,0,0,1,1,1,0,0,0,2,2,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2;;1;4"),
	LevelData.new("2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,2,2,0,1,1,1,1,1,1,1,0,2,2,0,1,6,1,1,1,1,1,0,2,2,0,1,1,1,1,1,1,1,0,2,2,0,1,1,1,7,1,6,1,0,2,2,0,1,1,1,1,1,1,1,0,2,2,0,1,7,1,1,1,1,1,0,2,2,0,1,1,1,1,1,1,1,0,2,2,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2;;3;4")
]
var __current_level : int


# Lifecycle methods

func _ready() -> void:
	get_levels()
	var _ignore : Variant

	__home = true

	var tween : Tween = create_tween()

	_ignore = tween_in(tween)
	_ignore = tween.tween_callback(menu_sreen_show)

	_ignore = __button_home.pressed.connect(home)
	_ignore = __button_play.pressed.connect(func() -> void: __playing = true)
	_ignore = __button_restart.pressed.connect(func() -> void: load_level(__current_level))

	_ignore = __button_finish.pressed.connect(home)
	_ignore = __button_next.pressed.connect(load_level)
	_ignore = __button_replay.pressed.connect(func() -> void: load_level(__current_level))


func _process(
	p_delta: float,
) -> void:
	if __home && __can_start && Input.is_anything_pressed():
		__home = false
		menu_sreen_hide()
		load_level(0)

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
			__winning = true
			ui_hide()

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
			await tween_out().finished
			level_screen_show()

		__move_index += 1

		if __move_index >= Constant.LEVEL_MOVE_MAX:
			__playing = false
			ui_hide()
			await tween_out().finished
			level_screen_show()
			__winning = true


# Public methods

func home() -> void:
	level_screen_hide()
	ui_hide()
	if !__winning:
		await tween_out().finished
	var _i : int = get_tree().reload_current_scene()


func get_levels() -> void:
	var _ignore : Variant

	var requester : HTTPRequest = HTTPRequest.new()
	add_child(requester)
	print("Making request")

	_ignore = requester.request_completed.connect(
		func(
			_p_result: int,
			p_response_code: int,
			_p_headers: PackedStringArray,
			p_body: PackedByteArray
		) -> void:
			if p_response_code != 200:
				complete_or_timeout.emit(__levels)

			var levels : Array[LevelData]
			var level_strings : PackedStringArray = p_body.get_string_from_utf8().replace("\n", "").split("~")

			for level_string : String in level_strings:
				print(level_string)
				levels.append(LevelData.new(level_string))
	)

	var error : int = requester.request(__LEVEL_DATA_URI)
	if error != OK:
		print("Failed")
		return

	var tween : Tween = create_tween()
	_ignore = tween.tween_interval(0.5)
	_ignore = tween.tween_callback(
		func() -> void:
			print("timeout")
			complete_or_timeout.emit(__levels)
	)

	__levels = await complete_or_timeout
	requester.queue_free()


func load_level(
	p_level : int = __current_level + 1,
) -> void:
	__playing = false

	ui_hide()
	level_screen_hide()

	if !__winning:
		await tween_out().finished

	__winning = false

	for character : Character in __characters:
		character.queue_free()

	__characters.clear()
	__targets.clear()

	__current_level = p_level
	if __current_level >= __levels.size():
		return

	var level_data : Array[int] = __levels[__current_level].data

	for x : int in Constant.BOARD_SIZE:
		for y : int in Constant.BOARD_SIZE:
			var coord : Vector2i = Vector2i(x, y)

			var index : int = y * Constant.BOARD_SIZE + x
			var type : Space.Type = level_data[index] as Space.Type

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
	ui_show()


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


func level_screen_hide() -> void:
	__level_screen.visible = false


func level_screen_show() -> void:
	__level_screen.visible = true

	if __winning:
		var instruction_count : int = 0

		for character : Character in __characters:
			instruction_count += character.move_count()

		if __current_level + 1 < __levels.size():
			__level_congrats.text = "You did it!"
			__button_next.visible = true
		else:
			__level_congrats.text = "You did the\nwhole thing!"
			__button_finish.visible = true
			__button_next.visible = false

		__level_data.text = "instructions: %d, best %d\nmoves: %d, best %d" % [
			instruction_count,
			__levels[__current_level].best_instruction,
			__move_index + 1,
			__levels[__current_level].best_move,
		]
	else:
		__level_congrats.text = "Faaaail!"
		__level_data.text = "You reached max moves (25)\nwoomp woomp..."
		__button_next.visible = false


func menu_sreen_hide() -> void:
	__menu_screen.visible = false


func menu_sreen_show() -> void:
	__can_start = true
	__menu_screen.visible = true


func ui_hide() -> void:
	for button : TextureButton in __buttons:
		button.visible = false

func ui_show() -> void:
	for button : TextureButton in __buttons:
		button.visible = true
