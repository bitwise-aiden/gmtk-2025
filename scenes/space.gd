class_name Space extends Node2D


# Public signals

signal activated(p_coord : Vector2i)
signal deactivated(p_coord : Vector2i)
signal spiked(p_character : Character)


# Public enums

enum Type { none = 0, wall, spike, button, gate }


# Public variables

var coord : Vector2i :
	set(p_value):
		coord = p_value
		position = p_value * 64.0


var type : Type

# none, spike, button, gate
var occupied_by : Character

# spike, button, gate
var enabled : bool

# button
var target : Vector2i


# Public methods

func can_enter() -> bool:
	if type == Type.wall:
		return false

	if occupied_by != null:
		return false

	if type == Type.gate && enabled:
		return false

	return true


func enter(
	p_character : Character,
) -> void:
	occupied_by = p_character

	if type == Type.spike && enabled:
		spiked.emit(p_character)

	if type == Type.button:
		enabled = true
		activated.emit(target)


func exit() -> void:
	occupied_by = null

	if type == Type.button:
		enabled = false
		deactivated.emit(target)
