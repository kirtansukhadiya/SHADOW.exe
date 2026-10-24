extends Control
## Main menu script for SHADOW.exe title screen.

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var tutorial_button: Button = $VBoxContainer/TutorialButton
@onready var topdown_button: Button = $VBoxContainer/TopDownButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	topdown_button.pressed.connect(_on_topdown_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()

	# Audio on hover
	start_button.mouse_entered.connect(func(): AudioManager.play_move())
	tutorial_button.mouse_entered.connect(func(): AudioManager.play_move())
	topdown_button.mouse_entered.connect(func(): AudioManager.play_move())
	quit_button.mouse_entered.connect(func(): AudioManager.play_move())

	# Subtle fade-in
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

	# Pulsing glow on the title label
	var pulse_tween := create_tween().set_loops()
	pulse_tween.tween_property(title_label, "theme_override_colors/font_color", Color(0.0, 0.8, 0.95, 1.0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(title_label, "theme_override_colors/font_color", Color(0.2, 1.0, 1.0, 1.0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _on_start_pressed() -> void:
	AudioManager.play_shadow_deploy()
	GameData.load_level(0)


func _on_tutorial_pressed() -> void:
	AudioManager.play_move()
	get_tree().change_scene_to_file("res://scenes/sidescroll/TutorialLevel.tscn")


func _on_topdown_pressed() -> void:
	AudioManager.play_shadow_flip()
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
