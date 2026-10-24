## Phase 1 — DISCOVERY: The Echo
## The player awakens in a digital chamber.
## Stepping onto the start plate, leaping across the void platforms to Plate 1,
## deploying the shadow to open Door 1, and executing SHADOW FLIP ([F]) to reverse
## the clone to Plate 2 to open Door 2!
extends "res://scripts/sidescroll_level_base.gd"

var _revealed_reversal: bool = false

func _ready() -> void:
	level_phase_name = "PHASE 1 — DISCOVERY // THE ECHO"
	level_subtitle = "ECHO DETECTED. REVERSE\nSYNCHRONIZATION ACTIVE."
	level_hint = "Step on Plate 2 -> jump to Plate 1. Deploy [SPACE] for Door 1, then enter airlock & FLIP [F] for Door 2!"
	super._ready()


func _on_flip() -> void:
	super._on_flip()
	if not _revealed_reversal:
		_revealed_reversal = true
		if _hud and _hud.has_method("show_message"):
			_hud.show_message("REVERSAL SYNCHRONIZED:\nSHADOW RETRACING PATH TO PLATE 2!", 3.0)
