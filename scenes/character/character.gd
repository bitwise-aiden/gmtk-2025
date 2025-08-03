class_name Character extends Entity


# Public enums

enum Move { right = 0, down, left, up, none }


# Private constants

const __MOVES_MAX : int = 10
const __MOVES_VECTOR : Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.ZERO,
]

# Private static

static var id : int


# Public variables

var code : String


# Private variables

@onready var __sprite : AnimatedSprite2D = $animated_sprite

@onready var __area : Area2D = $area
var __mouse_over : bool

@onready var __speech_bubble : SpeechBubble = $speech_bubble
var __moves : Array[Move]


# Lifecycle methods

func _ready() -> void:
	var _ignore : int

	_ignore = __area.mouse_entered.connect(__mouse_interacted.bind(true))
	_ignore = __area.mouse_exited.connect(__mouse_interacted.bind(false))

	__speech_bubble.update_moves(__moves)

	var animations : Array[String] = ["a", "b"]
	__sprite.play(animations[id % 2])
	id += 1


func _process(
	_p_delta: float,
) -> void:
	if !__mouse_over:
		return

	if Input.is_action_just_pressed("right"):
		__add_move(Move.right)
	if Input.is_action_just_pressed("down"):
		__add_move(Move.down)
	if Input.is_action_just_pressed("left"):
		__add_move(Move.left)
	if Input.is_action_just_pressed("up"):
		__add_move(Move.up)
	if Input.is_action_just_pressed("noop"):
		__add_move(Move.none)
	if Input.is_action_just_pressed("undo"):
		if __moves.size() > 0:
			__moves.pop_back()
			__speech_bubble.update_moves(__moves)


# Public methods

func direction(
	move_index : int,
) -> Vector2i:
	if __moves.is_empty():
		return Vector2i.ZERO

	var move : Move = __moves[move_index % __moves.size()]

	return __MOVES_VECTOR[move]


func tween_in(
	duration : float,
	p_tween : Tween = create_tween(),
) -> Tween:
	__sprite.position.y = Constant.SPACE_OFFSCREEN_OFFSET

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


# Private methods

func __add_move(
	p_move : Move,
) -> void:
	if __moves.size() >= __MOVES_MAX:
		return

	__moves.append(p_move)
	__speech_bubble.update_moves(__moves)


func __mouse_interacted(
	p_over : bool,
) -> void:
	__mouse_over = p_over
	__speech_bubble.visible = p_over
