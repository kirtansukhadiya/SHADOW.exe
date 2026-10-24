## Door that blocks grid movement when closed.
## Controlled by pressure plates or other game logic.
extends Node2D

## The grid cell this door occupies.
@export var grid_pos: Vector2i = Vector2i.ZERO

## Whether the door is currently open (passable).
var is_open: bool = false

## Tile size in pixels.
const TILE_SIZE: int = 64

# ── Signals ──────────────────────────────────────────────────────────────────

signal opened
signal closed


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	position = Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)
	queue_redraw()


# ── Public API ───────────────────────────────────────────────────────────────

## Open the door so entities can pass through.
func open() -> void:
	if not is_open:
		is_open = true
		opened.emit()
		AudioManager.play_door_open()
		queue_redraw()


## Close the door, making it impassable again.
func close() -> void:
	if is_open:
		is_open = false
		closed.emit()
		queue_redraw()


# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var half := TILE_SIZE / 2.0 - 2.0

	if is_open:
		# Thin cyan/green outline — passable.
		draw_rect(
			Rect2(-half, -half, half * 2, half * 2),
			Color(0.0, 1.0, 0.6, 0.35),
			false,
			1.5,
		)
	else:
		# Solid red block — impassable.
		draw_rect(
			Rect2(-half, -half, half * 2, half * 2),
			Color(0.9, 0.1, 0.15, 0.85),
			true,
		)
		# Bright red outline for extra visibility.
		draw_rect(
			Rect2(-half, -half, half * 2, half * 2),
			Color(1.0, 0.3, 0.3, 1.0),
			false,
			2.0,
		)
