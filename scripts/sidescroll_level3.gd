## Level 3 — REVELATION: The Original
## The final chamber uses the shadow mechanic, but its conclusion reveals that
## the player is the future projection and the shadow is the original!
extends "res://scripts/sidescroll_level_base.gd"

var _revelation_shown: bool = false

func _ready() -> void:
	level_phase_name = "LEVEL 3 — REVELATION // THE ORIGINAL"
	level_subtitle = "IDENTITY ERROR: YOU ARE THE ECHO."
	level_hint = "Route Plate 1 -> Plate 2. Pass Doors 1 & 2, then execute SHADOW FLIP [F] for the System Core!"
	super._ready()


func _on_flip() -> void:
	super._on_flip()
	if not _revelation_shown:
		_revelation_shown = true
		if _hud and _hud.has_method("show_message"):
			_hud.show_message("REVELATION PROTOCOL:\nYOU ARE THE ECHO. THE SHADOW IS THE ORIGINAL.", 4.0)
		if _hud and _hud.has_method("set_shadow_status"):
			_hud.set_shadow_status("REVERSAL ACTIVE: Original entity retracing the past to unseal the Core!")
