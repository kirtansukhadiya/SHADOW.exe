## Master controller for the Side-Scroll Protocol demo in SHADOW.exe.
extends Node2D

@onready var player: CharacterBody2D = $SidescrollPlayer
@onready var shadow: Node2D = $SidescrollShadow
@onready var plate1: Area2D = $Plate1
@onready var plate2: Area2D = $Plate2
@onready var exit_zone: Node2D = $ExitZone
@onready var hud: CanvasLayer = $HUD

var _shadow_on_plate1: bool = false
var _shadow_on_plate2: bool = false
var _completed: bool = false


func _ready() -> void:
	if hud and hud.has_method("set_level_name"):
		hud.set_level_name("DEMO: SIDE-SCROLL PROTOCOL")
		hud.set_shadow_status("Jump up [W] to Plate 1 -> return below. Deploy [SPACE], pass Door 1, FLIP [F] for Door 2!")
	if hud and hud.has_method("show_message"):
		hud.show_message("SIDE-SCROLL PROTOCOL\n[A][D] RUN  [W] JUMP  [SPACE] SHADOW  [F] FLIP", 4.0)

	player.shadow_deploy_requested.connect(_on_deploy)
	player.shadow_flip_requested.connect(_on_flip)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("pause"):
		GameData.go_to_title()

	# Check shadow overlap with plates
	if shadow and shadow.visible:
		var s_pos: Vector2 = shadow.global_position
		# Plate 1 check
		var p1_dist := s_pos.distance_to(plate1.global_position)
		var p1_active := (p1_dist < 32.0)
		if p1_active != _shadow_on_plate1:
			_shadow_on_plate1 = p1_active
			plate1.set_shadow_present(_shadow_on_plate1)

		# Plate 2 check
		var p2_dist := s_pos.distance_to(plate2.global_position)
		var p2_active := (p2_dist < 32.0)
		if p2_active != _shadow_on_plate2:
			_shadow_on_plate2 = p2_active
			plate2.set_shadow_present(_shadow_on_plate2)

	# Check exit
	if not _completed and exit_zone and player:
		if player.global_position.distance_to(exit_zone.global_position) < 40.0:
			_completed = true
			AudioManager.play_victory()
			if hud and hud.has_method("show_message"):
				hud.show_message("EXTRACTION COMPLETE!\nReturning to Title...", 3.0)
			get_tree().create_timer(3.0).timeout.connect(func(): GameData.go_to_title())


func _on_deploy() -> void:
	if player.recorded_path.size() > 5:
		shadow.start_replay(player.recorded_path)
		AudioManager.play_shadow_deploy()
		if hud and hud.has_method("set_shadow_status"):
			hud.set_shadow_status("SHADOW CLONE ACTIVE >> Running Route >> Press [F] for REVERSAL")


func _on_flip() -> void:
	if shadow.visible:
		shadow.flip()
		if hud and hud.has_method("set_shadow_status"):
			if shadow.is_reversed:
				hud.set_shadow_status("<< SHADOW FLIP: REVERSAL TRAJECTORY <<")
			else:
				hud.set_shadow_status(">> SHADOW: FORWARD TRAJECTORY >>")


func _draw() -> void:
	# Sci-fi digital backdrop grid
	var total_w := 960.0
	var total_h := 640.0
	draw_rect(Rect2(0, 0, total_w, total_h), Color(0.015, 0.02, 0.04, 1.0), true)

	# Subtle neon horizontal perspective grid lines
	for y in range(80, 640, 40):
		draw_line(Vector2(0, float(y)), Vector2(total_w, float(y)), Color(0.0, 0.8, 1.0, 0.05), 1.0)
	for x in range(40, 960, 40):
		draw_line(Vector2(float(x), 0), Vector2(float(x), total_h), Color(0.0, 0.8, 1.0, 0.05), 1.0)
