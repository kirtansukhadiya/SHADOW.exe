## SHADOW.exe — Godot port of the browser build (index.html).
## Mirrors the web version one-to-one: page layout (top nav, game canvas,
## key legend), level data, physics, shadow clone/flip, drawing, menus,
## modal terminal and audio. Theme: REVERSAL.
extends Control

const UI := preload("res://scripts/ui_style.gd")
const WebWorld := preload("res://scripts/web_world.gd")
const TerminalModal := preload("res://scripts/terminal_modal.gd")
const WebAudio := preload("res://scripts/web_audio.gd")
# Cubit: the player is a hovering cube that tumbles as it moves. The echo
# and reversed shadow are Cubits too, in their own colours.
const CUBIT_FILL := Color("#0d1f38")
const ECHO_FILL := Color("#24140a")
const REVERSED_FILL := Color("#1c0a2a")
const CUBIT_ROLL_SPEED := 6.0  # radians per second while moving
const CUBIT_IDLE_SPIN := 2.0   # radians per second while standing (never stops)

# --- GAME CONSTANTS (same as web) ---
const CANVAS_W := 960.0
const CANVAS_H := 640.0
const GRAVITY := 900.0
const SPEED := 240.0
const JUMP_POWER := -490.0
const PLAYER_W := 24.0
const PLAYER_H := 34.0
# Collision half-widths. The web build used 12 (walls) and 9 (floors), which
# is wider than the 20px void gaps: the player could never drop in and instead
# stood on a 1px pillar corner. Narrower boxes let the player fall off edges.
const HIT_HW_WALL := 9.0
const HIT_HW_FLOOR := 6.0

enum State { MENU, PLAYING, VICTORY }

# Level definitions copied from the web build.
const LEVELS := [
	# LEVEL 0: TUTORIAL PROTOCOL
	{
		"name": "TUTORIAL PROTOCOL",
		"phase": "CALIBRATION",
		"subtitle": "SHADOW CLONE & REVERSAL REHEARSAL",
		"spawn": [80, 520],
		"solids": [
			[0, 550, 960, 90, "#0a121e"],
			[218, 520, 24, 30, "#142236"],
			[325, 440, 110, 14, "#101c2e"],
			[510, 0, 20, 470, "#0e1828"],
			[690, 0, 20, 470, "#0e1828"],
		],
		"plates": [
			{"id": "p1", "x": 380, "y": 436, "w": 48, "h": 12, "doors": ["d1"], "release_delay": 0.5},
			{"id": "p2", "x": 300, "y": 546, "w": 48, "h": 12, "doors": ["d2"], "release_delay": 0.5},
		],
		"doors": [
			{"id": "d1", "x": 520, "y": 510, "w": 16, "h": 80},
			{"id": "d2", "x": 700, "y": 510, "w": 16, "h": 80},
		],
		"terminal": {
			"x": 150, "y": 535,
			"title": "TUTORIAL PROTOCOL LOG",
			"text": "1. Walk [A/D] and Jump [W] onto the raised platform to touch Plate 1.\n2. Return to the lower floor. Press [SPACE] to deploy your Shadow clone!\n3. While your shadow steps on Plate 1, pass Door 1, then press [F] to REVERSE your shadow back onto Plate 2!",
		},
		"exit": [850, 510],
	},
	# LEVEL 1: DISCOVERY (THE ECHO)
	# Why reversal is mandatory:
	#  - Door 1 needs Plate B, Door 2 needs Plate A, and the doors come in that
	#    order (B first, then A).
	#  - Plate A is on the spawn ledge; the drop to the lower floor (180px) is
	#    higher than a jump (~133px), so any recording visits A before B.
	#  - A forward replay presses A then B (wrong order) and parks at the
	#    deploy point, which can't be Plate A (the path must continue to B).
	#  - Flipping walks the echo back over B (Door 1) and then up to A (Door 2).
	{
		"name": "LEVEL 1 - DISCOVERY",
		"phase": "THE ECHO",
		"subtitle": "ECHO DETECTED. ITS ORDER IS WRONG. REVERSE IT.",
		"spawn": [50, 353],
		"solids": [
			[0, 370, 300, 270, "#0c1626"],    # Spawn ledge (180px above the floor: one-way drop)
			[300, 550, 660, 90, "#0a121e"],   # Lower floor
			[590, 0, 220, 430, "#0d1829"],    # Airlock roof over Doors 1 & 2
		],
		"plates": [
			{"id": "pA", "x": 210, "y": 366, "w": 48, "h": 12, "doors": ["d2"], "release_delay": 0.5},  # Plate A (ledge)
			{"id": "pB", "x": 430, "y": 546, "w": 48, "h": 12, "doors": ["d1"], "release_delay": 0.5},  # Plate B (floor)
		],
		"doors": [
			{"id": "d1", "x": 600, "y": 490, "w": 18, "h": 120},
			{"id": "d2", "x": 800, "y": 490, "w": 18, "h": 120},
		],
		"terminal": {
			"x": 120, "y": 355,
			"title": "ARCHIVE 01: SYSTEM AWAKENING",
			"text": "ARCHIVE 01: SUBJECT AWAKENED IN CORRUPTED SECTOR 1.\nTHE LEDGE BELOW IS ONE-WAY. YOUR ECHO REPLAYS YOUR STEPS IN THE ORDER YOU TOOK THEM.\nTHE AIRLOCK DEMANDS THE OPPOSITE ORDER. DEPLOY [SPACE], THEN REVERSE TIME [F].",
		},
		"exit": [890, 500],
	},
	# LEVEL 2: DOUBT (THE OPPOSITE)
	{
		"name": "LEVEL 2 - DOUBT",
		"phase": "THE OPPOSITE",
		"subtitle": "WARNING: ORIGINAL SIGNAL NOT FOUND.",
		"spawn": [70, 520],
		"solids": [
			[0, 550, 960, 90, "#0a121e"],
			[540, 0, 210, 470, "#0d1829"],
			[130, 450, 100, 14, "#101c2e"],
			[260, 350, 100, 14, "#101c2e"],
			[390, 260, 100, 14, "#101c2e"],
		],
		"plates": [
			{"id": "p1", "x": 440, "y": 256, "w": 48, "h": 12, "doors": ["d1"], "release_delay": 0.5},
			{"id": "p2", "x": 150, "y": 546, "w": 48, "h": 12, "doors": ["d2"], "release_delay": 0.5},
		],
		"doors": [
			{"id": "d1", "x": 550, "y": 510, "w": 16, "h": 80},
			{"id": "d2", "x": 740, "y": 510, "w": 16, "h": 80},
		],
		"terminal": {
			"x": 620, "y": 535,
			"title": "ARCHIVE 02: SIGNAL ANOMALY",
			"text": "ARCHIVE 02: WARNING: THE SIGNAL YOU ARE TRACING DOES NOT ORIGINATE FROM YOU.\nWHO IS THE ARCHIVE, AND WHO IS THE PROGRAM?",
		},
		"exit": [870, 510],
	},
	# LEVEL 3: REVELATION (THE ORIGINAL)
	{
		"name": "LEVEL 3 - REVELATION",
		"phase": "THE ORIGINAL",
		"subtitle": "IDENTITY ERROR: YOU ARE THE ECHO.",
		"spawn": [70, 520],
		"solids": [
			[0, 550, 960, 90, "#0a121e"],
			[450, 0, 20, 470, "#0d1829"],
			[670, 0, 20, 470, "#0d1829"],
			[810, 0, 20, 470, "#0d1829"],
			[130, 450, 100, 14, "#101c2e"],
			[265, 360, 110, 14, "#101c2e"],
		],
		"plates": [
			{"id": "p1", "x": 160, "y": 546, "w": 48, "h": 12, "doors": ["d1", "d3"], "release_delay": 0.5},
			{"id": "p2", "x": 320, "y": 356, "w": 48, "h": 12, "doors": ["d2"], "release_delay": 0.5},
		],
		"doors": [
			{"id": "d1", "x": 460, "y": 510, "w": 16, "h": 80},
			{"id": "d2", "x": 680, "y": 510, "w": 16, "h": 80},
			{"id": "d3", "x": 820, "y": 510, "w": 16, "h": 80},
		],
		"terminal": {
			"x": 750, "y": 535,
			"title": "ARCHIVE 03: CLASSIFIED TRUTH",
			"text": "ARCHIVE 03: SYSTEM RESET PURGED THE MASTER RECORD.\nTHE BLUE FORM IS AN EMISSION. YOU ARE THE ECHO.\nTHE RED SHADOW WAS YOU.",
		},
		"exit": [900, 510],
	},
]

