class_name Entity extends Node2D


# Public variables

var coord : Vector2i :
	set(p_value):
		coord = p_value
		position = (p_value + Vector2i.ONE * Constant.BOARD_OFFSET) * Constant.BOARD_SCALE
