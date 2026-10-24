## Pressure plate that activates when the player or shadow stands on it.
## By default, requires continuous weight (active only while an entity stands on it).
## Can be linked to a Door node via `linked_door_path` to open/close it.
extends Node2D

## The grid cell this plate occupies.
@export var grid_pos: Vector2i = Vector2i.ZERO

## NodePath pointing to the Door this plate controls.
@export var linked_door_path: NodePath

## Optional secondary Door this plate also controls.
@export var linked_door_2_path: NodePath

## If true, stepping on this plate permanently toggles its state.
## If false (default), it only stays active while weight is applied.
@export var is_toggle: bool = false

## Tile size in pixels.
const TILE_SIZE: int = 64

## Whether the plate is currently pressed.
var is_activated: bool = false

# ── Signals ──────────────────────────────────────────────────────────────────

signal activated
signal deactivated


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	position = Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2,
	)
	queue_redraw()


# ── Public API ───────────────────────────────────────────────────────────────

## Updates pressure plate state based on who is currently on this cell.
func update_pressure(player_pos: Vector2i, shadow_active: bool, shadow_pos: Vector2i) -> void:
	var someone_on_plate: bool = (player_pos == grid_pos) or (shadow_active and shadow_pos == grid_pos)

	if is_toggle:
		if someone_on_plate and not is_activated:
			activate()
	else:
		if someone_on_plate and not is_activated:
			activate()
		elif not someone_on_plate and is_activated:
			deactivate()


## Legacy helper.
func check_activation(stepper_pos: Vector2i) -> void:
	if stepper_pos == grid_pos and not is_activated:
		activate()


## Press the plate, open the linked door, and emit the signal.
func activate() -> void:
	if is_activated:
		return
	is_activated = true
	AudioManager.play_plate_activate()
	activated.emit()
	queue_redraw()

	if linked_door_path != NodePath(""):
		var door: Node = get_node_or_null(linked_door_path)
		if door and door.has_method("open"):
			door.open()

	if linked_door_2_path != NodePath(""):
		var door2: Node = get_node_or_null(linked_door_2_path)
		if door2 and door2.has_method("open"):
			door2.open()


## Release the plate, close the linked door, and emit the signal.
func deactivate() -> void:
	if not is_activated:
		return
	is_activated = false
	AudioManager.play_plate_activate()
	deactivated.emit()
	queue_redraw()

	if linked_door_path != NodePath(""):
		var door: Node = get_node_or_null(linked_door_path)
		if door and door.has_method("close"):
			door.close()

	if linked_door_2_path != NodePath(""):
		var door2: Node = get_node_or_null(linked_door_2_path)
		if door2 and door2.has_method("close"):
			door2.close()


# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var half := TILE_SIZE / 2.0 - 6.0  # slight inset from cell edges

	if is_activated:
		# Filled glowing emerald square with bright corners
		draw_rect(
			Rect2(-half, -half, half * 2, half * 2),
			Color(0.0, 1.0, 0.45, 0.85),
			true,
		)
		draw_rect(
			Rect2(-half, -half, half * 2, half * 2),
			Color(0.8, 1.0, 0.9, 1.0),
			false,
			2.0,
		)
	else:
		# Cyan / white tech outline square with inner cross
		draw_rect(
			Rect2(-half, -half, half * 2, half * 2),
			Color(0.0, 0.9, 1.0, 0.7),
			false,
			1.5,
		)
		var inner_half := half * 0.4
		draw_line(Vector2(-inner_half, 0), Vector2(inner_half, 0), Color(0.0, 0.9, 1.0, 0.5), 1.0)
		draw_line(Vector2(0, -inner_half), Vector2(0, inner_half), Color(0.0, 0.9, 1.0, 0.5), 1.0)
