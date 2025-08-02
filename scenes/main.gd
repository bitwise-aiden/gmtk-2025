class_name Main extends Node2D


# Public constants

const CHARACTER_NAMES : Array[String] = ["Pinky", "Blinky"]

const SCENE_CHARACTER : PackedScene = preload("res://scenes/character.tscn")
const SCENE_SPACE : PackedScene = preload("res://scenes/space.tscn")

const SIZE : int = 10

const TEMPLATE_MOVE_SCRIPT : String = """
extends Runner

@warning_ignore_start("unused_parameter")
func move_list(
	p_character : Character,
) -> Array[Callable]:
	return [
		%s
	]
@warning_ignore_restore("unused_parameter")
"""

# Private variables

@onready var __parent_characters : Node2D = $characters
var __characters : Dictionary[String, Character]
var __character_selected : String

@onready var __parent_spaces : Node2D = $spaces
var __spaces : Dictionary[Vector2i, Space]

@onready var __runner : Runner = $runner

@onready var __button_play : Button = $camera/ui/_/_/play
#@onready var __button_stop : Button = $camera/ui/_/_/stop
@onready var __edit_code : CodeEdit = $camera/ui/_/code
@onready var __label_name : Label = $camera/ui/_/name


# Lifecycle methods

func _ready() -> void:
	var _ignore : int

	for x : int in SIZE:
		for y : int in SIZE:
			var coord : Vector2i = Vector2i(x, y)

			var space : Space = SCENE_SPACE.instantiate()
			space.coord = coord

			__parent_spaces.add_child(space)
			__spaces[coord] = space


	for character_name : String in CHARACTER_NAMES:
		var character : Character = SCENE_CHARACTER.instantiate()

		var coord : Vector2i = __random_coord()
		while __spaces[coord].occupied_by != "":
			coord = __random_coord()

		character.coord = coord
		character.name = character_name

		__parent_characters.add_child(character)
		__characters[character_name] = character

		__spaces[coord].occupied_by = character_name

		_ignore = character.selected.connect(__character_was_selected.bind(character_name))

	_ignore = __button_play.pressed.connect(__play_was_pressed)
	_ignore = __edit_code.text_changed.connect(__code_was_changed)


# Private methods

func __character_was_selected(
	p_name : String,
) -> void:
	if p_name == __character_selected:
		return

	__character_selected = p_name

	__label_name.text = __character_selected
	__edit_code.text = __characters[__character_selected].code
	__edit_code.editable = true


func __code_was_changed() -> void:
	__characters[__character_selected].code = __edit_code.text


func __random_coord() -> Vector2i:
	return Vector2i(
		randi() % SIZE,
		randi() % SIZE,
	)


func __play_was_pressed() -> void:
	var move_set : Array[Array]

	for character_name : String in __characters:
		var character : Character = __characters[character_name]
		var character_code : String = character.code

		var formatted_code : String = ""

		for line : String in character_code.split("\n", false):
			formatted_code += "\t\tfunc() -> void: p_character.%s(),\n" % line

		var moves_script : String = TEMPLATE_MOVE_SCRIPT % formatted_code.strip_edges()

		var script : GDScript = GDScript.new()
		script.source_code = moves_script
		var _ignore : int = script.reload()

		__runner.set_script(script)
		var moves : Array[Callable] = __runner.move_list(character)

		for i : int in moves.size():
			if move_set.size() == i:
				move_set.append([])

			move_set[i].append(moves[i])

	for i : int in move_set.size():
		__edit_code.select(i, 0, i, 100)

		for move : Callable in move_set[i]:
			move.call()

		await get_tree().create_timer(0.5).timeout
