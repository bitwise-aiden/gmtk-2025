class_name Level extends Node2D

# Private constants

const __SCENE_CHARACTER : PackedScene = preload("res://scenes/character/character.tscn")
const __LEVEL_DATA_PATH : String = "res://assets/level-with-buttons.data"


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


var __levels : Array[LevelData] = []
var __current_level : int


# Lifecycle methods

func _ready() -> void:
	__levels = get_levels()
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
		load_level(4)

	if !__playing:
		return

	__elapsed += p_delta

	if __elapsed > Constant.LEVEL_MOVE_DURATION:
		__elapsed -= Constant.LEVEL_MOVE_DURATION

		for character : Character in __characters:
			character.move_show(__move_index)

		await get_tree().create_timer(0.2).timeout

		__board.activation_reset()

		for character : Character in __characters:
			var direction : Vector2i = character.direction(__move_index)
			var prev : Vector2i = character.coord
			var next : Vector2i = prev + direction

			if __board.can_enter(next):
				__board.exit(prev)
				__board.enter(next, character)
				character.coord = next

			character.move_hide()

		__board.activation_apply()

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


func get_levels() -> Array[LevelData]:
	var _ignore : Variant

	var file : FileAccess = FileAccess.open(__LEVEL_DATA_PATH, FileAccess.READ)
	var content : String = file.get_as_text()

	var levels : Array[LevelData]
	var level_strings : PackedStringArray = content.replace("\n", "").split("~")

	for level_string : String in level_strings:
		levels.append(LevelData.new(level_string))

	return levels


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

	var level_data : Array[Space.Type] = __levels[__current_level].data

	for x : int in Constant.BOARD_SIZE:
		for y : int in Constant.BOARD_SIZE:
			var coord : Vector2i = Vector2i(x, y)

			var index : int = y * Constant.BOARD_SIZE + x
			var type : Space.Type = level_data[index]

			match type:
				Space.Type.character:
					type = Space.Type.floor

					var character : Character = __SCENE_CHARACTER.instantiate()
					__parent_characters.add_child(character)
					__characters.append(character)

					character.coord = coord
				Space.Type.trapdoor:
					__targets.append(coord)

			__board.set_space_type(coord, type, __current_level)

	var buttons : Dictionary[Vector2i, Array] = __levels[__current_level].buttons
	for trigger_coord : Vector2i in buttons:
		__board.set_trigger(trigger_coord, buttons[trigger_coord])

	for inverted_coord : Vector2i in __levels[__current_level].inverted:
		__board.set_inverted(inverted_coord)

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
		__level_data.text = "You reached max 25 moves\nwoomp woomp..."
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
