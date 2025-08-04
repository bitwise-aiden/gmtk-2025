class_name LilBubz extends Sprite2D


# Private constants

const __FRAME_DURATION : float = 0.2
const __FRAME_MAX : int = 8


# Private variables

var __elapsed : float
var __frame : int


# Lifecycle methods

func _process(
	p_delta: float,
) -> void:
	__elapsed += p_delta

	if __elapsed >= __FRAME_DURATION:
		__elapsed -= __FRAME_DURATION
		__frame = (__frame + 1) % __FRAME_MAX

		(texture as AtlasTexture).region.position.x = __frame * Constant.BOARD_SCALE
