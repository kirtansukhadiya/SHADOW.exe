## Exit zone — the extraction gateway to the system core.
## Features a futuristic cyber portal visual style:
## - Concentric counter-rotating segmented holographic rings
## - Octagonal digital platform with energy nodes
## - Floating vertical data stream particles
## - Emissive singularity core
## - Large interactive extraction radius
extends Node2D

const WebWorld := preload("res://scripts/web_world.gd")
const UI := preload("res://scripts/ui_style.gd")

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


# ── Portal Drawing (web build style) ────────────────────────────────────────

func _draw() -> void:
	var rot := _time_alive * 2.0
	# Outer dashed ring (cyan, rotating) and inner dashed ring (orange, counter-rotating)
	_dashed_circle(32.0, 8.0, 6.0, rot, Color(UI.CYAN, 0.7), 2.5)
	_dashed_circle(20.0, 6.0, 4.0, -rot, Color(UI.ORANGE, 0.8), 2.0)

	# Core diamond with glow
	WebWorld.draw_glow(self, Vector2.ZERO, 20.0, Color(UI.CYAN, 0.6))
	draw_rect(Rect2(-6, -6, 12, 12), UI.CYAN)

	var font := UI.orbitron(600)
	var label := "EXTRACTION PORTAL"
	var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	# Keep the label on screen when the portal sits near an edge.
	var x := clampf(-w / 2.0, 8.0 - global_position.x, 952.0 - global_position.x - w)
	draw_string(font, Vector2(x, 46.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, UI.CYAN)


func _dashed_circle(radius: float, dash: float, gap: float, offset: float, color: Color, width: float) -> void:
	var dash_ang := dash / radius
	var step := (dash + gap) / radius
	var a := 0.0
	while a < TAU - 0.001:
		draw_arc(Vector2.ZERO, radius, offset + a, offset + minf(a + dash_ang, TAU), 4, color, width)
		a += step
