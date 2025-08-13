class_name LevelData extends RefCounted


# Public variables

var board : Array[Space.Type]
var buttons : Dictionary[Vector2i, Array]
var moves : Dictionary[Vector2i, Array]
var enabled : Array[Vector2i]
var inverted : Array[Vector2i]
var best_instruction : int
var best_move : int


# Lifecycle methods

func _init(
	p_level_string : String,
) -> void:
	var parts : PackedStringArray = p_level_string.split(";")

	for cel : String in parts[0].split(","):
		board.append(int(cel) as Space.Type)

	for trigger_data : String in parts[1].split("/", false):
		var trigger_parts : PackedStringArray = trigger_data.split(":", false)

		var trigger_coord : Vector2i = __parse_coord(trigger_parts[0])

		match __get_cel_type(trigger_coord):
			Space.Type.button:
				var button_data : PackedStringArray = trigger_parts[1].split("|", false)

				var is_inverted : bool = bool(int(button_data[0]))
				if is_inverted:
					inverted.append(trigger_coord)

				button_data.remove_at(0)

				buttons[trigger_coord] = []
				for target_data : String in button_data:
					buttons[trigger_coord].append(__parse_coord(target_data))
			Space.Type.gate:
				var gate_data : PackedStringArray = trigger_parts[1].split("|", false)
				var is_enabled : bool = bool(int(gate_data[0]))
				if is_enabled:
					enabled.append(trigger_coord)

			Space.Type.character:
				var character_data : PackedStringArray = trigger_parts[1].split("|", false)

				moves[trigger_coord] = []
				for move_data : String in character_data:
					moves[trigger_coord].append(int(move_data) as Character.Move)

			_:
				pass # TODO: Should do something with unimplemented.

	best_instruction = int(parts[2])
	best_move = int(parts[3])


# Private methods

func __get_cel_type(
	p_coord : Vector2i,
) -> Space.Type:
	return board[p_coord.y * Constant.BOARD_SIZE + p_coord.x]


func __parse_coord(
	p_coord_string : String,
) -> Vector2i:
	var parts : PackedStringArray = p_coord_string.split(",")

	return Vector2i(
		int(parts[0]),
		int(parts[1]),
	)
