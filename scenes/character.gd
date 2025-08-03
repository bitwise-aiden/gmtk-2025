class_name Character extends Entity


# Public signals

signal selected()


# Public variables

var code : String


# Private variables

@onready var __sprite : Sprite2D = $sprite

@onready var __area : Area2D = $area
var __mouse_over : bool


# Lifecycle methods

func _ready() -> void:
	var _ignore : int

	_ignore = __area.mouse_entered.connect(func() -> void: __mouse_over = true)
	_ignore = __area.mouse_exited.connect(func() -> void: __mouse_over = false)


func _process(
	_p_delta : float,
) -> void:
	if __mouse_over && Input.is_action_just_pressed("click"):
		selected.emit()


# Public methods

func move_down() -> void:
	coord += Vector2i.DOWN


func move_left() -> void:
	coord += Vector2i.LEFT


func move_right() -> void:
	coord += Vector2i.RIGHT


func move_up() -> void:
	coord += Vector2i.UP


func noop() -> void:
	pass


func set_offscreen() -> void:
	__sprite.position.y = Constant.SPACE_OFFSCREEN_OFFSET


func tween_in(
	duration : float,
	p_tween : Tween = create_tween(),
) -> Tween:
	set_offscreen()

	var _i : Tweener = p_tween.tween_property(
		__sprite,
		"position:y",
		0.0,
		duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	return p_tween


func tween_out(
	duration : float,
	p_tween : Tween = create_tween(),
) -> Tween:
	__sprite.position.y = 0.0

	var _i : Tweener = p_tween.tween_property(
		__sprite,
		"position:y",
		Constant.SPACE_OFFSCREEN_OFFSET,
		duration
	).set_ease(Tween.EASE_OUT)

	return p_tween
