## Exit zone — the extraction gateway to the system core.
## Features a futuristic cyber portal visual style:
## - Concentric counter-rotating segmented holographic rings
## - Octagonal digital platform with energy nodes
## - Floating vertical data stream particles
## - Emissive singularity core
## - Large interactive extraction radius
extends Node2D

## Optional grid position (used only if non-zero, e.g. for top-down).
@export var grid_pos: Vector2i = Vector2i.ZERO

## Tile size in pixels.
const TILE_SIZE: int = 64

signal player_reached_exit

var _time_alive: float = 0.0


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Only snap to grid if grid_pos was explicitly configured (for top-down)
	if grid_pos != Vector2i.ZERO:
		position = Vector2(
			grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
			grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
		)


func _process(delta: float) -> void:
	_time_alive += delta
	queue_redraw()


# ── Public API ───────────────────────────────────────────────────────────────

func check_player(player_pos: Vector2i) -> void:
	if player_pos == grid_pos:
		player_reached_exit.emit()


# ── Portal Drawing ───────────────────────────────────────────────────────────

func _draw() -> void:
	var t := _time_alive
	var pulse := (sin(t * 3.5) + 1.0) / 2.0  # 0.0 -> 1.0

	# 1. Base Octagonal Cyber Platform
	var base_r := 30.0
	var oct_pts := PackedVector2Array()
	for i in range(8):
		var ang := float(i) * (TAU / 8.0)
		oct_pts.append(Vector2(cos(ang), sin(ang)) * base_r)
	draw_colored_polygon(oct_pts, Color(0.01, 0.08, 0.16, 0.9))
	draw_polyline(oct_pts, Color(0.0, 0.85, 1.0, 0.6), 2.0)

	# 2. Side Pylons / Emitters
	draw_line(Vector2(-34, -20), Vector2(-34, 20), Color(0.0, 1.0, 0.9, 0.8), 3.0)
	draw_line(Vector2(34, -20), Vector2(34, 20), Color(0.0, 1.0, 0.9, 0.8), 3.0)
	draw_circle(Vector2(-34, -22), 3.5, Color(1, 1, 1, 1))
	draw_circle(Vector2(34, -22), 3.5, Color(1, 1, 1, 1))

	# 3. Outer Rotating Segmented Ring
	var r_outer := 25.0 + pulse * 3.0
	var rot_a := t * 1.4
	for i in range(6):
		var start_ang := rot_a + float(i) * (TAU / 6.0)
		var end_ang := start_ang + 0.65
		draw_arc(Vector2.ZERO, r_outer, start_ang, end_ang, 12, Color(0.0, 0.95, 1.0, 0.75), 2.5)

	# 4. Inner Counter-Rotating Ring
	var r_inner := 17.0
	var rot_b := -t * 2.0
	for i in range(4):
		var start_ang := rot_b + float(i) * (TAU / 4.0)
		var end_ang := start_ang + 0.85
		draw_arc(Vector2.ZERO, r_inner, start_ang, end_ang, 8, Color(0.3, 1.0, 0.85, 0.9), 2.0)

	# 5. Floating Vertical Data Stream Sparks
	for p_idx in range(6):
		var seed_val := float(p_idx) * 1.618
		var p_time := fmod(t * 1.5 + seed_val, 1.0)
		var p_x := (sin(seed_val * 4.0)) * 16.0
		var p_y := 14.0 - p_time * 28.0
		var p_alpha := sin(p_time * PI) * 0.85
		draw_rect(Rect2(p_x - 1.5, p_y - 1.5, 3.0, 3.0), Color(0.0, 1.0, 1.0, p_alpha))

	# 6. Glowing Singularity Core
	var core_r := 9.0 + pulse * 4.0
	var core_col := Color(0.0, 1.0, 0.9, 0.75).lerp(Color(1.0, 1.0, 1.0, 0.95), pulse * 0.6)
	draw_circle(Vector2.ZERO, core_r, core_col)
	draw_circle(Vector2.ZERO, core_r * 0.45, Color(1.0, 1.0, 1.0, 1.0))
