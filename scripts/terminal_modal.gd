## Archive terminal modal, matching the web build's #modal-overlay.
## Call open(title, text); closes on the button, SPACE, ENTER or ESC.
extends Control

signal closed

const UI := preload("res://scripts/ui_style.gd")

## When true, the scene tree is paused while the modal is open.
var pause_tree: bool = false

var _title: Label
var _body: Label
var _btn: Button
var _open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(1 / 255.0, 4 / 255.0, 8 / 255.0, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 0)
	panel.add_theme_stylebox_override("panel", UI.modal_panel())
	center.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	panel.add_child(vb)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header.add_child(UI.label("⚡", UI.mono(), 20, UI.CYAN))
	_title = UI.label("ARCHIVE TERMINAL DATA", UI.orbitron(600), 16, UI.CYAN)
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(_title)
	vb.add_child(header)

	var rule_gap := Control.new()
	rule_gap.custom_minimum_size = Vector2(0, 8)
	vb.add_child(rule_gap)
	var rule := ColorRect.new()
	rule.color = Color(UI.CYAN, 0.25)
	rule.custom_minimum_size = Vector2(0, 1)
	vb.add_child(rule)
	var body_gap := Control.new()
	body_gap.custom_minimum_size = Vector2(0, 14)
	vb.add_child(body_gap)

	_body = UI.label("", UI.mono(), 14, UI.TEXT_BODY)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(532, 80)
	_body.add_theme_constant_override("line_spacing", 6)
	vb.add_child(_body)

	var btn_gap := Control.new()
	btn_gap.custom_minimum_size = Vector2(0, 20)
	vb.add_child(btn_gap)

	_btn = Button.new()
	_btn.text = "ACKNOWLEDGE [SPACE / ENTER]"
	_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	_btn.add_theme_font_override("font", UI.orbitron(800))
	_btn.add_theme_font_size_override("font_size", 13)
	_btn.add_theme_color_override("font_color", UI.CYAN)
	_btn.add_theme_color_override("font_hover_color", UI.BG)
	_btn.add_theme_color_override("font_pressed_color", UI.BG)
	var normal := UI.box(Color(UI.CYAN, 0.15), UI.CYAN, 1, 3)
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = UI.CYAN
	hover.shadow_color = Color(UI.CYAN, 0.8)
	hover.shadow_size = 10
	_btn.add_theme_stylebox_override("normal", normal)
	_btn.add_theme_stylebox_override("hover", hover)
	_btn.add_theme_stylebox_override("pressed", hover)
	_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_btn.focus_mode = Control.FOCUS_NONE
	_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn.pressed.connect(close)
	vb.add_child(_btn)


func is_open() -> bool:
	return _open


func open(title: String, text: String, button_text: String = "ACKNOWLEDGE [SPACE / ENTER]") -> void:
	_title.text = title
	_body.text = text
	if _btn:
		_btn.text = button_text
	_open = true
	visible = true
	if pause_tree:
		get_tree().paused = true


func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	closed.emit()
	if pause_tree:
		# Unpause a frame later so the closing key press doesn't also
		# reach gameplay (e.g. SPACE deploying the shadow).
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().paused = false


func _input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var code: Key = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		if code in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE] or event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
			get_viewport().set_input_as_handled()
			close()
