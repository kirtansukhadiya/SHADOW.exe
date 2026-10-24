## Shadow entity for SHADOW.exe.
## Features a spectral glitch-ghost visual style:
## - Chromatic aberration with micro-jitter
## - Horizontal digital scanlines across the phantom shell
## - Directional reversal chevron indicators (<< or >>)
## - Temporal ripple rings and glitch fragment trail
extends Node2D

## The shadow's current cell on the grid.
@export var grid_pos: Vector2i = Vector2i.ZERO

## Tile size in pixels.
const TILE_SIZE: int = 64

## The full list of positions to replay.
var replay_positions: Array[Vector2i] = []

## Index into replay_positions for the next step.
var replay_index: int = 0

## Whether the shadow is currently replaying a path.
var is_replaying: bool = false

## Whether playback is reversed (Shadow Flip).
var is_reversed: bool = false

## Seconds between each replay step.
var replay_speed: float = 0.2

## Internal countdown until the next step.
var replay_timer: float = 0.0

## Ring buffer of the last 4 positions for trailing glow.
var _trail: Array[Vector2i] = []

## Active tween reference.
var _tween: Tween = null

## Flip flash timer for visual pulse.
var _flip_flash: float = 0.0

var _time_alive: float = 0.0
var _jitter_offset: Vector2 = Vector2.ZERO

# ── Signals ──────────────────────────────────────────────────────────────────

signal replay_finished
signal stepped_on(grid_pos: Vector2i)
signal flipped(is_reversed: bool)


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	visible = false
	_snap_to_grid()


func _process(delta: float) -> void:
	_time_alive += delta

	# Subtle random glitch jitter every few frames
	if randf() < 0.2:
		_jitter_offset = Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))
	else:
		_jitter_offset = Vector2.ZERO

	if _flip_flash > 0.0:
		_flip_flash -= delta

	queue_redraw()

	if not is_replaying:
		return

	replay_timer -= delta
	if replay_timer > 0.0:
		return

	if not is_reversed:
		# Moving forward
		if replay_index >= replay_positions.size():
			is_replaying = false
			replay_finished.emit()
			return
		_move_to(replay_positions[replay_index])
		replay_index += 1
		replay_timer = replay_speed
	else:
		# Moving backward (Shadow Flip)
		if replay_index < 0:
			is_replaying = false
			replay_finished.emit()
			return
		_move_to(replay_positions[replay_index])
		replay_index -= 1
		replay_timer = replay_speed


# ── Public API ───────────────────────────────────────────────────────────────

## Begin replaying the recorded positions forward (or backward if reversed=true).
func start_replay(positions: Array[Vector2i], start_in_reverse: bool = false) -> void:
	if positions.is_empty():
		return

	replay_positions = positions.duplicate()
	is_reversed = start_in_reverse
	_trail.clear()
	visible = true

	if not is_reversed:
		grid_pos = replay_positions[0]
		_snap_to_grid()
		replay_index = 1 if replay_positions.size() > 1 else 0
	else:
		grid_pos = replay_positions[replay_positions.size() - 1]
		_snap_to_grid()
		replay_index = replay_positions.size() - 2

	is_replaying = true
	replay_timer = 0.05
	_flip_flash = 0.35
	stepped_on.emit(grid_pos)


## Flip shadow direction on the fly (Shadow Flip).
func flip() -> void:
	if replay_positions.is_empty() and not visible:
		return

	is_reversed = !is_reversed
	_flip_flash = 0.45

	if is_replaying:
		if is_reversed:
			replay_index = clampi(replay_index - 2, -1, replay_positions.size() - 1)
		else:
			replay_index = clampi(replay_index + 2, 0, replay_positions.size())
	else:
		is_replaying = true
		if is_reversed:
			replay_index = clampi(replay_positions.size() - 2, -1, replay_positions.size() - 1)
		else:
			replay_index = clampi(1, 0, replay_positions.size())
		replay_timer = 0.05

	stepped_on.emit(grid_pos)
	flipped.emit(is_reversed)


## Reset all replay state.
func reset() -> void:
	is_replaying = false
	is_reversed = false
	replay_positions.clear()
	replay_index = 0
	replay_timer = 0.0
	_trail.clear()
	visible = false
	if _tween and _tween.is_running():
		_tween.kill()


# ── Spectral Ghost Drawing ───────────────────────────────────────────────────

