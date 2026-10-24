## Player controller for SHADOW.exe.
## Features a futuristic cybernetic security program visual style:
## - Rotating holographic shield brackets
## - Directional optic sensor facing movement
## - Pulsing digital reactor core & glowing circuit traces
## - Smooth grid-based tweening & path recording
extends Node2D

## The player's current cell on the grid.
@export var grid_pos: Vector2i = Vector2i.ZERO

## Tile size in pixels.
const TILE_SIZE: int = 64

## Minimum time (seconds) between successive moves.
var move_cooldown: float = 0.15

## Visited grid cells in order.
var recorded_positions: Array[Vector2i] = []

## True while tweening between cells.
var is_moving: bool = false

## Facing direction vector (for optic sensor aim).
var facing_dir: Vector2 = Vector2.DOWN

var _cooldown_timer: float = 0.0
var _tween: Tween = null
var _time_alive: float = 0.0

# ── Signals ──────────────────────────────────────────────────────────────────

signal moved(grid_pos: Vector2i)
signal recording_complete
signal flip_requested


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	_snap_to_grid()
	recorded_positions.append(grid_pos)
	queue_redraw()


func _process(delta: float) -> void:
	_time_alive += delta
	queue_redraw()

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

	facing_dir = Vector2(direction.x, direction.y).normalized()
	var target := grid_pos + direction

	# Check wall & door collision with parent level
	var level: Node = get_parent()
	if level.has_method("is_wall") and level.is_wall(target):
		return
	if level.has_method("is_door_blocking") and level.is_door_blocking(target):
		return

	# Accept move
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


# ── Cybernetic Drawing ───────────────────────────────────────────────────────

func _draw() -> void:
	var t := _time_alive
	var pulse := (sin(t * 5.0) + 1.0) / 2.0  # 0.0 -> 1.0
	var core_pulse := 0.85 + pulse * 0.15

	# 1. Holographic Floor Ring / Field Projection
	var field_r := 26.0 + pulse * 2.0
	draw_arc(Vector2.ZERO, field_r, 0.0, TAU, 32, Color(0.0, 0.9, 1.0, 0.15), 1.5)

	# 2. Orbiting Shield Brackets (Rotate with time)
	var orbit_ang := t * 1.8
	var bracket_r := 23.0
	for i in range(4):
		var a := orbit_ang + float(i) * (PI / 2.0)
		var p1 := Vector2(cos(a - 0.25), sin(a - 0.25)) * bracket_r
		var p2 := Vector2(cos(a + 0.25), sin(a + 0.25)) * bracket_r
		draw_line(p1, p2, Color(0.2, 0.95, 1.0, 0.75), 2.0)

	# 3. Outer Armored Cyber Diamond Chassis (Faceted polygon)
	var size := 18.0
	var hull_pts := PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0),
	])
	# Dark cyber-hull fill
	draw_colored_polygon(hull_pts, Color(0.04, 0.1, 0.2, 0.95))
	# Glowing electric cyan bevel edge
	draw_polyline(PackedVector2Array([
		Vector2(0, -size), Vector2(size, 0), Vector2(0, size), Vector2(-size, 0), Vector2(0, -size)
	]), Color(0.0, 0.95, 1.0, 0.9), 2.0)

	# 4. Circuit Traces from Hull Corners to Inner Core
	var inner_r := 8.0 * core_pulse
	var circuit_col := Color(0.1, 0.8, 1.0, 0.6)
	draw_line(Vector2(0, -size), Vector2(0, -inner_r), circuit_col, 1.5)
	draw_line(Vector2(size, 0), Vector2(inner_r, 0), circuit_col, 1.5)
	draw_line(Vector2(0, size), Vector2(0, inner_r), circuit_col, 1.5)
	draw_line(Vector2(-size, 0), Vector2(-inner_r, 0), circuit_col, 1.5)

	# 5. Glowing Digital Reactor Core
	var core_pts := PackedVector2Array([
		Vector2(0, -inner_r),
		Vector2(inner_r, 0),
		Vector2(0, inner_r),
		Vector2(-inner_r, 0),
	])
	# Glow halo
	draw_colored_polygon(core_pts, Color(0.0, 1.0, 1.0, 0.8))
	# White hyper-core center
	var hot_r := inner_r * 0.45
	var hot_pts := PackedVector2Array([
		Vector2(0, -hot_r), Vector2(hot_r, 0), Vector2(0, hot_r), Vector2(-hot_r, 0)
	])
	draw_colored_polygon(hot_pts, Color(1.0, 1.0, 1.0, 0.95))

	# 6. Directional Optic Visor (Points in facing direction)
	var visor_dist := 11.0
	var visor_pos := facing_dir * visor_dist
	var perp := Vector2(-facing_dir.y, facing_dir.x) * 4.0
	draw_line(visor_pos - perp, visor_pos + perp, Color(0.8, 1.0, 1.0, 1.0), 3.0)
	draw_circle(visor_pos, 2.5, Color(1.0, 1.0, 1.0, 1.0))


func _snap_to_grid() -> void:
	position = Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)
