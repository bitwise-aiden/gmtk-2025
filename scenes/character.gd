class_name Character extends Node2D


# Public signals

signal selected()


# Public variables

var coord : Vector2i :
	set(p_value):
		coord = p_value
		position = p_value * 64.0

var code : String


# Private variables

@onready var __area : Area2D = $area
var __mouse_over : bool


# Lifecycle methods

func _ready() -> void:
	var _ignore : int

	_ignore = __area.mouse_entered.connect(func() -> void: __mouse_over = true)
	_ignore = __area.mouse_exited.connect(func() -> void: __mouse_over = false)


func _process(
	_p_delta : float,
) -> void:
	if __mouse_over && Input.is_action_just_pressed("click"):
		selected.emit()


# Public methods

func move_down() -> void:
	coord += Vector2i.DOWN


func move_left() -> void:
	coord += Vector2i.LEFT


func move_right() -> void:
	coord += Vector2i.RIGHT


func move_up() -> void:
	coord += Vector2i.UP


func noop() -> void:
	pass
