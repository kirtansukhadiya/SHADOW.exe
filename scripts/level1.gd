## Level 1: THE ECHO
## Purpose: Teach the core shadow replay mechanic.
## Plate 1 is in a dead-end corridor. Door 1 blocks the only passage to the Exit.
## Because the plate requires weight, the player cannot pass Door 1 alone.
## The player must record a path to the plate, return to Door 1, and press SPACE.
extends "res://scripts/level_base.gd"

func _ready() -> void:
	level_name = "SECTOR 01 — THE ECHO"
	level_subtitle = "Your shadow repeats your steps."
	super._ready()

	var hud: Node = _find_child_by_type("CanvasLayer")
	if hud and hud.has_method("set_level_name"):
		hud.set_level_name(level_name)
		hud.set_shadow_status("Step onto the plate, return to Door 1, then press SPACE")

	if hud and hud.has_method("show_message"):
		hud.show_message("SECTOR 01: THE ECHO", 2.5)


func setup_walls() -> void:
	super.setup_walls()

	# Dividing wall at column 7 (Door 1 is at 7, 2)
	wall_cells.append(Vector2i(7, 1))
	wall_cells.append(Vector2i(7, 3))
	wall_cells.append(Vector2i(7, 4))
	wall_cells.append(Vector2i(7, 5))
	wall_cells.append(Vector2i(7, 6))
	wall_cells.append(Vector2i(7, 7))
	wall_cells.append(Vector2i(7, 8))

	# Guide corridor wall forcing player through alcove
	wall_cells.append(Vector2i(4, 3))
	wall_cells.append(Vector2i(4, 4))
	wall_cells.append(Vector2i(4, 5))
	wall_cells.append(Vector2i(4, 6))
	wall_cells.append(Vector2i(4, 7))


func _find_child_by_type(type_name: String) -> Node:
	for child in get_children():
		if child.get_class() == type_name:
			return child
	return null