const MANUAL_TITLE := "SHADOW.exe MANUAL // REVERSAL PROTOCOL"
const MANUAL_TEXT := "MISSION DIRECTIVE:\n1. [W] or [UP] to JUMP. Space is strictly for Shadow clone deployment.\n2. Walk across pressure plates to open security blast doors.\n3. Press [SPACE] to deploy your Shadow clone, which replays your past steps.\n4. Press [F] for SHADOW FLIP: time-reverses the clone, so it revisits your steps in the opposite order. Every sector requires it.\n5. Reaching the Extraction Portal triggers sector advance."

# --- GLOBAL STATE ---
var game_state: State = State.MENU
var current_level_index: int = 1
var screen_shake: float = 0.0
var death_transition: float = 0.0
var keys := {"left": false, "right": false, "jump": false, "deploy": false, "flip": false, "interact": false}
var particles: Array[Dictionary] = []

# --- ACTIVE LEVEL RUNNER STATE ---
var data: Dictionary
var solids: Array[Rect2] = []
var solid_colors: Array[Color] = []
var plates: Array[Dictionary] = []
var doors: Array[Dictionary] = []
var terminal: Dictionary
var exit_pos: Vector2
var exit_rot: float = 0.0
var player: Dictionary
var history: Array[Dictionary] = []
var recording: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var shadow: Dictionary
var complete: bool = false

# --- NODES ---
var _canvas: Control
var _modal: Control
var _audio: Node
var _level_badge: Label
var _phase_badge: Label
var _sound_btn: Button
var _brand: Control
var _shake_off := Vector2.ZERO
var _bg_tex: GradientTexture2D
var _cube_outer := PackedVector2Array()
var _cube_inner := PackedVector2Array()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cube_outer = _rounded_square(8.0, 2.5)
	_cube_inner = _rounded_square(5.0, 1.5)
	_audio = WebAudio.new()
	add_child(_audio)
	_build_page()
	# Initialize (web: loadLevel(1); gameState = MENU)
	load_level(1)
	game_state = State.MENU


# ═══════════════════════════════ PAGE LAYOUT ═══════════════════════════════

func _build_page() -> void:
	# body: radial-gradient(circle at 50% 20%, #0d1a2d 0%, #03070d 80%)
	var g := Gradient.new()
	g.set_color(0, Color("#0d1a2d"))
	g.set_color(1, Color("#03070d"))
	_bg_tex = GradientTexture2D.new()
	_bg_tex.gradient = g
	_bg_tex.fill = GradientTexture2D.FILL_RADIAL
	_bg_tex.fill_from = Vector2(0.5, 0.2)
	_bg_tex.fill_to = Vector2(0.5 + 0.8 * 0.94, 0.2)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 0)
	center.add_child(column)

	column.add_child(_build_top_nav())
	column.add_child(_build_game_container())
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	column.add_child(gap)
	column.add_child(_build_bottom_bar())


func _draw() -> void:
	draw_texture_rect(_bg_tex, Rect2(Vector2.ZERO, size), false)


