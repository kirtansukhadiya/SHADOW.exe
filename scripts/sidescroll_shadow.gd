## Side-scrolling shadow clone for SHADOW.exe.
## Features distinct animated GIF sprite frames:
## - ghost.gif frames when moving forward
## - ghost_reverse.gif frames when in Shadow Flip (reversal)
extends Node2D

var replay_path: Array[Vector2] = []
var current_step: float = 0.0
var is_replaying: bool = false
var is_reversed: bool = false
var replay_speed: float = 30.0

var _time_alive: float = 0.0
var _jitter: Vector2 = Vector2.ZERO
var _trail: Array[Vector2] = []

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

	if randf() < 0.2:
		_jitter = Vector2(randf_range(-1.5, 1.5), randf_range(-1.0, 1.0))
	else:
		_jitter = Vector2.ZERO

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
	global_position = replay_path[idx]

	_trail.append(global_position)
	if _trail.size() > 5:
		_trail.remove_at(0)

	queue_redraw()


func start_replay(path: Array[Vector2], start_in_reverse: bool = false) -> void:
	if path.is_empty():
		return
	replay_path = path.duplicate()
	is_reversed = start_in_reverse
	visible = true
	is_replaying = true
	_trail.clear()

	if not is_reversed:
		current_step = 0.0
	else:
		current_step = float(replay_path.size() - 1)

	global_position = replay_path[int(current_step)]


func flip() -> void:
	if replay_path.is_empty():
		return
	is_reversed = !is_reversed
	is_replaying = true
	AudioManager.play_shadow_flip()
	shadow_flipped.emit(is_reversed)


func _draw() -> void:
	if not visible:
		return

	var is_flip := is_reversed
	var main_col := Color(1.0, 0.15, 0.45) if not is_flip else Color(1.0, 0.6, 0.1)

	# 1. Glitch trail
	for i in range(_trail.size()):
		var local := _trail[i] - global_position
		var alpha := 0.08 + float(i) * 0.08
		draw_rect(Rect2(local - Vector2(8, 12), Vector2(16, 24)), Color(main_col.r, main_col.g, main_col.b, alpha), false, 1.5)

	# 2. Select appropriate animated GIF frames
	var active_frames := _frames_reverse if is_flip else _frames_forward
	if not active_frames.is_empty():
		var frame_idx: int = int(_time_alive * 10.0) % active_frames.size()
		var tex: Texture2D = active_frames[frame_idx]
		if tex:
			var sz := tex.get_size()
			draw_texture(tex, -sz * 0.5 + _jitter)
	else:
		# Fallback polygon
		draw_circle(Vector2.ZERO + _jitter, 16.0, main_col)
