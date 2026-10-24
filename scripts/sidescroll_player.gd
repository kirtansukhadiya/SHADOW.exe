## Side-scrolling cybernetic player controller for SHADOW.exe.
## Features separate keys for jump vs deploy:
## - [W] / [Up Arrow]: Jump
## - [SPACE]: Deploy Shadow Clone
## - [F] / [Q]: Shadow Flip
## Renders animated cyber-avatar sprite frames (from player.gif).
extends CharacterBody2D

const WebWorld := preload("res://scripts/web_world.gd")
const UI := preload("res://scripts/ui_style.gd")

const SPEED: float = 240.0
const JUMP_VELOCITY: float = -480.0
const GRAVITY: float = 900.0

var recorded_path: Array[Vector2] = []
var sample_timer: float = 0.0
const SAMPLE_RATE: float = 0.033

var facing: float = 1.0
var _time_alive: float = 0.0
var _anim_timer: float = 0.0
var _is_dying: bool = false

# Preloaded animated GIF frame sequence
var _anim_frames: Array[Texture2D] = []

signal shadow_deploy_requested
signal shadow_flip_requested


func _ready() -> void:
	recorded_path.clear()
	recorded_path.append(global_position)

	# Load the 8 animated sprite frames
	for i in range(8):
		var tex: Texture2D = load("res://assets/art/player_%d.png" % i)
		if tex:
			_anim_frames.append(tex)


func _physics_process(delta: float) -> void:
	_time_alive += delta

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# 1. JUMP — strictly W or Up Arrow (NEVER Space bar!)
	if is_on_floor() and Input.is_action_just_pressed("move_up"):
		velocity.y = JUMP_VELOCITY
		AudioManager.play_move()

	# 2. DEPLOY SHADOW — Space Bar or E key
	if Input.is_action_just_pressed("activate_shadow"):
		shadow_deploy_requested.emit()

	# 3. SHADOW FLIP — F key or Q key
	if Input.is_action_just_pressed("shadow_flip"):
		shadow_flip_requested.emit()

	# Movement
	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir -= 1.0
	if Input.is_action_pressed("move_right"):
		dir += 1.0

	if dir != 0.0:
		velocity.x = dir * SPEED
		facing = dir
		_anim_timer += delta * 10.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)

	move_and_slide()

	# Fall death check — falling into chasms/pits restarts the level immediately
	if global_position.y > 610.0 and not _is_dying:
		_die()
		return

	# Record continuous trajectory
	sample_timer += delta
	if sample_timer >= SAMPLE_RATE:
		sample_timer = 0.0
		recorded_path.append(global_position)

	queue_redraw()


func _die() -> void:
	_is_dying = true
	AudioManager.play_death()
	set_physics_process(false)
	visible = false
	var fx := get_tree().get_first_node_in_group("web_fx")
	if fx:
		fx.burst(global_position, UI.RED, 35, 60.0, 180.0, 3.0, 0.6)
		fx.shake(12.0)
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("show_death"):
		hud.show_death(0.7)
	elif hud and hud.has_method("show_message"):
		hud.show_message("CRITICAL CORRUPTION // SIGNAL LOST\nRESTARTING CYCLE...", 0.8)
	get_tree().create_timer(0.7).timeout.connect(func(): GameData.restart_level())


func _draw() -> void:
	# Web style: ~28px sprite with a cyan glow; animates only while running.
	WebWorld.draw_glow(self, Vector2.ZERO, 22.0, Color(UI.CYAN, 0.35))
	if _anim_frames.is_empty():
		return
	var moving := absf(velocity.x) > 1.0
	var frame_idx: int = int(_anim_timer) % _anim_frames.size() if moving else 0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(signf(facing) if facing != 0.0 else 1.0, 1.0))
	var src := Rect2(frame_idx * 32.0, 0.0, 32.0, 32.0)
	draw_texture_rect_region(preload("res://assets/art/spritesheet.png"), Rect2(-16, -16, 32, 32), src)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
