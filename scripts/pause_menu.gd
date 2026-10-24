extends CanvasLayer
## Pause menu overlay for SHADOW.exe. Handles pause/unpause and navigation.

const UI := preload("res://scripts/ui_style.gd")

var is_paused: bool = false

@onready var overlay: ColorRect = $Overlay
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_apply_web_style()
	_set_visible(false)


func _apply_web_style() -> void:
	overlay.color = Color(1 / 255.0, 4 / 255.0, 8 / 255.0, 0.88)
	var title: Label = $VBoxContainer/PausedLabel
	title.add_theme_font_override("font", UI.orbitron(900))
	title.add_theme_color_override("font_color", UI.CYAN)
	UI.glow(title, UI.CYAN, 14)
	for b: Button in [resume_button, restart_button, quit_button]:
		b.custom_minimum_size = Vector2(300, 40)
		UI.style_menu_button(b, UI.CYAN)
	UI.style_menu_button(restart_button, UI.ORANGE)
	UI.style_menu_button(quit_button, UI.TEXT_MUTED)
	# Focus styling is disabled by style_menu_button; restore keyboard focus for this menu.
	for b: Button in [resume_button, restart_button, quit_button]:
		b.focus_mode = Control.FOCUS_ALL
		var f := UI.box(Color.TRANSPARENT, Color.WHITE, 1, 0)
		f.draw_center = false
		b.add_theme_stylebox_override("focus", f)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	_set_visible(is_paused)
	if is_paused:
		resume_button.grab_focus()


func _set_visible(show: bool) -> void:
	overlay.visible = show
	vbox.visible = show


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_restart_pressed() -> void:
	_unpause()
	GameData.restart_level()


func _on_quit_pressed() -> void:
	_unpause()
	GameData.go_to_title()


func _unpause() -> void:
	is_paused = false
	get_tree().paused = false
	_set_visible(false)
