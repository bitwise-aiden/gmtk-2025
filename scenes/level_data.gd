class_name LevelData extends RefCounted


# Public variables

var data : Array[int]
var buttons : Dictionary[Vector2i, Array]
var best_instruction : int
var best_move : int


# Lifecycle methods

func _init(
	p_level_string : String,
) -> void:
	var parts : PackedStringArray = p_level_string.split(";")

	for cel : String in parts[0].split(","):
		data.append(int(cel))

	best_instruction = int(parts[2])
	best_move = int(parts[3])
