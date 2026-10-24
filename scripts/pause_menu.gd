extends CanvasLayer
## Pause menu overlay for SHADOW.exe. Handles pause/unpause and navigation.

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
	_set_visible(false)


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
