## Interactive Story Terminal for SHADOW.exe.
## Renders a glowing holographic terminal that triggers lore logs when visited.
extends Area2D

const UI := preload("res://scripts/ui_style.gd")

@export_multiline var story_text: String = "SYSTEM LOG"
@export var terminal_label: String = "DATA ARCHIVE"

var _player_nearby: bool = false
var _read: bool = false
var _time_alive: float = 0.0
var _e_was_down: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_time_alive += delta
	queue_redraw()

	# [E] opens the archive (SPACE stays reserved for shadow deploy, as on web).
	var e_down := Input.is_physical_key_pressed(KEY_E)
	if _player_nearby and e_down and not _e_was_down:
		_display_log()
	_e_was_down = e_down


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_nearby = false


func _display_log() -> void:
	_read = true
	AudioManager.play_plate_activate()
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("show_terminal"):
		hud.show_terminal(terminal_label, story_text)
	elif hud and hud.has_method("show_message"):
		hud.show_message(story_text, 5.0)


func _draw() -> void:
	# Web style: navy console with cyan outline and a solid cyan screen.
	draw_rect(Rect2(-14, -36, 28, 36), Color("#061324"))
	draw_rect(Rect2(-14, -36, 28, 36), UI.CYAN, false, 1.5)
	draw_rect(Rect2(-10, -32, 20, 16), UI.CYAN)

	if _player_nearby:
		var font := UI.mono()
		var prompt := "[E] ACCESS ARCHIVE"
		var w := font.get_string_size(prompt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		draw_string(font, Vector2(-w / 2.0, -44.0), prompt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, UI.CYAN)
