## Base class for side-scrolling levels in SHADOW.exe.
## Handles player/shadow coordination, multi-plate tracking, Shadow Flip,
## narrative story prompts, and level progression.
extends Node2D

const WebWorld := preload("res://scripts/web_world.gd")

@export var level_phase_name: String = "LEVEL 1 - DISCOVERY"
@export var level_subtitle: String = "ECHO DETECTED. REVERSE SYNCHRONIZATION ACTIVE."
@export var level_hint: String = "Jump [W] to plate -> return below. Deploy [SPACE], then proceed."

var _player: CharacterBody2D = null
var _shadow: Node2D = null
var _exit: Node2D = null
var _hud: CanvasLayer = null
var _plates: Array[Area2D] = []

var _completed: bool = false
var _flash_timer: float = 0.0


func _ready() -> void:
	WebWorld.setup_level(self)
	_player = get_node_or_null("SidescrollPlayer") as CharacterBody2D
	_shadow = get_node_or_null("SidescrollShadow") as Node2D
	_exit = get_node_or_null("ExitZone") as Node2D
	_hud = get_node_or_null("HUD") as CanvasLayer

	# Collect all pressure plates
	for child in get_children():
		if child is Area2D and child.has_method("set_shadow_present"):
			_plates.append(child as Area2D)

	if _player:
		_player.shadow_deploy_requested.connect(_on_deploy)
		_player.shadow_flip_requested.connect(_on_flip)

	# Setup HUD
	if _hud:
		if _hud.has_method("set_level_name"):
			_hud.set_level_name(level_phase_name)
		if _hud.has_method("set_shadow_status"):
			_hud.set_shadow_status(level_hint)
		if _hud.has_method("show_message"):
			_hud.show_message(level_subtitle, 3.5)


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		queue_redraw()

	if Input.is_action_just_pressed("restart"):
		GameData.restart_level()
	if Input.is_action_just_pressed("pause"):
		GameData.go_to_title()

	# Evaluate shadow proximity to each pressure plate
	if _shadow and _shadow.visible:
		var s_pos: Vector2 = _shadow.global_position
		for plate in _plates:
			var d := s_pos.distance_to(plate.global_position)
			plate.set_shadow_present(d < 36.0)
	else:
		for plate in _plates:
			plate.set_shadow_present(false)

	# Check exit extraction
	if not _completed and _exit and _player:
		if _player.global_position.distance_to(_exit.global_position) < 55.0:
			_completed = true
			AudioManager.play_victory()
			if _hud and _hud.has_method("show_message"):
				_hud.show_message("SECTOR UNSEALED\nSYNCING ARCHIVE...", 2.0)
			get_tree().create_timer(1.8).timeout.connect(func(): GameData.next_level())


func _on_deploy() -> void:
	if _player == null or _shadow == null:
		return
	var path: Array[Vector2] = _player.get("recorded_path")
	if path.size() > 5:
		_shadow.start_replay(path, false)
		AudioManager.play_shadow_deploy()
		if _hud and _hud.has_method("set_shadow_status"):
			_hud.set_shadow_status(">> SHADOW DISPATCHED >> Running recorded route >> Press [F] to FLIP")


func _on_flip() -> void:
	if _shadow and _shadow.visible:
		_shadow.flip()
		_flash_timer = 0.25
		queue_redraw()
		if _hud and _hud.has_method("set_shadow_status"):
			if _shadow.get("is_reversed"):
				_hud.set_shadow_status("<< SHADOW FLIP: REVERSAL TRAJECTORY ENGAGED << (Press F to re-flip)")
			else:
				_hud.set_shadow_status(">> SHADOW: FORWARD TRAJECTORY >> (Press F to flip)")


func _draw() -> void:
	WebWorld.draw_level(self)