func _draw() -> void:
	if not visible:
		return

	var t := _time_alive
	var is_flip := is_reversed
	var pulse := (sin(t * 6.0) + 1.0) / 2.0

	# Palette
	var main_col := Color(1.0, 0.1, 0.4, 0.85) if not is_flip else Color(1.0, 0.55, 0.05, 0.9)
	var glow_col := Color(1.0, 0.0, 0.3, 0.25) if not is_flip else Color(1.0, 0.2, 0.8, 0.4)
	var trail_col := Color(1.0, 0.2, 0.4) if not is_flip else Color(1.0, 0.6, 0.1)

	# 1. Glitch Particle / Footprint Trail
	for i in range(_trail.size()):
		var t_pos: Vector2i = _trail[i]
		var world := Vector2(
			t_pos.x * TILE_SIZE + TILE_SIZE / 2,
			t_pos.y * TILE_SIZE + TILE_SIZE / 2,
		)
		var local := world - position
		var alpha := 0.08 + 0.09 * float(i)
		var r := 9.0 + float(i) * 1.5
		draw_rect(Rect2(local - Vector2(r, r) * 0.5, Vector2(r, r)), Color(trail_col.r, trail_col.g, trail_col.b, alpha), false, 1.5)

	# 2. Expanding Temporal Ripple (When Flipped)
	if is_flip:
		var ripple_r := 18.0 + pulse * 14.0
		var ripple_alpha := (1.0 - pulse) * 0.6
		draw_arc(Vector2.ZERO, ripple_r, 0.0, TAU, 24, Color(1.0, 0.6, 0.1, ripple_alpha), 1.5)

	# 3. Chromatic Aberration Shadow Layers (Glitch Offset)
	var half := 19.0
	var offset_pts := PackedVector2Array([
		Vector2(0, -half) + _jitter_offset,
		Vector2(half, 0) + _jitter_offset,
		Vector2(0, half) + _jitter_offset,
		Vector2(-half, 0) + _jitter_offset,
	])
	# Cyan ghost chromatic split
	var split_offset := Vector2(2.0, 0) if not is_flip else Vector2(-2.5, 0)
	var split_pts := PackedVector2Array([
		offset_pts[0] + split_offset,
		offset_pts[1] + split_offset,
		offset_pts[2] + split_offset,
		offset_pts[3] + split_offset,
	])
	draw_colored_polygon(split_pts, Color(0.0, 0.8, 1.0, 0.25))

	# Main spectral body
	draw_colored_polygon(offset_pts, main_col)

	# Outer glowing aura
	var aura_half := half + 4.0 + (pulse * 2.5)
	var aura_pts := PackedVector2Array([
		Vector2(0, -aura_half),
		Vector2(aura_half, 0),
		Vector2(0, aura_half),
		Vector2(-aura_half, 0),
	])
	draw_colored_polygon(aura_pts, glow_col)

	# 4. Horizontal Digital Scanlines
	for y_step in range(-14, 15, 4):
		var y_val := float(y_step)
		var span := (half - absf(y_val)) * 0.85
		if span > 2.0:
			draw_line(
				Vector2(-span, y_val) + _jitter_offset,
				Vector2(span, y_val) + _jitter_offset,
				Color(1.0, 1.0, 1.0, 0.35),
				1.0
			)

	# 5. Core Spectral Eye / Inversion Chevron
	if is_flip:
		# Draw Reversal Chevron (<<)
		draw_line(Vector2(4, -6), Vector2(-3, 0), Color(1.0, 1.0, 0.8, 0.95), 2.5)
		draw_line(Vector2(-3, 0), Vector2(4, 6), Color(1.0, 1.0, 0.8, 0.95), 2.5)
	else:
		# Spectral Core Diamond
		var eye_half := half * 0.35
		var eye_pts := PackedVector2Array([
			Vector2(0, -eye_half) + _jitter_offset,
			Vector2(eye_half, 0) + _jitter_offset,
			Vector2(0, eye_half) + _jitter_offset,
			Vector2(-eye_half, 0) + _jitter_offset,
		])
		draw_colored_polygon(eye_pts, Color(1.0, 0.9, 0.95, 0.9))


# ── Internal ─────────────────────────────────────────────────────────────────

func _move_to(target: Vector2i) -> void:
	_trail.append(grid_pos)
	if _trail.size() > 4:
		_trail.remove_at(0)

	grid_pos = target

	var target_px := Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)

	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", target_px, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.finished.connect(func() -> void:
		stepped_on.emit(grid_pos)
		queue_redraw()
	)


func _snap_to_grid() -> void:
	position = Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)
