extends Control
## Main menu script for SHADOW.exe title screen.
## Layout and styling mirror the web build's drawMenu().

const UI := preload("res://scripts/ui_style.gd")
const TerminalModal := preload("res://scripts/terminal_modal.gd")
# Individual 64x64 animation frames (the combined spritesheet is misaligned).
const FRAME_SETS := ["player", "ghost", "ghost_reverse"]

const W := 960.0
const CARD_Y := 220.0
const CARD_W := 240.0
const CARD_H := 150.0
const CARD_GAP := 20.0

const MANUAL_TITLE := "SHADOW.exe MANUAL // REVERSAL PROTOCOL"
const MANUAL_TEXT := "MISSION DIRECTIVE:\n" \
	+ "1. [W] or [UP] to JUMP. Space is strictly for Shadow clone deployment.\n" \
	+ "2. Walk across pressure plates to open security blast doors.\n" \
	+ "3. Press [SPACE] to deploy your Shadow clone, which replays your past steps.\n" \
	+ "4. Press [F] for SHADOW FLIP: time-reverses the clone's trajectory, sending it backward to unlock the second airlock door!\n" \
	+ "5. Reaching the Extraction Portal triggers sector advance."

# [color, tag, title, spritesheet row]
const CARDS := [
	[UI.CYAN, "CYBER PROJECTION", "PLAYER", 0],
	[UI.ORANGE, "PAST RECORDING", "ECHO CLONE", 1],
	[UI.VIOLET, "REVERSED SIGNAL", "SHADOW FLIP", 2],
]

var _time: float = 0.0
var _title: Label
var _modal: Control
var _frames: Array = []  # [row][frame] -> Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for set_name in FRAME_SETS:
		var row: Array[Texture2D] = []
		for f in 8:
			row.append(load("res://assets/art/%s_%d.png" % [set_name, f]))
		_frames.append(row)

	_title = _centered_label("SHADOW.exe", UI.orbitron(900), 48, UI.CYAN, 120)
	UI.glow(_title, UI.CYAN, 10)
	_centered_label("\"Your shadow remembers everything you regret.\"", UI.mono(), 16, UI.ORANGE, 155)
	_centered_label("HACKATHON THEME REQUIREMENT: REVERSAL PROTOCOL", UI.mono(), 13, Color(UI.CYAN, 0.7), 180)

	for i in CARDS.size():
		var c: Array = CARDS[i]
		var x := _card_x(i)
		_label_at(c[1], UI.mono(), 10, c[0], x, CARD_Y + 105, CARD_W)
		_label_at(c[2], UI.orbitron(700), 12, Color.WHITE, x, CARD_Y + 124, CARD_W)

	_centered_label("PRESS [SPACE] OR CLICK BELOW TO INITIALIZE", UI.orbitron(600), 18, Color.WHITE, 430)

	_add_button("▶ START CAMPAIGN (PHASE 1)", UI.CYAN, 460, 44, _on_start_pressed)
	_add_button("📖 TUTORIAL PROTOCOL", UI.ORANGE, 515, 38, _on_tutorial_pressed)
	_add_button("⚡ STORY ARCHIVES & MANUAL", UI.TEXT_MUTED, 565, 38, _on_manual_pressed)

	# Extras the web build doesn't have: top-down archive and quit.
	var extras := HBoxContainer.new()
	extras.add_theme_constant_override("separation", 8)
	add_child(extras)
	for spec in [["ARCHIVE: TOP-DOWN", _on_topdown_pressed], ["QUIT", _on_quit_pressed]]:
		var b := Button.new()
		b.text = spec[0]
		UI.style_nav_button(b)
		b.pressed.connect(spec[1])
		b.mouse_entered.connect(func(): AudioManager.play_move())
		extras.add_child(b)
	extras.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)

	_modal = TerminalModal.new()
	add_child(_modal)

	# Glitch text-shadow on the title (web .glitch-title, 3s alternate).
	var glitch := create_tween().set_loops()
	glitch.tween_callback(_set_title_shadow.bind(Color(UI.CYAN, 0.22), 0)).set_delay(0.0)
	glitch.tween_callback(_set_title_shadow.bind(Color("#ff0055"), -3)).set_delay(0.6)
	glitch.tween_callback(_set_title_shadow.bind(Color("#00ffff"), 3)).set_delay(0.6)
	glitch.tween_callback(_set_title_shadow.bind(Color(UI.CYAN, 0.28), 0)).set_delay(0.6)
	glitch.tween_interval(1.2)

	# Subtle fade-in
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			get_viewport().set_input_as_handled()
			_on_start_pressed()


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, 640), UI.BG)
	for x in range(0, int(W), 40):
		draw_line(Vector2(x, 0), Vector2(x, 640), Color(UI.CYAN, 0.05), 1.0)

	var frame := int(_time * 6.0) % 8
	for i in CARDS.size():
		var c: Array = CARDS[i]
		var rect := Rect2(_card_x(i), CARD_Y, CARD_W, CARD_H)
		draw_rect(rect, UI.MODAL_BG)
		draw_rect(rect, c[0], false, 1.5)
		var center := Vector2(rect.position.x + CARD_W / 2.0, CARD_Y + 55)
		# Soft colored aura behind the sprite (stands in for canvas shadowBlur).
		for r in [30.0, 22.0, 15.0]:
			draw_circle(center, r, Color(c[0], 0.07))
		draw_texture_rect(_frames[c[3]][frame], Rect2(center - Vector2(32, 32), Vector2(64, 64)), false)


func _card_x(i: int) -> float:
	var total := CARD_W * 3 + CARD_GAP * 2
	return (W - total) / 2.0 + i * (CARD_W + CARD_GAP)


func _set_title_shadow(color: Color, offset_x: int) -> void:
	_title.add_theme_color_override("font_shadow_color", color)
	_title.add_theme_constant_override("shadow_offset_x", offset_x)
	_title.add_theme_constant_override("shadow_outline_size", 10 if offset_x == 0 else 0)


## Places a full-width centered label so its baseline sits near `baseline_y`
## (same coordinates as the web canvas fillText calls).
func _centered_label(text: String, font: Font, size: int, color: Color, baseline_y: float) -> Label:
	return _label_at(text, font, size, color, 0, baseline_y, W)


func _label_at(text: String, font: Font, size: int, color: Color, x: float, baseline_y: float, width: float) -> Label:
	var l := UI.label(text, font, size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(x, baseline_y - font.get_ascent(size))
	l.size = Vector2(width, 0)
	add_child(l)
	return l


func _add_button(text: String, color: Color, y: float, h: float, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.position = Vector2(W / 2.0 - 160, y)
	b.size = Vector2(320, h)
	UI.style_menu_button(b, color)
	b.pressed.connect(cb)
	b.mouse_entered.connect(func(): AudioManager.play_move())
	add_child(b)


func _on_start_pressed() -> void:
	AudioManager.play_shadow_deploy()
	GameData.load_level(0)


func _on_tutorial_pressed() -> void:
	AudioManager.play_move()
	get_tree().change_scene_to_file("res://scenes/sidescroll/TutorialLevel.tscn")


func _on_manual_pressed() -> void:
	AudioManager.play_plate_activate()
	_modal.open(MANUAL_TITLE, MANUAL_TEXT)


func _on_topdown_pressed() -> void:
	AudioManager.play_shadow_flip()
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
