class_name LevelDataLabel extends Label


# Private constants

const __ELAPSED_TIME : float = 0.5

# Private variables

var __elapsed : float
var __upper : bool


# Lifecycle methods

func _process(
	p_delta: float,
) -> void:
	__elapsed += p_delta

	if __elapsed > __ELAPSED_TIME:
		__elapsed -= __ELAPSED_TIME

		text = text.to_upper() if __upper else text.to_lower()
		__upper = !__upper
