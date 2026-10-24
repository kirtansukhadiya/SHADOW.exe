extends Control
## Victory screen shown after completing all levels in SHADOW.exe.

@onready var return_button: Button = $VBoxContainer/ReturnButton


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)
	return_button.grab_focus()

	# Fade-in effect
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)


func _on_return_pressed() -> void:
	GameData.go_to_title()
