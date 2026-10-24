## Level 3: THE ORIGINAL
## Purpose: Climax and master puzzle.
## Requires routing a path across multiple security plates, passing through two
## successive sectors as the shadow moves forward, and then using SHADOW FLIP ([F])
## to retrace the shadow all the way back to the primary plate to unlock the System Core vault!
extends "res://scripts/level_base.gd"

var _has_shown_reveal: bool = false

func _ready() -> void:
	level_name = "SECTOR 03 — THE ORIGINAL"
	level_subtitle = "Cooperate with your past self to escape."
	super._ready()

	var hud: Node = _find_child_by_type("CanvasLayer")
	if hud and hud.has_method("set_level_name"):
		hud.set_level_name(level_name)
		hud.set_shadow_status("Route Plate 1 -> Plate 2. Pass Doors 1 & 2, then use SHADOW FLIP [F] for the Core Vault!")

	if hud and hud.has_method("show_message"):
		hud.show_message("FINAL SECTOR: THE ORIGINAL\nMASTER REVERSAL PROTOCOL", 3.0)


func setup_walls() -> void:
	super.setup_walls()

	# Dividing wall 1 at column 5 (Door 1 at 5, 2)
	wall_cells.append(Vector2i(5, 1))
	wall_cells.append(Vector2i(5, 3))
	wall_cells.append(Vector2i(5, 4))
	wall_cells.append(Vector2i(5, 5))
	wall_cells.append(Vector2i(5, 6))
	wall_cells.append(Vector2i(5, 7))
	wall_cells.append(Vector2i(5, 8))

	# Dividing wall 2 at column 8 (Door 2 at 8, 4)
	wall_cells.append(Vector2i(8, 1))
	wall_cells.append(Vector2i(8, 2))
	wall_cells.append(Vector2i(8, 3))
	wall_cells.append(Vector2i(8, 5))
	wall_cells.append(Vector2i(8, 6))
	wall_cells.append(Vector2i(8, 7))
	wall_cells.append(Vector2i(8, 8))

	# Dividing wall 3 at column 11 (Door 3 at 11, 2)
	wall_cells.append(Vector2i(11, 1))
	wall_cells.append(Vector2i(11, 3))
	wall_cells.append(Vector2i(11, 4))
	wall_cells.append(Vector2i(11, 5))
	wall_cells.append(Vector2i(11, 6))
	wall_cells.append(Vector2i(11, 7))
	wall_cells.append(Vector2i(11, 8))

	# Sector 1 obstacle column
	wall_cells.append(Vector2i(3, 3))
	wall_cells.append(Vector2i(3, 4))
	wall_cells.append(Vector2i(3, 5))
	wall_cells.append(Vector2i(3, 6))

	# Sector 2 corridor baffles
	wall_cells.append(Vector2i(7, 1))
	wall_cells.append(Vector2i(7, 2))
	wall_cells.append(Vector2i(6, 5))
	wall_cells.append(Vector2i(6, 6))


func _on_flip_requested() -> void:
	super._on_flip_requested()
	if not _has_shown_reveal:
		_has_shown_reveal = true
		var hud: Node = _find_child_by_type("CanvasLayer")
		if hud and hud.has_method("show_message"):
			hud.show_message("REVERSAL ACTIVE: You are cooperating\nwith your previous cycle.", 3.5)


func _find_child_by_type(type_name: String) -> Node:
	for child in get_children():
		if child.get_class() == type_name:
			return child
	return null
