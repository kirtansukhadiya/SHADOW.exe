## Phase 2 — DOUBT: The Opposite
## The player enters a connected room with more challenging switch placement.
## Subtle system messages imply that something is wrong with their identity.
## Requires SHADOW FLIP ([F]) to reverse through the airlock!
extends "res://scripts/sidescroll_level_base.gd"

var _revealed_doubt: bool = false

func _ready() -> void:
	level_phase_name = "PHASE 2 — DOUBT // THE OPPOSITE"
	level_subtitle = "WARNING: ORIGINAL SIGNAL\nNOT FOUND."
	level_hint = "Start on Plate 2 -> climb to Plate 1 -> wait at Door 1. Deploy [SPACE], enter airlock, then FLIP [F]!"
	super._ready()


func _on_flip() -> void:
	super._on_flip()
	if not _revealed_doubt:
		_revealed_doubt = true
		if _hud and _hud.has_method("show_message"):
			_hud.show_message("QUERY: WHO IS LEADING?\nWHO IS FOLLOWING?", 3.0)
