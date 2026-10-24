## Side-scrolling cybernetic player controller for SHADOW.exe.
## Features separate keys for jump vs deploy:
## - [W] / [Up Arrow]: Jump
## - [SPACE] / [E]: Deploy Shadow Clone
## - [F] / [Q]: Shadow Flip
## Renders animated cyber-avatar sprite frames (from player.gif).
extends CharacterBody2D

const SPEED: float = 240.0
const JUMP_VELOCITY: float = -480.0
const GRAVITY: float = 900.0

var recorded_path: Array[Vector2] = []
var sample_timer: float = 0.0
const SAMPLE_RATE: float = 0.033

var facing: float = 1.0
var _time_alive: float = 0.0
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
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("show_message"):
		hud.show_message("CRITICAL CORRUPTION // SIGNAL LOST\nRESTARTING CYCLE...", 0.8)
	get_tree().create_timer(0.65).timeout.connect(func(): GameData.restart_level())


func _draw() -> void:
	# Holographic floor ring
	draw_arc(Vector2(0, 16), 16.0, 0.0, PI, 16, Color(0.0, 0.9, 1.0, 0.25), 1.5)

	# Draw animated sprite frames
	if not _anim_frames.is_empty():
		var frame_idx: int = int(_time_alive * 10.0) % _anim_frames.size()
		var tex: Texture2D = _anim_frames[frame_idx]
		if tex:
			var sz := tex.get_size()
			# Apply horizontal flipping based on facing direction
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
			draw_texture(tex, -sz * 0.5)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		# Fallback cyber torso
		var torso_pts := PackedVector2Array([
			Vector2(-10, -18), Vector2(10, -18), Vector2(14, 0),
			Vector2(8, 16), Vector2(-8, 16), Vector2(-14, 0),
		])
		draw_colored_polygon(torso_pts, Color(0.04, 0.1, 0.22, 0.95))
		draw_polyline(torso_pts, Color(0.0, 0.9, 1.0, 0.85), 2.0)
		draw_circle(Vector2(0, -2), 6.0, Color(0.0, 1.0, 1.0, 0.75))
