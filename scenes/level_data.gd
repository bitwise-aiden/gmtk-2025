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

	for trigger_data : String in parts[1].split("/", false):
		var trigger_parts : PackedStringArray = trigger_data.split(":", false)

		var trigger_coord : Vector2i = __parse_coord(trigger_parts[0])
		buttons[trigger_coord] = []

		for target_data : String in trigger_parts[1].split("|", false):
			buttons[trigger_coord].append(__parse_coord(target_data))

	best_instruction = int(parts[2])
	best_move = int(parts[3])


func __parse_coord(
	p_coord_string : String,
) -> Vector2i:
	var parts : PackedStringArray = p_coord_string.split(",")

	return Vector2i(
		int(parts[0]),
		int(parts[1]),
	)
