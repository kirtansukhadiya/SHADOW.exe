extends CanvasLayer
## HUD overlay for SHADOW.exe. Displays level info, shadow status, and messages.

@onready var level_name_label: Label = $LevelNameLabel
@onready var shadow_status_label: Label = $ShadowStatusLabel
@onready var message_label: Label = $MessageLabel
@onready var controls_hint_label: Label = $ControlsHintLabel

var _message_tween: Tween


func _ready() -> void:
	message_label.text = ""
	message_label.modulate.a = 0.0


func set_level_name(n: String) -> void:
	level_name_label.text = n


func set_shadow_status(status: String) -> void:
	shadow_status_label.text = status


func show_message(text: String, duration: float = 2.0) -> void:
	# Cancel any existing message animation
	if _message_tween and _message_tween.is_valid():
		_message_tween.kill()

	message_label.text = text
	message_label.modulate.a = 1.0

	_message_tween = create_tween()
	_message_tween.tween_interval(duration)
	_message_tween.tween_property(message_label, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