func _build_top_nav() -> Control:
	var nav := PanelContainer.new()
	nav.custom_minimum_size = Vector2(962, 0)
	var sb := UI.box(UI.PANEL_BG, UI.BORDER, 1, 0, Color(UI.CYAN, 0.1), 20)
	sb.border_width_bottom = 0
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	nav.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	nav.add_child(row)
	var title := HBoxContainer.new()
	title.add_theme_constant_override("separation", 10)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)

	_brand = Control.new()
	_brand.custom_minimum_size = Vector2(UI.orbitron(900).get_string_size("SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 4, 22)
	_brand.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_brand.draw.connect(_draw_brand)
	title.add_child(_brand)

	_level_badge = _badge("SYSTEM INITIALIZED", UI.CYAN, UI.CYAN_DIM, Color(UI.CYAN, 0.12), title)
	_phase_badge = _badge("THEME: REVERSAL", UI.ORANGE, UI.ORANGE, Color(UI.ORANGE, 0.15), title)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	row.add_child(controls)
	for spec in [["TITLE MENU", _on_nav_menu], ["TUTORIAL", _on_nav_tutorial], ["RESET [R]", _on_nav_restart],
			["SOUND: ON", _on_nav_sound], ["FULLSCREEN", _on_nav_fullscreen]]:
		var b := Button.new()
		b.text = spec[0]
		UI.style_nav_button(b)
		b.add_theme_font_override("font", UI.mono_spaced())
		b.pressed.connect(spec[1])
		controls.add_child(b)
		if spec[0] == "SOUND: ON":
			_sound_btn = b
	return nav


func _badge(text: String, color: Color, border: Color, bg: Color, parent: Control) -> Label:
	var p := PanelContainer.new()
	var sb := UI.box(bg, border, 1, 3)
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var l := UI.label(text.to_upper(), UI.mono_spaced(), 11, color)
	p.add_child(l)
	parent.add_child(p)
	return l


## Brand "SHADOW.exe" with the CSS glitch text-shadow (3s, alternate).
func _draw_brand() -> void:
	var font := UI.orbitron(900)
	var pos := Vector2(2, 17)
	var t := fmod(Time.get_ticks_msec() / 1000.0, 6.0) / 3.0
	if t > 1.0:
		t = 2.0 - t
	if t > 0.1 and t < 0.3:
		_brand.draw_string(font, pos + Vector2(-2, 0), "SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ff0055"))
		_brand.draw_string(font, pos + Vector2(2, 0), "SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#00ffff"))
	elif t >= 0.3 and t < 0.5:
		_brand.draw_string(font, pos + Vector2(2, 0), "SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ff0055"))
		_brand.draw_string(font, pos + Vector2(-2, 0), "SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#00ffff"))
	else:
		_brand.draw_string_outline(font, pos, "SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 8, Color(UI.CYAN, 0.25))
	_brand.draw_string(font, pos, "SHADOW.exe", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UI.CYAN)


func _build_game_container() -> Control:
	var frame := Panel.new()
	frame.custom_minimum_size = Vector2(962, 642)
	var sb := UI.box(Color("#020408"), UI.BORDER, 1, 0)
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.shadow_color = Color(0, 0, 0, 0.9)
	sb.shadow_size = 20
	sb.shadow_offset = Vector2(0, 10)
	frame.add_theme_stylebox_override("panel", sb)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_canvas = Control.new()
	_canvas.position = Vector2(1, 1)
	_canvas.size = Vector2(CANVAS_W, CANVAS_H)
	_canvas.clip_contents = true
	_canvas.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_canvas.draw.connect(_draw_canvas)
	_canvas.gui_input.connect(_on_canvas_input)
	frame.add_child(_canvas)

	# CRT scanline overlay over the canvas only (web #crt-overlay)
	var crt := ColorRect.new()
	crt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	float line = step(1.5, mod(FRAGCOORD.y, 3.0)) * 0.25;
	float d = distance(UV, vec2(0.5)) / 0.7071;
	float vig = smoothstep(0.7, 1.0, d) * 0.4;
	COLOR = vec4(0.0, 0.0, 0.0, (1.0 - (1.0 - line) * (1.0 - vig)) * 0.7);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	crt.material = mat
	_canvas.add_child(crt)

	_modal = TerminalModal.new()
	_modal.closed.connect(func():
		keys.left = false
		keys.right = false
		keys.jump = false
		keys.deploy = false
		keys.flip = false
		keys.interact = false
	)
	_canvas.add_child(_modal)
	return frame


func _build_bottom_bar() -> Control:
	var bar := PanelContainer.new()
	bar.custom_minimum_size = Vector2(962, 0)
	var sb := UI.box(Color(5 / 255.0, 12 / 255.0, 20 / 255.0, 0.75), Color(UI.CYAN, 0.2), 1, 4)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	bar.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	bar.add_child(row)
	var left := HBoxContainer.new()
	left.add_theme_constant_override("separation", 12)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(left)
	for g in [[["A", "D"], "Move", false], [["W"], "Jump", false], [["SPACE"], "Deploy Shadow", false],
			[["F"], "Shadow Flip (REVERSE)", true], [["E"], "Interact / Read", false], [["R"], "Quick Reset", false]]:
		var group := HBoxContainer.new()
		group.add_theme_constant_override("separation", 5)
		for k in g[0]:
			var cap := UI.keycap(k)
			cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			group.add_child(cap)
		group.add_child(UI.label(g[1], UI.mono(), 11, UI.ORANGE if g[2] else UI.TEXT_MUTED))
		left.add_child(group)
	var tag := UI.label("CYBER ECHO REVERSAL SIMULATION // V2.0", UI.mono(), 11, UI.CYAN)
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(tag)
	return bar


# ═══════════════════════════════ LEVEL RUNNER ═══════════════════════════════

func show_level_instructions(_lvl: Dictionary) -> void:
	var title: String = "PROTOCOL BRIEFING // CONTROLS & OBJECTIVE"
	var body: String = (
		"OPERATIONAL INSTRUCTIONS & CONTROLS:\n\n" +
		"  • [W] / [↑]          JUMP across platforms & void\n" +
		"  • [SPACE]            DEPLOY SHADOW (clone replays past recorded path)\n" +
		"  • [F]                FLIP (REVERSES time! Rewinds shadow backward)\n" +
		"  • [R]                RESET timeline sequence\n" +
		"  • [A] / [D] / [←][→]  MOVE / SPRINT left and right\n\n" +
		"MISSION OBJECTIVE:\n" +
		"Cooperate with your time-reversed shadow to press plates, open security blast doors, and reach the Extraction Portal."
	)
	_modal.open(title, body, "START GAME [SPACE / ENTER]")


func load_level(idx: int, show_briefing: bool = false) -> void:
	current_level_index = idx
	data = LEVELS[idx]
	solids.clear()
	solid_colors.clear()
	for s in data.solids:
		solids.append(Rect2(s[0], s[1], s[2], s[3]))
		solid_colors.append(Color(s[4]))
	plates.clear()
	for p in data.plates:
		var c: Dictionary = p.duplicate(true)
		c.is_pressed = false
		c.timer = 0.0
		plates.append(c)
	doors.clear()
	for d in data.doors:
		var c: Dictionary = d.duplicate(true)
		c.open_amount = 0.0
		doors.append(c)
	terminal = data.terminal
	exit_pos = Vector2(data.exit[0], data.exit[1])
	exit_rot = 0.0
	player = {"x": float(data.spawn[0]), "y": float(data.spawn[1]), "vx": 0.0, "vy": 0.0, "on_ground": false,
		"facing": 1.0, "roll": 0.0, "cube_ang": 0.0, "is_dead": false}
	history.clear()
	recording = true
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	shadow = {"active": false, "history": [], "index": 0, "playback_dir": 1, "x": 0.0, "y": 0.0,
		"facing": 1.0, "cube_ang": 0.0, "is_reversed": false}
	complete = false

	# Update top navigation badges
	_level_badge.text = data.name
	_phase_badge.text = data.phase

	# Instructions ONLY appear before Level 1
	if show_briefing and idx == 1 and game_state == State.PLAYING:
		show_level_instructions(data)


func next_level() -> void:
	if current_level_index < LEVELS.size() - 1:
		load_level(current_level_index + 1, false)
	else:
		game_state = State.VICTORY
		_audio.play("victory")


func restart_level() -> void:
	load_level(current_level_index, false)


func _update(dt: float) -> void:
	if player.is_dead:
		return

	# 1. Player physics & controls
	var move_dir := 0.0
	if keys.left:
		move_dir -= 1.0
	if keys.right:
		move_dir += 1.0
	player.vx = move_dir * SPEED
	player.vy += GRAVITY * dt
	if move_dir != 0.0:
		player.facing = move_dir
	# Cubit always spins toward the way it faces; faster while moving.
	player.roll += player.facing * (CUBIT_ROLL_SPEED if move_dir != 0.0 else CUBIT_IDLE_SPIN) * dt
	player.cube_ang = player.roll

	# Coyote time & jump buffering
	coyote_timer = 0.14 if player.on_ground else maxf(0.0, coyote_timer - dt)
	if keys.jump:
		jump_buffer_timer = 0.16
	elif jump_buffer_timer > 0.0:
		jump_buffer_timer = maxf(0.0, jump_buffer_timer - dt)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		player.vy = JUMP_POWER
		player.on_ground = false
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		_audio.play("jump")

	player.x += player.vx * dt
	_resolve_x(player)
	player.y += player.vy * dt
	player.on_ground = false
	_resolve_y(player)

	if recording:
		history.append({"x": player.x, "y": player.y, "facing": player.facing, "cube_ang": player.cube_ang})

	# Void fall death check
	if player.y > 615.0 and not player.is_dead:
		_trigger_death()
		return

	# 2. Deploy shadow
	if keys.deploy and recording and history.size() > 5:
		keys.deploy = false
		_deploy_shadow()
	# 3. Shadow flip
	if keys.flip and shadow.active:
		keys.flip = false
		_flip_shadow()
	# 4. Shadow clone
	if shadow.active:
		_update_shadow()
	_update_plates(dt)
	_update_doors(dt)
	_check_terminal()
	_check_exit()
	exit_rot += dt * 2.0


func _all_solids() -> Array[Rect2]:
	var all := solids.duplicate()
	for d in doors:
		if d.open_amount < 0.8:
			all.append(Rect2(d.x - d.w / 2.0, d.y - d.h / 2.0, d.w, d.h))
	return all


func _resolve_x(e: Dictionary) -> void:
	var hw := HIT_HW_WALL
	var hh := PLAYER_H / 2.0
	for b in _all_solids():
		var p_left: float = e.x - hw
		var p_right: float = e.x + hw
		var p_top: float = e.y - hh + 4.0
		var p_bottom: float = e.y + hh - 4.0
		if p_right > b.position.x and p_left < b.end.x and p_bottom > b.position.y and p_top < b.end.y:
			if e.vx > 0.0:
				e.x = b.position.x - hw
				e.vx = 0.0
			elif e.vx < 0.0:
				e.x = b.end.x + hw
				e.vx = 0.0


func _resolve_y(e: Dictionary) -> void:
	var hw := HIT_HW_FLOOR
	var hh := PLAYER_H / 2.0
	for b in _all_solids():
		var p_left: float = e.x - hw
		var p_right: float = e.x + hw
		var p_top: float = e.y - hh
		var p_bottom: float = e.y + hh
		if p_right > b.position.x and p_left < b.end.x and p_bottom > b.position.y and p_top < b.end.y:
			if e.vy > 0.0:
				e.y = b.position.y - hh
				e.vy = 0.0
				e.on_ground = true
			elif e.vy < 0.0:
				e.y = b.end.y + hh
				e.vy = 0.0


func _deploy_shadow() -> void:
	shadow.active = true
	shadow.history = history.duplicate()
	shadow.index = 0
	shadow.playback_dir = 1
	shadow.is_reversed = false
	recording = false
	_audio.play("deploy")
	var origin: Dictionary = shadow.history[0]
	for i in 20:
		var angle := TAU * i / 20.0
		var spd := 80.0 + randf() * 60.0
		_add_particle(origin.x, origin.y, cos(angle) * spd, sin(angle) * spd, UI.ORANGE, 3.0, 0.5)


func _flip_shadow() -> void:
	shadow.playback_dir *= -1
	shadow.is_reversed = not shadow.is_reversed
	screen_shake = 6.0
	_audio.play("flip")
	for i in 30:
		var angle := randf() * TAU
		var spd := 90.0 + randf() * 90.0
		_add_particle(shadow.x, shadow.y, cos(angle) * spd, sin(angle) * spd,
			UI.VIOLET if shadow.is_reversed else UI.ORANGE, 4.0, 0.6)


func _update_shadow() -> void:
	var hist: Array = shadow.history
	shadow.index = clampi(shadow.index + shadow.playback_dir, 0, hist.size() - 1)
	var frame: Dictionary = hist[shadow.index]
	shadow.x = frame.x
	shadow.y = frame.y
	shadow.facing = -frame.facing if shadow.playback_dir == -1 else frame.facing
	shadow.cube_ang = frame.cube_ang  # replayed backwards after a flip, so it rolls in reverse
	if randf() < 0.4:
		_add_particle(shadow.x + (randf() - 0.5) * 10.0, shadow.y + (randf() - 0.5) * 16.0,
			-shadow.facing * 10.0, -15.0, UI.VIOLET if shadow.is_reversed else UI.ORANGE, 2.5, 0.4)


func _on_plate(e_x: float, e_y: float, p: Dictionary) -> bool:
	var p_l: float = p.x - p.w / 2.0
	var p_r: float = p.x + p.w / 2.0
	var p_t: float = p.y - p.h / 2.0
	var p_b: float = p.y + p.h / 2.0
	return e_x + PLAYER_W / 2.0 > p_l and e_x - PLAYER_W / 2.0 < p_r \
		and e_y + PLAYER_H / 2.0 >= p_t - 4.0 and e_y - PLAYER_H / 2.0 < p_b


func _update_plates(dt: float) -> void:
	for p in plates:
		var standing := _on_plate(player.x, player.y, p)
		if shadow.active and _on_plate(shadow.x, shadow.y, p):
			standing = true
		if standing:
			p.timer = p.release_delay
			if not p.is_pressed:
				p.is_pressed = true
				_audio.play("plate")
		elif p.timer > 0.0:
			p.timer -= dt
		else:
			p.is_pressed = false


func _update_doors(dt: float) -> void:
	for d in doors:
		var should_open := false
		for p in plates:
			if d.id in p.doors and p.is_pressed:
				should_open = true
		if should_open:
			if d.open_amount < 1.0:
				d.open_amount = minf(1.0, d.open_amount + dt * 3.5)
				if d.open_amount == 1.0:
					_audio.play("door")
		elif d.open_amount > 0.0:
			d.open_amount = maxf(0.0, d.open_amount - dt * 3.5)


func _check_terminal() -> void:
	if Vector2(player.x, player.y).distance_to(Vector2(terminal.x, terminal.y)) < 45.0 and keys.interact:
		keys.interact = false
		_modal.open(terminal.title, terminal.text)


func _check_exit() -> void:
	if Vector2(player.x, player.y).distance_to(exit_pos) < 45.0 and not complete:
		complete = true
		_audio.play("victory")
		next_level()


func _trigger_death() -> void:
	player.is_dead = true
	screen_shake = 12.0
	_audio.play("death")
	death_transition = 0.7
	for i in 35:
		var angle := randf() * TAU
		var spd := 60.0 + randf() * 120.0
		_add_particle(player.x, player.y, cos(angle) * spd, sin(angle) * spd, UI.RED, 3.0, 0.6)


func _add_particle(x: float, y: float, vx: float, vy: float, color: Color, sz: float, life: float) -> void:
	particles.append({"x": x, "y": y, "vx": vx, "vy": vy, "color": color, "size": sz, "life": life, "max_life": life})


# ═══════════════════════════════ MAIN LOOP ═══════════════════════════════

func _process(delta: float) -> void:
	var dt := minf(0.05, delta)
	_shake_off = Vector2.ZERO
	if screen_shake > 0.0:
		_shake_off = Vector2(randf() - 0.5, randf() - 0.5) * screen_shake * 2.0
		screen_shake = maxf(0.0, screen_shake - dt * 25.0)

	if game_state == State.PLAYING:
		if not _modal.is_open():
			_update(dt)
			if player.is_dead:
				death_transition -= dt
				if death_transition <= 0.0:
					restart_level()
	_canvas.queue_redraw()
	_brand.queue_redraw()


# ═══════════════════════════════ DRAWING ═══════════════════════════════

func _draw_canvas() -> void:
	_canvas.draw_set_transform(_shake_off)
	var time := Time.get_ticks_msec() / 1000.0
	match game_state:
		State.PLAYING: _draw_level()
		State.MENU: _draw_menu(time)
		State.VICTORY: _draw_victory()
	_canvas.draw_set_transform(Vector2.ZERO)


## Canvas-style fillText: align 0 = left, 1 = center, 2 = right; y is the baseline.
func _text(s: String, x: float, y: float, font: Font, sz: int, color: Color, align: int = 0, glow: float = 0.0) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
	var pos := Vector2(x - (w / 2.0 if align == 1 else (w if align == 2 else 0.0)), y)
	if glow > 0.0:
		_canvas.draw_string_outline(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, int(glow), Color(color, 0.12))
		_canvas.draw_string_outline(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, int(glow / 2.0), Color(color, 0.2))
	_canvas.draw_string(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, color)


## Draws a Cubit in the 32px character box centred on `pos` (feet at +16).
## `s` scales the whole character (2.0 on the title cards).
func _draw_cubit(pos: Vector2, ang: float, facing: float, s: float, outline: Color, fill: Color, t: float) -> void:
	var c := _canvas
	# Soft floor shadow
	c.draw_set_transform(_shake_off + pos + Vector2(0, 15.0 * s), 0.0, Vector2(1.0, 0.22))
	c.draw_circle(Vector2.ZERO, 7.0 * s, Color(outline, 0.12))
	# Hovering, tumbling body
	var center := pos + Vector2(0, (4.0 + sin(t * 3.0) * 1.4) * s)
	c.draw_set_transform(_shake_off)
	_glow(center, 17.0 * s, outline, 0.35)
	c.draw_set_transform(_shake_off + center, ang, Vector2(s, s))
	c.draw_colored_polygon(_cube_outer, fill)
	c.draw_polyline(_cube_outer, Color(outline, 0.3), 4.0)
	c.draw_polyline(_cube_outer, outline, 1.5)
	c.draw_polyline(_cube_inner, Color(outline, 0.35), 1.0)
	# Eyes stay upright and look the way the Cubit is facing
	c.draw_set_transform(_shake_off + center, 0.0, Vector2(s * (1.0 if facing >= 0.0 else -1.0), s))
	c.draw_rect(Rect2(-0.5, -4, 4, 5.5), Color(outline, 0.25))
	c.draw_rect(Rect2(3, -4, 4, 5.5), Color(outline, 0.25))
	c.draw_rect(Rect2(0.5, -3, 2, 3.5), outline)
	c.draw_rect(Rect2(4, -3, 2, 3.5), outline)
	c.draw_set_transform(_shake_off)


## Closed outline of a rounded square (half-size `h`, corner radius `r`).
func _rounded_square(h: float, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var corners := [Vector2(h - r, -h + r), Vector2(h - r, h - r), Vector2(-h + r, h - r), Vector2(-h + r, -h + r)]
	var start_angles := [-PI / 2.0, 0.0, PI / 2.0, PI]
	for i in 4:
		for k in 5:
			var a: float = start_angles[i] + (PI / 2.0) * k / 4.0
			pts.append(corners[i] + Vector2(cos(a), sin(a)) * r)
	pts.append(pts[0])
	return pts


func _glow(pos: Vector2, radius: float, color: Color, alpha: float = 0.45) -> void:
	WebWorld.draw_glow(_canvas, pos, radius, Color(color, alpha))


func _draw_level() -> void:
	var c := _canvas
	var now := Time.get_ticks_msec() / 1000.0
	# 1. Background cyber grid
	c.draw_rect(Rect2(0, 0, CANVAS_W, CANVAS_H), Color("#03070d"))
	var grid := Color(0, 240 / 255.0, 1, 0.04)
	for x in range(0, int(CANVAS_W), 40):
		c.draw_line(Vector2(x, 0), Vector2(x, CANVAS_H), grid, 1.0)
	for y in range(0, int(CANVAS_H), 40):
		c.draw_line(Vector2(0, y), Vector2(CANVAS_W, y), grid, 1.0)
	c.draw_rect(Rect2(0, 590, CANVAS_W, 50), Color(1, 30 / 255.0, 60 / 255.0, 0.06))

	# 2. Solids
	for i in solids.size():
		var b := solids[i]
		c.draw_rect(b, solid_colors[i])
		c.draw_rect(b, UI.CYAN, false, 1.5)
		c.draw_line(b.position, Vector2(b.end.x, b.position.y), UI.CYAN, 2.5)

	# 3. Pressure plates
	for p in plates:
		var active: bool = p.is_pressed
		var press := 4.0 if active else 0.0
		var r := Rect2(p.x - p.w / 2.0, p.y - p.h / 2.0 + press, p.w, p.h - press)
		c.draw_rect(r, Color("#ffaa00") if active else Color("#142336"))
		c.draw_rect(r, Color.WHITE if active else UI.CYAN, false, 2.0)
		if active:
			_glow(Vector2(p.x, r.position.y + 1.5), 24.0, UI.ORANGE, 0.5)
			c.draw_rect(Rect2(r.position.x + 6, r.position.y, p.w - 12, 3), UI.ORANGE)

	# 4. Airlock blast doors
	for d in doors:
		var d_l: float = d.x - d.w / 2.0
		var d_t: float = d.y - d.h / 2.0
		for hr in [Rect2(d_l - 4, d_t - 8, d.w + 8, 8), Rect2(d_l - 4, d_t + d.h, d.w + 8, 8)]:
			c.draw_rect(hr, Color("#0a1626"))
			c.draw_rect(hr, UI.CYAN, false, 1.0)
		var cur_h: float = d.h * (1.0 - d.open_amount)
		if cur_h > 2.0:
			c.draw_rect(Rect2(d_l, d_t, d.w, cur_h), Color("#06101c"))
			c.draw_line(Vector2(d.x, d_t), Vector2(d.x, d_t + cur_h), Color(UI.RED, 0.18), 12.0)
			c.draw_line(Vector2(d.x, d_t), Vector2(d.x, d_t + cur_h), Color(UI.RED, 0.3), 7.0)
			c.draw_line(Vector2(d.x, d_t), Vector2(d.x, d_t + cur_h), UI.RED, 3.0)
			c.draw_line(Vector2(d_l + 2, d_t + cur_h), Vector2(d_l + d.w - 2, d_t + cur_h), Color.WHITE, 1.0)

	# 5. Story terminal
	var tx: float = terminal.x
	var ty: float = terminal.y
	c.draw_rect(Rect2(tx - 14, ty - 32, 28, 36), Color("#061324"))
	c.draw_rect(Rect2(tx - 14, ty - 32, 28, 36), UI.CYAN, false, 1.5)
	c.draw_rect(Rect2(tx - 10, ty - 28, 20, 16), UI.CYAN)
	if Vector2(player.x, player.y).distance_to(Vector2(tx, ty)) < 45.0:
		_text("[E] ACCESS ARCHIVE", tx, ty - 40, UI.mono(), 11, UI.CYAN, 1)

	# 6. Exit portal
	_dashed_circle(exit_pos, 32.0, 8.0, 6.0, exit_rot, Color(0, 240 / 255.0, 1, 0.7), 2.5)
	_dashed_circle(exit_pos, 20.0, 6.0, 4.0, -exit_rot, Color(1, 119 / 255.0, 0, 0.8), 2.0)
	_glow(exit_pos, 22.0, UI.CYAN, 0.6)
	c.draw_set_transform(_shake_off + exit_pos, -exit_rot)
	c.draw_rect(Rect2(-6, -6, 12, 12), UI.CYAN)
	c.draw_set_transform(_shake_off)
	_draw_portal_label()

	# 7. Shadow clone
	if shadow.active:
		var s_pos := Vector2(shadow.x, shadow.y)
		var s_col := UI.VIOLET if shadow.is_reversed else UI.ORANGE
		_draw_cubit(s_pos, shadow.cube_ang, shadow.facing, 1.0, s_col,
			REVERSED_FILL if shadow.is_reversed else ECHO_FILL, now)
		_text("<< REVERSED SHADOW" if shadow.is_reversed else "ECHO SHADOW >>", shadow.x, shadow.y - 24, UI.mono(), 10, s_col, 1)

	# 8. Player
	if not player.is_dead:
		var p_pos := Vector2(player.x, player.y)
		_draw_cubit(p_pos, player.cube_ang, player.facing, 1.0, UI.CYAN, CUBIT_FILL, now)

	# 9. Particles (web advances them by a fixed 0.016 per draw)
	for i in range(particles.size() - 1, -1, -1):
		var pt := particles[i]
		pt.x += pt.vx * 0.016
		pt.y += pt.vy * 0.016
		pt.life -= 0.016
		if pt.life <= 0.0:
			particles.remove_at(i)
			continue
		var a := maxf(0.0, pt.life / pt.max_life)
		c.draw_rect(Rect2(pt.x - pt.size / 2.0, pt.y - pt.size / 2.0, pt.size, pt.size), Color(pt.color, a))

	# 10. HUD on-screen elements
	_text("%s // %s" % [data.name, data.phase], 24, 32, UI.orbitron(600), 13, UI.CYAN)
	_text(data.subtitle, 24, 50, UI.mono(), 12, UI.TEXT_MUTED)
	var status_text := "STATUS: RECORDING TRAJECTORY"
	var status_color := UI.CYAN
	if shadow.active:
		if shadow.is_reversed:
			status_text = "STATUS: SHADOW TIME-REVERSED [<<]"
			status_color = UI.VIOLET
		else:
			status_text = "STATUS: SHADOW REPLAYING [>>]"
			status_color = UI.ORANGE
	_text(status_text, 24, 70, UI.mono(), 12, status_color)

	# Red death flash overlay
	if player.is_dead:
		c.draw_rect(Rect2(0, 0, CANVAS_W, CANVAS_H), Color(1, 30 / 255.0, 60 / 255.0, maxf(0.0, death_transition) * 0.7))
		_text("SIGNAL SEVERED // SEQUENCE TERMINATED", CANVAS_W / 2.0, CANVAS_H / 2.0, UI.orbitron(800), 24, Color.WHITE, 1)
		_text("VOID INTEGRITY FAILURE. REBOOTING RECORD...", CANVAS_W / 2.0, CANVAS_H / 2.0 + 30, UI.mono(), 14, Color.WHITE, 1)


## "EXTRACTION PORTAL" under the portal, kept readable: it drops below the
## floor's neon edge instead of sitting on it, and splits onto two lines
## when one line would run off the side of the screen.
func _draw_portal_label() -> void:
	var font := UI.orbitron(600)
	var label := "EXTRACTION PORTAL"
	var baseline := exit_pos.y + 46.0
	for b in solids:
		var top := b.position.y
		if exit_pos.x >= b.position.x and exit_pos.x <= b.end.x and top > exit_pos.y \
				and baseline > top - 2.0 and baseline - 10.0 < top + 3.0:
			baseline = top + 15.0
	var half_w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x / 2.0
	if exit_pos.x - half_w < 8.0 or exit_pos.x + half_w > CANVAS_W - 8.0:
		_text("EXTRACTION", exit_pos.x, baseline, font, 11, UI.CYAN, 1)
		_text("PORTAL", exit_pos.x, baseline + 14.0, font, 11, UI.CYAN, 1)
	else:
		_text(label, exit_pos.x, baseline, font, 11, UI.CYAN, 1)


## Canvas setLineDash circle: dashes laid along the arc starting at `rot`.
func _dashed_circle(center: Vector2, radius: float, dash: float, gap: float, rot: float, color: Color, width: float) -> void:
	var a := 0.0
	while a < TAU - 0.0001:
		var end := minf(a + dash / radius, TAU)
		_canvas.draw_arc(center, radius, rot + a, rot + end, 6, color, width)
		a += (dash + gap) / radius


func _draw_menu(time: float) -> void:
	var c := _canvas
	c.draw_rect(Rect2(0, 0, CANVAS_W, CANVAS_H), Color("#03070d"))
	for x in range(0, int(CANVAS_W), 40):
		c.draw_line(Vector2(x, 0), Vector2(x, CANVAS_H), Color(0, 240 / 255.0, 1, 0.05), 1.0)

	_text("SHADOW.exe", CANVAS_W / 2.0, 120, UI.orbitron(900), 48, UI.CYAN, 1, 18.0)
	_text("\"Your shadow remembers everything you regret.\"", CANVAS_W / 2.0, 155, UI.mono(), 16, UI.ORANGE, 1)
	_text("HACKATHON THEME REQUIREMENT: REVERSAL PROTOCOL", CANVAS_W / 2.0, 180, UI.mono(), 13, Color(UI.CYAN, 0.7), 1)

	var card_y := 220.0
	# Three 240px cards with 20px gaps, centred (the web build overlapped the first two).
	_draw_card(CANVAS_W / 2.0 - 380, card_y, 240, 150, UI.CYAN, "CYBER PROJECTION", "PLAYER", 0, time)
	_draw_card(CANVAS_W / 2.0 - 120, card_y, 240, 150, UI.ORANGE, "PAST RECORDING", "ECHO CLONE", 1, time)
	_draw_card(CANVAS_W / 2.0 + 140, card_y, 240, 150, UI.VIOLET, "REVERSED SIGNAL", "SHADOW FLIP", 2, time)

	_text("PRESS [SPACE] OR CLICK BELOW TO INITIALIZE", CANVAS_W / 2.0, 430, UI.orbitron(600), 18, Color.WHITE, 1)
	_draw_menu_button(CANVAS_W / 2.0 - 160, 460, 320, 44, "▶ START CAMPAIGN (LEVEL 1)", UI.CYAN)
	_draw_menu_button(CANVAS_W / 2.0 - 160, 515, 320, 38, "📖 TUTORIAL PROTOCOL", UI.ORANGE)
	_draw_menu_button(CANVAS_W / 2.0 - 160, 565, 320, 38, "⚡ STORY ARCHIVES & MANUAL", UI.TEXT_MUTED)


func _draw_card(x: float, y: float, w: float, h: float, color: Color, tag: String, title: String, row: int, time: float) -> void:
	_canvas.draw_rect(Rect2(x, y, w, h), UI.MODAL_BG)
	_canvas.draw_rect(Rect2(x, y, w, h), color, false, 1.5)
	# Player and echo spin forward; the reversed shadow spins backward.
	var ang: float = [time * CUBIT_IDLE_SPIN, time * CUBIT_IDLE_SPIN, -time * CUBIT_IDLE_SPIN][row]
	var fill: Color = [CUBIT_FILL, ECHO_FILL, REVERSED_FILL][row]
	_draw_cubit(Vector2(x + w / 2.0, y + 40), ang, 1.0, 2.0, color, fill, time)
	_text(tag, x + w / 2.0, y + 105, UI.mono(), 10, color, 1)
	_text(title, x + w / 2.0, y + 124, UI.orbitron(800), 12, Color.WHITE, 1)


func _draw_menu_button(x: float, y: float, w: float, h: float, label: String, color: Color) -> void:
	_canvas.draw_rect(Rect2(x, y, w, h), Color(0, 240 / 255.0, 1, 0.08))
	_canvas.draw_rect(Rect2(x, y, w, h), color, false, 1.5)
	_text(label, x + w / 2.0, y + h / 2.0 + 5, UI.orbitron(800), 13, color, 1)


func _draw_victory() -> void:
	_canvas.draw_rect(Rect2(0, 0, CANVAS_W, CANVAS_H), Color("#020509"))
	_text("SYSTEM ESCAPE COMPLETE", CANVAS_W / 2.0, 150, UI.orbitron(900), 42, UI.CYAN, 1, 20.0)
	_text("IDENTITY VERIFIED: YOU ARE THE ECHO.", CANVAS_W / 2.0, 220, UI.orbitron(800), 22, UI.ORANGE, 1)
	var lines := ["The red shadow was the original entity, preserved after system reset.",
		"You were only the projected echo sent forward.",
		"By reversing time and cooperating with your past self,",
		"the recursive containment cycle has shattered."]
	for i in lines.size():
		_text(lines[i], CANVAS_W / 2.0, 280 + i * 30, UI.mono(), 16, UI.TEXT, 1)
	_draw_menu_button(CANVAS_W / 2.0 - 140, 460, 280, 48, "RETURN TO TITLE MENU", UI.CYAN)


# ═══════════════════════════════ INPUT ═══════════════════════════════

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var code: Key = event.physical_keycode
	if event.pressed:
		if _modal.is_open():
			return
		if game_state == State.MENU:
			if code == KEY_SPACE or code == KEY_ENTER:
				game_state = State.PLAYING
				load_level(1, true)
			return
		if game_state == State.VICTORY:
			if code in [KEY_SPACE, KEY_ENTER, KEY_ESCAPE]:
				game_state = State.MENU
			return
		match code:
			KEY_A, KEY_LEFT: keys.left = true
			KEY_D, KEY_RIGHT: keys.right = true
			KEY_W, KEY_UP: keys.jump = true
			KEY_SPACE: keys.deploy = true
			KEY_F, KEY_Q: keys.flip = true
			KEY_E: keys.interact = true
			KEY_R: restart_level()
			KEY_ESCAPE: game_state = State.MENU
	else:
		match code:
			KEY_A, KEY_LEFT: keys.left = false
			KEY_D, KEY_RIGHT: keys.right = false
			KEY_W, KEY_UP:
				keys.jump = false
				if not player.is_empty() and player.vy < -160.0:
					player.vy *= 0.55
			KEY_SPACE: keys.deploy = false
			KEY_F, KEY_Q: keys.flip = false
			KEY_E: keys.interact = false


func _on_canvas_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var p: Vector2 = event.position
	var in_x := p.x >= CANVAS_W / 2.0 - 160 and p.x <= CANVAS_W / 2.0 + 160
	if game_state == State.MENU:
		if in_x and p.y >= 460 and p.y <= 504:
			game_state = State.PLAYING
			load_level(1, true)
		elif in_x and p.y >= 515 and p.y <= 553:
			game_state = State.PLAYING
			load_level(0, false)
		elif in_x and p.y >= 565 and p.y <= 603:
			_modal.open(MANUAL_TITLE, MANUAL_TEXT)
	elif game_state == State.VICTORY:
		if p.x >= CANVAS_W / 2.0 - 140 and p.x <= CANVAS_W / 2.0 + 140 and p.y >= 460 and p.y <= 508:
			game_state = State.MENU


func _on_nav_menu() -> void:
	game_state = State.MENU


func _on_nav_tutorial() -> void:
	game_state = State.PLAYING
	load_level(0)


func _on_nav_restart() -> void:
	restart_level()


func _on_nav_sound() -> void:
	_sound_btn.text = "SOUND: ON" if _audio.toggle_mute() else "SOUND: OFF"


func _on_nav_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
