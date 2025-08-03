class_name SpeechBubbleMove extends TextureRect


# Public variables

var type : Character.Move :
	set(p_value):
		type = p_value

		(texture as AtlasTexture).region.position.x = p_value * Constant.BOARD_SCALE


# Lifecycle methods

func _ready() -> void:
	texture = texture.duplicate()
