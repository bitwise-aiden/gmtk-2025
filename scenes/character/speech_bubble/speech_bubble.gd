class_name SpeechBubble extends Node2D


# Private constants

const __SCENE_MOVE : PackedScene = preload("res://scenes/character/speech_bubble/move.tscn")


# Private variables

@onready var __bubble : NinePatchRect = $bubble
@onready var __moves : GridContainer = $moves


# Public methods

func update_moves(
	p_moves : Array[Character.Move],
) -> void:
	var move_children : Array = __moves.get_children()

	while move_children.size() > p_moves.size():
		var move : SpeechBubbleMove = move_children.pop_back()
		move.queue_free()

	for i : int in p_moves.size():
		if i < move_children.size():
			var move : SpeechBubbleMove = move_children[i]
			move.type = p_moves[i]
		else:
			var move : SpeechBubbleMove = __SCENE_MOVE.instantiate()
			__moves.add_child(move)

			move.type = p_moves[i]

	if p_moves.size() == 0:
		var move : SpeechBubbleMove = __SCENE_MOVE.instantiate()
		__moves.add_child(move)

		move.type = Character.Move.none

	var columns : int = clamp(p_moves.size(), 1, 5)
	var half_width : float = columns * -8.0 - (columns - 1)
	__moves.position.x = half_width

	__bubble.position.x = half_width - 16.0
	__bubble.size.x = __bubble.position.x * -2.0

	var rows : int = max(1, ceil(p_moves.size() / 5.0))

	var half_height : float = rows * -8.0 - (rows - 1)
	__moves.position.y = -44 + half_height

	__bubble.position.y = -44 + half_height - 16.0
	__bubble.size.y = half_height * -2.0 + 32.0
