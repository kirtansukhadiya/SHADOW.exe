## Side-scrolling shadow clone for SHADOW.exe.
## Features distinct animated GIF sprite frames:
## - ghost.gif frames when moving forward
## - ghost_reverse.gif frames when in Shadow Flip (reversal)
extends Node2D

const WebWorld := preload("res://scripts/web_world.gd")
const UI := preload("res://scripts/ui_style.gd")

var replay_path: Array[Vector2] = []
var current_step: float = 0.0
var is_replaying: bool = false
var is_reversed: bool = false
var replay_speed: float = 30.0

var _time_alive: float = 0.0
var _facing: float = 1.0
var _moving: bool = false

var _frames_forward: Array[Texture2D] = []
var _frames_reverse: Array[Texture2D] = []

signal shadow_flipped(is_reversed: bool)


func _ready() -> void:
	visible = false
	# Load forward ghost frames
	for i in range(8):
		var tex: Texture2D = load("res://assets/art/ghost_%d.png" % i)
		if tex:
			_frames_forward.append(tex)

	# Load reverse ghost frames
	for i in range(8):
		var tex_rev: Texture2D = load("res://assets/art/ghost_reverse_%d.png" % i)
		if tex_rev:
			_frames_reverse.append(tex_rev)


func _process(delta: float) -> void:
	_time_alive += delta

	# Trail particles drifting off the clone (web updateShadow).
	if visible and randf() < 0.4:
		var fx := get_tree().get_first_node_in_group("web_fx")
		if fx:
			fx.add(global_position + Vector2(randf_range(-5, 5), randf_range(-8, 8)),
				Vector2(-_facing * 10.0, -15.0), _color(), 2.5, 0.4)

	if not is_replaying or replay_path.is_empty():
		queue_redraw()
		return

	if not is_reversed:
		current_step += replay_speed * delta
		if current_step >= float(replay_path.size() - 1):
			current_step = float(replay_path.size() - 1)
			is_replaying = false
	else:
		current_step -= replay_speed * delta
		if current_step <= 0.0:
			current_step = 0.0
			is_replaying = false

	var idx: int = clampi(int(current_step), 0, replay_path.size() - 1)
	var prev := global_position
	global_position = replay_path[idx]
	var dx := global_position.x - prev.x
	_moving = absf(dx) > 0.1
	if _moving:
		_facing = signf(dx)

	queue_redraw()


func start_replay(path: Array[Vector2], start_in_reverse: bool = false) -> void:
	if path.is_empty():
		return
	replay_path = path.duplicate()
	is_reversed = start_in_reverse
	visible = true
	is_replaying = true

	if not is_reversed:
		current_step = 0.0
	else:
		current_step = float(replay_path.size() - 1)

	global_position = replay_path[int(current_step)]

	# Deployment shockwave (web: 20 radial orange particles).
	var fx := get_tree().get_first_node_in_group("web_fx")
	if fx:
		fx.burst(replay_path[0], UI.ORANGE, 20, 80.0, 140.0, 3.0, 0.5, true)


func flip() -> void:
	if replay_path.is_empty():
		return
	is_reversed = !is_reversed
	is_replaying = true
	AudioManager.play_shadow_flip()
	var fx := get_tree().get_first_node_in_group("web_fx")
	if fx:
		fx.burst(global_position, _color(), 30, 90.0, 180.0, 4.0, 0.6)
		fx.shake(6.0)
	shadow_flipped.emit(is_reversed)


func _color() -> Color:
	return UI.VIOLET if is_reversed else UI.ORANGE


func _draw() -> void:
	if not visible:
		return
	var col := _color()
	WebWorld.draw_glow(self, Vector2.ZERO, 22.0, Color(col, 0.4))

	var row := 2.0 if is_reversed else 1.0
	var frame_idx: int = int(_time_alive * 10.0) % 8 if _moving else 0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(signf(_facing) if _facing != 0.0 else 1.0, 1.0))
	var src := Rect2(frame_idx * 32.0, row * 32.0, 32.0, 32.0)
	draw_texture_rect_region(preload("res://assets/art/spritesheet.png"), Rect2(-16, -16, 32, 32), src)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Name tag
	var tag := "<< REVERSED SHADOW" if is_reversed else "ECHO SHADOW >>"
	var font := UI.mono()
	var w := font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
	draw_string(font, Vector2(-w / 2.0, -24.0), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, col)
