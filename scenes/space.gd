class_name Space extends Node2D


# Public variables

var coord : Vector2i :
	set(p_value):
		coord = p_value
		position = p_value * 64.0


var occupied_by : String
