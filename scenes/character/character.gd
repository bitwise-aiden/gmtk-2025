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


# Pubic variables

var spiked : bool :
	set(p_value):
		spiked = p_value

		var animations : Array[String] = ["a_spiked", "b_spiked"]
		__sprite.play(animations[__id % 2])

		__sprite_back.visible = true
		__sprite_back.play(animations[__id % 2])


# Private variables

@onready var __sprite : AnimatedSprite2D = $sprite
@onready var __sprite_back : AnimatedSprite2D = $sprite/back
@onready var __shadow : Sprite2D = $shadow
@onready var __action : Sprite2D = $action

@onready var __area : Area2D = $area
var __mouse_over : bool

@onready var __speech_bubble : SpeechBubble = $speech_bubble
var __moves : Array[Move]

var __id : int


# Lifecycle methods

func _ready() -> void:
	var _ignore : int

	__action.texture = __action.texture.duplicate()

	_ignore = __area.mouse_entered.connect(__mouse_interacted.bind(true))
	_ignore = __area.mouse_exited.connect(__mouse_interacted.bind(false))

	__speech_bubble.update_moves(__moves)

	__id = id
	id += 1

	var animations : Array[String] = ["a", "b"]
	__sprite.play(animations[__id % 2])


func _process(
	_p_delta: float,
) -> void:
	__speech_bubble.visible = __mouse_over && __shadow.scale.y > 0.999

	if !__mouse_over:
		return

	if Input.is_action_just_pressed("right"):
		add_move(Move.right)
	if Input.is_action_just_pressed("down"):
		add_move(Move.down)
	if Input.is_action_just_pressed("left"):
		add_move(Move.left)
	if Input.is_action_just_pressed("up"):
		add_move(Move.up)
	if Input.is_action_just_pressed("noop"):
		add_move(Move.none)
	if Input.is_action_just_pressed("undo"):
		if __moves.size() > 0:
			__moves.pop_back()
			__speech_bubble.update_moves(__moves)


# Public methods

func add_move(
	p_move : Move,
) -> void:
	if __moves.size() >= __MOVES_MAX:
		return

	__moves.append(p_move)
	__speech_bubble.update_moves(__moves)


func direction(
	move_index : int,
) -> Vector2i:
	if __moves.is_empty() || spiked:
		return Vector2i.ZERO

	var move : Move = __moves[move_index % __moves.size()]

	return __MOVES_VECTOR[move]


func fall(
	p_tween : Tween = create_tween(),
) -> void:
	var _ignore : Tweener

	_ignore = p_tween.tween_callback(func() -> void: __shadow.visible = false)
	_ignore = p_tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		1.0
	)
	_ignore = p_tween.tween_property(
		self,
		"rotation",
		TAU * 2.0,
		1.0
	).set_ease(Tween.EASE_IN)


func move_count() -> int:
	return __moves.size()


func move_hide() -> void:
	__action.visible = false


func move_show(
	p_move_index : int,
) -> void:
	var move : Move = Move.none

	if !__moves.is_empty():
		move = __moves[p_move_index % __moves.size()]

	__action.visible = true
	(__action.texture as AtlasTexture).region.position.x = move * Constant.BOARD_SCALE

func tween_in(
	duration : float,
	p_tween : Tween = create_tween(),
) -> Tween:
	var _ignore : Tweener
	__sprite.position.y = Constant.SPACE_OFFSCREEN_OFFSET
	__shadow.scale = Vector2.ZERO

	_ignore = p_tween.tween_property(
		__sprite,
		"position:y",
		0.0,
		duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	var shadow_tween : Tween = create_tween()

	_ignore = shadow_tween.tween_interval(duration * 0.5)
	_ignore = shadow_tween.tween_property(
		__shadow,
		"scale",
		Vector2.ONE,
		duration * 0.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	_ignore = p_tween.parallel().tween_subtween(shadow_tween)

	return p_tween


func tween_out(
	duration : float,
	p_tween : Tween = create_tween(),
) -> Tween:
	var _ignore : Tweener
	__sprite.position.y = 0.0
	__shadow.scale = Vector2.ONE

	_ignore = p_tween.tween_property(
		__sprite,
		"position:y",
		Constant.SPACE_OFFSCREEN_OFFSET,
		duration
	).set_ease(Tween.EASE_OUT)
	_ignore = p_tween.parallel().tween_property(
		__shadow,
		"scale",
		Vector2.ZERO,
		duration * 0.5
	).set_ease(Tween.EASE_OUT)

	return p_tween


# Private methods

func __mouse_interacted(
	p_over : bool,
) -> void:
	__mouse_over = p_over
