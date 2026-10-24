extends CanvasLayer
## Enhanced HUD controller for SHADOW.exe.
## Features dynamic status badges, cybernetic color shifts, and message toasts.

@onready var level_name_label: Label = $TopBar/LevelBadge/LevelNameLabel
@onready var status_led: ColorRect = $TopBar/LevelBadge/StatusLed
@onready var shadow_status_label: Label = $BottomCard/ShadowStatusLabel
@onready var message_overlay: Control = $MessageOverlay
@onready var message_label: Label = $MessageOverlay/MessageLabel

var _message_tween: Tween
var _led_tween: Tween


func _ready() -> void:
	message_overlay.modulate.a = 0.0
	# Pulsing green online LED
	_led_tween = create_tween().set_loops()
	_led_tween.tween_property(status_led, "color:a", 0.4, 0.8).set_trans(Tween.TRANS_SINE)
	_led_tween.tween_property(status_led, "color:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)


func set_level_name(n: String) -> void:
	level_name_label.text = n.to_upper()


func set_shadow_status(status: String) -> void:
	shadow_status_label.text = status
	# Dynamic color coding based on status
	if "REVERSAL" in status or "FLIP" in status:
		shadow_status_label.set("theme_override_colors/font_color", Color(1.0, 0.65, 0.1, 1.0))
	elif "DEPLOYED" in status:
		shadow_status_label.set("theme_override_colors/font_color", Color(1.0, 0.25, 0.7, 1.0))
	else:
		shadow_status_label.set("theme_override_colors/font_color", Color(0.0, 1.0, 0.9, 0.95))


func show_message(text: String, duration: float = 2.0) -> void:
	if _message_tween and _message_tween.is_valid():
		_message_tween.kill()

	message_label.text = text
	message_overlay.scale = Vector2(0.95, 0.95)

	_message_tween = create_tween()
	_message_tween.parallel().tween_property(message_overlay, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
	_message_tween.parallel().tween_property(message_overlay, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT)
	_message_tween.tween_interval(duration)
	_message_tween.tween_property(message_overlay, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
