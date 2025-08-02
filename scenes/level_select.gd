extends Control


# Private variables

@onready var __label_select : Label = $label_select
@onready var __label_select_origin : Vector2 = __label_select.position

@onready var __level_row_0 : HBoxContainer = $level_row_0
@onready var __level_row_0_origin : Vector2 = __level_row_0.position

@onready var __level_row_1 : HBoxContainer = $level_row_1
@onready var __level_row_1_origin : Vector2 = __level_row_1.position


# Lifecycle methods

func _ready() -> void:
	var tween : Tween = create_tween()
	var _ignore : Variant

	__label_select.position.y -= 720.0
	__level_row_0.position.x += 1280.0
	__level_row_1.position.x -= 1280.0

	_ignore = tween.tween_interval(0.2)
	_ignore = tween.tween_property(
		__label_select,
		"position:y",
		__label_select_origin.y,
		0.3,
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)
	_ignore = tween.tween_property(
		__level_row_0,
		"position:x",
		__level_row_0_origin.x,
		0.5,
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	_ignore = tween.tween_property(
		__level_row_1,
		"position:x",
		__level_row_1_origin.x,
		0.5,
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
