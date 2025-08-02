class_name Title extends Control


# Private variables

@onready var __image_title : TextureRect = $image_title
@onready var __image_title_origin : Vector2 = __image_title.position

@onready var __label_action : Label = $label_action
@onready var __label_action_origin : Vector2 = __label_action.position


# Lifecycle methods

func _ready() -> void:
	var tween : Tween = create_tween()
	var _ignore : Tweener

	__image_title.position.y -= 720.0
	__label_action.position.y += 720.0

	_ignore = tween.tween_interval(0.2)
	_ignore = tween.tween_property(
		__image_title,
		"position:y",
		__image_title_origin.y,
		0.3,
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)
	_ignore = tween.tween_property(
		__label_action,
		"position:y",
		__label_action_origin.y,
		1.0,
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)


func _input(event: InputEvent) -> void:
	if !event.is_pressed():
		return

	var tween : Tween = create_tween()
	var _ignore : Variant

	_ignore = tween.tween_interval(0.2)
	_ignore = tween.tween_property(
		__image_title,
		"position:y",
		__image_title_origin.y - 720.0,
		0.3,
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)
	_ignore = tween.tween_property(
		__label_action,
		"position:y",
		__label_action_origin.y + 720.0,
		1.0,
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

	await tween.finished

	_ignore = get_tree().change_scene_to_file("res://scenes/level_select.tscn")
