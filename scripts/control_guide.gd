## Start-of-game control guide for SHADOW.exe: keycap controls on the left,
## the record / deploy / reverse loop (with live Cubits) on the right.
## Call open(); closes on the button, SPACE, ENTER or ESC.
extends Control

signal closed

const UI := preload("res://scripts/ui_style.gd")

## func(ci: CanvasItem, offset: Vector2, pos: Vector2, ang: float, facing: float,
##      s: float, outline: Color, fill: Color, t: float) - set by the game.
var cubit_drawer: Callable

const CONTROLS := [
	[["A", "D"], "Move", false],
	[["W"], "Jump", false],
	[["SPACE"], "Deploy your echo", false],
	[["F"], "Reverse your echo", true],
	[["E"], "Read a terminal", false],
	[["R"], "Restart the sector", false],
	[["ESC"], "Back to the title", false],
]

# [title, key, text, colour, fill, spin direction]
const STEPS := [
	["RECORD", "", "From the moment a sector starts, every move you make is recorded.", "#00f0ff", "#0d1f38", 1.0],
	["DEPLOY", "SPACE", "Your orange echo replays your path from the start and holds plates down.", "#ff7700", "#24140a", 1.0],
	["REVERSE", "F", "The echo turns violet and walks your path backwards. Every sector needs it.", "#d000ff", "#1c0a2a", -1.0],
]

var _open: bool = false
var _time: float = 0.0
var _btn: Button
var _icons: Array[Control] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(1 / 255.0, 4 / 255.0, 8 / 255.0, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 0)
	var sb := UI.modal_panel()
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header.add_child(UI.label("⚡", UI.mono(), 20, UI.CYAN))
	var title := UI.label("PROTOCOL BRIEFING", UI.orbitron(800), 18, UI.CYAN)
	UI.glow(title, UI.CYAN, 6)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(_badge("THEME: REVERSE", UI.ORANGE))
	vb.add_child(header)

	var intro := UI.label("You are a Cubit. Everything you do is recorded, and your echo can replay it forwards or backwards. Use both to open the blast doors.", UI.mono(), 13, UI.TEXT_BODY)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(732, 0)
	vb.add_child(intro)
	vb.add_child(_rule())

	# Two columns
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 32)
	vb.add_child(cols)

	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 8)
	left.custom_minimum_size = Vector2(290, 0)
	cols.add_child(left)
	left.add_child(_heading("CONTROLS"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 8)
	left.add_child(grid)
	for row in CONTROLS:
		var keys := HBoxContainer.new()
		keys.add_theme_constant_override("separation", 4)
		keys.custom_minimum_size = Vector2(76, 0)
		for k in row[0]:
			keys.add_child(UI.keycap(k))
		grid.add_child(keys)
		var desc := UI.label(row[1], UI.mono(), 13, UI.VIOLET if row[2] else UI.TEXT_BODY)
		desc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		desc.size_flags_vertical = Control.SIZE_FILL
		grid.add_child(desc)
	var arrows := UI.label("Arrow keys also move and jump.", UI.mono(), 11, UI.TEXT_MUTED)
	left.add_child(arrows)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(right)
	right.add_child(_heading("HOW IT WORKS"))
	for i in STEPS.size():
		right.add_child(_step_row(i))

	vb.add_child(_rule())

	# Footer
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	var goal := UI.label("Goal: reach the Extraction Portal. Stuck? Press [R] to restart.", UI.mono(), 12, UI.TEXT_MUTED)
	goal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(goal)
	_btn = _button("START [SPACE / ENTER]")
	_btn.pressed.connect(close)
	footer.add_child(_btn)
	vb.add_child(footer)


func is_open() -> bool:
	return _open


func open(button_text: String = "START [SPACE / ENTER]") -> void:
	_btn.text = button_text
	_open = true
	visible = true


func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	closed.emit()


func _process(delta: float) -> void:
	if not _open:
		return
	_time += delta
	for icon in _icons:
		icon.queue_redraw()


func _input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var code: Key = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		if code in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
			get_viewport().set_input_as_handled()
			close()


# ── Building blocks ──────────────────────────────────────────────────────────

func _step_row(i: int) -> Control:
	var step: Array = STEPS[i]
	var color := Color(step[3])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)

	var icon := Control.new()
	icon.custom_minimum_size = Vector2(60, 60)
	icon.draw.connect(_draw_icon.bind(icon, i))
	row.add_child(icon)
	_icons.append(icon)

	var text := VBoxContainer.new()
	text.add_theme_constant_override("separation", 2)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	title_row.add_child(UI.label("%d  %s" % [i + 1, step[0]], UI.orbitron(800), 13, color))
	if step[1] != "":
		var cap := UI.keycap(step[1])
		cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		title_row.add_child(cap)
	text.add_child(title_row)
	var desc := UI.label(step[2], UI.mono(), 12, UI.TEXT_BODY)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(320, 0)
	text.add_child(desc)
	row.add_child(text)
	return row


func _draw_icon(icon: Control, i: int) -> void:
	var step: Array = STEPS[i]
	var color := Color(step[3])
	var sb := UI.box(Color(color, 0.06), Color(color, 0.5), 1, 3)
	icon.draw_style_box(sb, Rect2(Vector2.ZERO, icon.size))
	if cubit_drawer.is_valid():
		var s := 1.4
		cubit_drawer.call(icon, Vector2.ZERO, icon.size / 2.0 - Vector2(0, 6.0 * s), _time * 2.0 * step[5],
			step[5], s, color, Color(step[4]), _time)


func _heading(text: String) -> Label:
	var l := UI.label(text, UI.mono_spaced(), 11, UI.CYAN_DIM)
	return l


func _rule() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(UI.CYAN, 0.2)
	r.custom_minimum_size = Vector2(0, 1)
	return r


func _badge(text: String, color: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := UI.box(Color(color, 0.15), color, 1, 3)
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	p.add_theme_stylebox_override("panel", sb)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.add_child(UI.label(text, UI.mono_spaced(), 11, color))
	return p


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", UI.orbitron(800))
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", UI.CYAN)
	b.add_theme_color_override("font_hover_color", UI.BG)
	b.add_theme_color_override("font_pressed_color", UI.BG)
	var normal := UI.box(Color(UI.CYAN, 0.15), UI.CYAN, 1, 3)
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = UI.CYAN
	hover.shadow_color = Color(UI.CYAN, 0.8)
	hover.shadow_size = 10
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b
