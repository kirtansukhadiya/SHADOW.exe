## Level 2: OPPOSITE
## Purpose: Teach and require SHADOW FLIP (Reversal).
## An airlock chamber separates the start area from the exit.
## Door 1 is opened by Plate 1 (far end of path).
## Door 2 is opened by Plate 2 (beginning of path).
## The player must enter the airlock, then trigger SHADOW FLIP ([F])
## so the shadow walks in reverse back to Plate 2, opening Door 2!
extends "res://scripts/level_base.gd"

func _ready() -> void:
	level_name = "SECTOR 02 — OPPOSITE"
	level_subtitle = "Reversal is the only way through."
	super._ready()

	var hud: Node = _find_child_by_type("CanvasLayer")
	if hud and hud.has_method("set_level_name"):
		hud.set_level_name(level_name)
		hud.set_shadow_status("Walk from Plate 2 -> Plate 1 -> Door 1. Deploy [SPACE], enter airlock, then FLIP [F]!")

	if hud and hud.has_method("show_message"):
		hud.show_message("SECTOR 02: OPPOSITE\n[F] KEY = SHADOW FLIP", 3.0)


func setup_walls() -> void:
	super.setup_walls()

	# Left airlock wall (column 6, Door 1 is at 6, 4)
	wall_cells.append(Vector2i(6, 1))
	wall_cells.append(Vector2i(6, 2))
	wall_cells.append(Vector2i(6, 3))
	wall_cells.append(Vector2i(6, 5))
	wall_cells.append(Vector2i(6, 6))
	wall_cells.append(Vector2i(6, 7))
	wall_cells.append(Vector2i(6, 8))

	# Airlock column 7 ceiling and floor (airlock cell is strictly 7, 4)
	wall_cells.append(Vector2i(7, 1))
	wall_cells.append(Vector2i(7, 2))
	wall_cells.append(Vector2i(7, 3))
	wall_cells.append(Vector2i(7, 5))
	wall_cells.append(Vector2i(7, 6))
	wall_cells.append(Vector2i(7, 7))
	wall_cells.append(Vector2i(7, 8))

	# Right airlock wall (column 8, Door 2 is at 8, 4)
	wall_cells.append(Vector2i(8, 1))
	wall_cells.append(Vector2i(8, 2))
	wall_cells.append(Vector2i(8, 3))
	wall_cells.append(Vector2i(8, 5))
	wall_cells.append(Vector2i(8, 6))
	wall_cells.append(Vector2i(8, 7))
	wall_cells.append(Vector2i(8, 8))

	# Interior obstacle wall in Room 1
	wall_cells.append(Vector2i(3, 3))
	wall_cells.append(Vector2i(3, 4))
	wall_cells.append(Vector2i(3, 5))
	wall_cells.append(Vector2i(3, 6))


func _find_child_by_type(type_name: String) -> Node:
	for child in get_children():
		if child.get_class() == type_name:
			return child
	return null
