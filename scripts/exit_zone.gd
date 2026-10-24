## Exit zone — the goal the player must reach to complete the level.
## Renders as a pulsing cyan/white diamond.
extends Node2D

## The grid cell this exit occupies.
@export var grid_pos: Vector2i = Vector2i.ZERO

## Tile size in pixels.
const TILE_SIZE: int = 64

# ── Signals ──────────────────────────────────────────────────────────────────

## Emitted when the player steps onto the exit cell.
signal player_reached_exit


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	position = Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)


func _process(_delta: float) -> void:
	# Continuously redraw so the pulse animation updates.
	queue_redraw()


# ── Public API ───────────────────────────────────────────────────────────────

## Call every time the player moves; emits signal if they've reached the exit.
func check_player(player_pos: Vector2i) -> void:
	if player_pos == grid_pos:
		player_reached_exit.emit()


# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var pulse := (sin(t * 4.0) + 1.0) / 2.0  # 0 → 1 oscillation

	# Outer glow ring — pulsing size and alpha.
	var glow_radius := 22.0 + pulse * 8.0
	var glow_alpha := 0.15 + pulse * 0.2
	draw_circle(Vector2.ZERO, glow_radius, Color(0.0, 1.0, 1.0, glow_alpha))

	# Diamond shape — size pulses gently.
	var half := 16.0 + pulse * 4.0
	var pts := PackedVector2Array([
		Vector2(0, -half),
		Vector2(half, 0),
		Vector2(0, half),
		Vector2(-half, 0),
	])

	# Colour lerps between cyan and white with the pulse.
	var col := Color(0.0, 1.0, 1.0, 1.0).lerp(Color(1.0, 1.0, 1.0, 1.0), pulse * 0.5)
	draw_colored_polygon(pts, col)

	# Tiny bright core.
	var core := half * 0.35
	var core_pts := PackedVector2Array([
		Vector2(0, -core),
		Vector2(core, 0),
		Vector2(0, core),
		Vector2(-core, 0),
	])
	draw_colored_polygon(core_pts, Color(1.0, 1.0, 1.0, 0.9))
