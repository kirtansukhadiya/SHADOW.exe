## Interactive step-by-step Tutorial Level for SHADOW.exe.
extends Node2D

@onready var player: CharacterBody2D = $SidescrollPlayer
@onready var shadow: Node2D = $SidescrollShadow
@onready var plate1: Area2D = $Plate1
@onready var plate2: Area2D = $Plate2
@onready var exit_zone: Node2D = $ExitZone
@onready var hud: CanvasLayer = $HUD

var _plates: Array[Area2D] = []
var _completed: bool = false
var _flash_timer: float = 0.0


func _ready() -> void:
	for child in get_children():
		if child is Area2D and child.has_method("set_shadow_present"):
			_plates.append(child as Area2D)

	if player:
		player.shadow_deploy_requested.connect(_on_deploy)
		player.shadow_flip_requested.connect(_on_flip)

	if hud:
		if hud.has_method("set_level_name"):
			hud.set_level_name("TUTORIAL PROTOCOL // BASICS")
		if hud.has_method("set_shadow_status"):
			hud.set_shadow_status("STEP 1: Run [A]/[D], Jump [W] over the barrier.")
		if hud.has_method("show_message"):
			hud.show_message("WELCOME TO SHADOW.exe\nSYSTEM CALIBRATION INITIATED", 3.5)


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		queue_redraw()

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("pause"):
		GameData.go_to_title()

	# Shadow plate presence
	if shadow and shadow.visible:
		var s_pos: Vector2 = shadow.global_position
		for plate in _plates:
			var d := s_pos.distance_to(plate.global_position)
			plate.set_shadow_present(d < 36.0)
	else:
		for plate in _plates:
			plate.set_shadow_present(false)

	# Checkpoint messages based on player position
	if player and hud:
		var px := player.global_position.x
		if px > 260.0 and px < 500.0:
			hud.set_shadow_status("STEP 2: Climb to Plate 1 -> return below. Press [SPACE]/[E] to deploy shadow.")
		elif px >= 560.0 and px < 700.0:
			hud.set_shadow_status("STEP 3: Inside airlock! Press [F] for SHADOW FLIP to reverse clone to Plate 2!")

	# Exit
	if not _completed and exit_zone and player:
		if player.global_position.distance_to(exit_zone.global_position) < 42.0:
			_completed = true
			AudioManager.play_victory()
			if hud and hud.has_method("show_message"):
				hud.show_message("TUTORIAL COMPLETE!\nSYNCHRONIZATION 100%", 2.5)
			get_tree().create_timer(2.5).timeout.connect(func(): GameData.go_to_title())


func _on_deploy() -> void:
	if player == null or shadow == null:
		return
	var path: Array[Vector2] = player.get("recorded_path")
	if path.size() > 5:
		shadow.start_replay(path, false)
		AudioManager.play_shadow_deploy()
		if hud and hud.has_method("set_shadow_status"):
			hud.set_shadow_status(">> SHADOW DISPATCHED >> Running Route >> Press [F] to FLIP")


func _on_flip() -> void:
	if shadow and shadow.visible:
		shadow.flip()
		_flash_timer = 0.25
		queue_redraw()
		if hud and hud.has_method("set_shadow_status"):
			if shadow.get("is_reversed"):
				hud.set_shadow_status("<< SHADOW FLIP: REVERSAL ENGAGED! Gate 2 unsealing! <<")
			else:
				hud.set_shadow_status(">> SHADOW: FORWARD PLAYBACK >>")


func _draw() -> void:
	var total_w := 960.0
	var total_h := 640.0
	draw_rect(Rect2(0, 0, total_w, total_h), Color(0.015, 0.02, 0.04, 1.0), true)

	for y in range(60, 640, 40):
		draw_line(Vector2(0, float(y)), Vector2(total_w, float(y)), Color(0.0, 0.85, 1.0, 0.04), 1.0)
	for x in range(40, 960, 40):
		draw_line(Vector2(float(x), 0), Vector2(float(x), total_h), Color(0.0, 0.85, 1.0, 0.04), 1.0)

	if _flash_timer > 0.0:
		var alpha: float = (_flash_timer / 0.25) * 0.35
		draw_rect(Rect2(0, 0, total_w, total_h), Color(1.0, 0.3, 0.8, alpha), true)
