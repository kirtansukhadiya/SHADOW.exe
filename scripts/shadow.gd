## Shadow entity for SHADOW.exe.
## Replays the player's recorded path either forward or in reverse (Shadow Flip).
## Stays on its destination tile to hold pressure plates until flipped or reset.
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

## Ring buffer of the last 3 positions (used for trailing glow).
var _trail: Array[Vector2i] = []

## Active tween reference.
var _tween: Tween = null

## Flip flash timer for visual pulse.
var _flip_flash: float = 0.0

# ── Signals ──────────────────────────────────────────────────────────────────

signal replay_finished
signal stepped_on(grid_pos: Vector2i)
signal flipped(is_reversed: bool)


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	visible = false
	_snap_to_grid()


func _process(delta: float) -> void:
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
	_flip_flash = 0.3
	stepped_on.emit(grid_pos)
	queue_redraw()


## Flip shadow direction on the fly (Shadow Flip).
## If moving forward, it starts moving backward. If stopped, it retraces.
func flip() -> void:
	if replay_positions.is_empty() and not visible:
		return

	is_reversed = !is_reversed
	_flip_flash = 0.4

	if is_replaying:
		# Re-target index in reverse direction
		if is_reversed:
			replay_index = clampi(replay_index - 2, -1, replay_positions.size() - 1)
		else:
			replay_index = clampi(replay_index + 2, 0, replay_positions.size())
	else:
		# Was idle/stopped; resume in new direction
		is_replaying = true
		if is_reversed:
			replay_index = clampi(replay_positions.size() - 2, -1, replay_positions.size() - 1)
		else:
			replay_index = clampi(1, 0, replay_positions.size())
		replay_timer = 0.05

	stepped_on.emit(grid_pos)
	flipped.emit(is_reversed)
	queue_redraw()


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
	queue_redraw()


# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	if not visible:
		return

	var is_flip := is_reversed
	# Normal: Neon Red/Magenta. Flip: Electric Violet/Amber.
	var base_col := Color(1.0, 0.15, 0.5, 0.8) if not is_flip else Color(1.0, 0.55, 0.0, 0.9)
	var glow_col := Color(1.0, 0.0, 0.4, 0.35) if not is_flip else Color(1.0, 0.3, 0.8, 0.5)

	if _flip_flash > 0.0:
		glow_col = Color(1.0, 1.0, 1.0, 0.7)

	# ── Trail ──
	for i in range(_trail.size()):
		var t_pos: Vector2i = _trail[i]
		var world := Vector2(
			t_pos.x * TILE_SIZE + TILE_SIZE / 2,
			t_pos.y * TILE_SIZE + TILE_SIZE / 2,
		)
		var local := world - position
		var alpha := 0.15 + 0.12 * float(i)
		var trail_col := Color(1.0, 0.2, 0.4, alpha) if not is_flip else Color(1.0, 0.6, 0.1, alpha)
		draw_circle(local, 12.0, trail_col)

	# ── Diamond body ──
	var half := 20.0
	var glow_half := half + (6.0 if _flip_flash > 0.0 else 3.5)

	var glow_pts := PackedVector2Array([
		Vector2(0, -glow_half),
		Vector2(glow_half, 0),
		Vector2(0, glow_half),
		Vector2(-glow_half, 0),
	])
	draw_colored_polygon(glow_pts, glow_col)

	var pts := PackedVector2Array([
		Vector2(0, -half),
		Vector2(half, 0),
		Vector2(0, half),
		Vector2(-half, 0),
	])
	draw_colored_polygon(pts, base_col)

	# Inner core
	var inner := half * 0.4
	var inner_pts := PackedVector2Array([
		Vector2(0, -inner),
		Vector2(inner, 0),
		Vector2(0, inner),
		Vector2(-inner, 0),
	])
	var inner_col := Color(1.0, 0.8, 0.9, 0.9) if not is_flip else Color(1.0, 0.95, 0.7, 0.95)
	draw_colored_polygon(inner_pts, inner_col)


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
