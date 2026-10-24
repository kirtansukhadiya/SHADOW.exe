## Interactive Story Terminal for SHADOW.exe.
## Renders a glowing holographic terminal that triggers lore logs when visited.
extends Area2D

@export_multiline var story_text: String = "SYSTEM LOG"
@export var terminal_label: String = "DATA ARCHIVE"

var _player_nearby: bool = false
var _read: bool = false
var _time_alive: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_time_alive += delta
	queue_redraw()

	if _player_nearby and Input.is_action_just_pressed("activate_shadow"):
		_display_log()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_nearby = true
		_display_log()


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_nearby = false


func _display_log() -> void:
	_read = true
	AudioManager.play_plate_activate()
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("show_message"):
		hud.show_message(story_text, 5.0)


func _draw() -> void:
	var t := _time_alive
	var pulse := (sin(t * 4.0) + 1.0) / 2.0

	# Pillar Base
	draw_rect(Rect2(-12, -28, 24, 28), Color(0.06, 0.12, 0.2, 0.9), true)
	draw_rect(Rect2(-12, -28, 24, 28), Color(0.0, 0.85, 1.0, 0.8), false, 1.5)

	# Holographic Floating Screen
	var scr_y := -48.0 + sin(t * 3.0) * 3.0
	draw_rect(Rect2(-18, scr_y - 12, 36, 24), Color(0.0, 0.2, 0.3, 0.65), true)
	draw_rect(Rect2(-18, scr_y - 12, 36, 24), Color(0.0, 1.0, 0.9, 0.9), false, 1.5)

	# Terminal core beacon
	draw_circle(Vector2(0, scr_y), 4.0 + pulse * 2.0, Color(0.2, 1.0, 0.9, 0.9))

	# Prompt
	if _player_nearby:
		draw_arc(Vector2(0, scr_y), 24.0, 0.0, TAU, 16, Color(1.0, 0.8, 0.2, 0.8), 2.0)
