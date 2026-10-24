## Player controller for SHADOW.exe.
## Handles discrete grid-based movement with smooth tweened transitions,
## records every visited cell, and renders the player as a bright cyan diamond.
extends Node2D

## The player's current cell on the grid.
@export var grid_pos: Vector2i = Vector2i.ZERO

## Tile size in pixels – must match the global grid constant.
const TILE_SIZE: int = 64

## Minimum time (seconds) between successive moves.
var move_cooldown: float = 0.15

## Every grid cell the player has visited, in order.
var recorded_positions: Array[Vector2i] = []

## True while a movement tween is in progress.
var is_moving: bool = false

## Internal cooldown accumulator.
var _cooldown_timer: float = 0.0

## Active tween reference (kept so we never stack tweens).
var _tween: Tween = null

# ── Signals ──────────────────────────────────────────────────────────────────

## Emitted every time the player finishes moving to a new cell.
signal moved(grid_pos: Vector2i)

## Emitted when the player presses the activate_shadow action,
## signalling that the path recording is done.
signal recording_complete

## Emitted when the player presses the shadow_flip action.
signal flip_requested


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	_snap_to_grid()
	recorded_positions.append(grid_pos)
	queue_redraw()


func _process(delta: float) -> void:
	if is_moving:
		return

	_cooldown_timer -= delta
	if _cooldown_timer > 0.0:
		return

	# ── Activate shadow ──
	if Input.is_action_just_pressed("activate_shadow"):
		recording_complete.emit()
		return

	# ── Shadow Flip ──
	if Input.is_action_just_pressed("shadow_flip"):
		flip_requested.emit()
		return

	# ── Movement ──
	var direction := Vector2i.ZERO
	if Input.is_action_pressed("move_up"):
		direction = Vector2i(0, -1)
	elif Input.is_action_pressed("move_down"):
		direction = Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		direction = Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		direction = Vector2i(1, 0)

	if direction == Vector2i.ZERO:
		return

	var target := grid_pos + direction

	# Ask the parent level whether the cell is blocked.
	var level: Node = get_parent()
	if level.has_method("is_wall") and level.is_wall(target):
		return
	if level.has_method("is_door_blocking") and level.is_door_blocking(target):
		return

	# Move accepted — tween to the new cell.
	grid_pos = target
	is_moving = true
	_cooldown_timer = move_cooldown

	var target_px := Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)

	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", target_px, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.finished.connect(_on_move_finished)


func _on_move_finished() -> void:
	is_moving = false
	recorded_positions.append(grid_pos)
	AudioManager.play_move()
	moved.emit(grid_pos)
	queue_redraw()


# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var half := 24.0  # diamond half-size (~48 px across)

	# Glow outline (larger, semi-transparent cyan).
	var glow_half := half + 4.0
	var glow_pts := PackedVector2Array([
		Vector2(0, -glow_half),
		Vector2(glow_half, 0),
		Vector2(0, glow_half),
		Vector2(-glow_half, 0),
	])
	draw_colored_polygon(glow_pts, Color(0.0, 1.0, 1.0, 0.25))

	# Solid cyan diamond.
	var pts := PackedVector2Array([
		Vector2(0, -half),
		Vector2(half, 0),
		Vector2(0, half),
		Vector2(-half, 0),
	])
	draw_colored_polygon(pts, Color(0.0, 1.0, 1.0, 1.0))

	# Inner bright core.
	var inner := half * 0.45
	var inner_pts := PackedVector2Array([
		Vector2(0, -inner),
		Vector2(inner, 0),
		Vector2(0, inner),
		Vector2(-inner, 0),
	])
	draw_colored_polygon(inner_pts, Color(0.7, 1.0, 1.0, 0.9))


# ── Helpers ──────────────────────────────────────────────────────────────────

## Snap position to the centre of the current grid cell.
func _snap_to_grid() -> void:
	position = Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)
