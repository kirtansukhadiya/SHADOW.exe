extends CanvasLayer
## HUD controller for SHADOW.exe, styled after the web build:
## top-left sector readout, top-right key helper, bottom key legend,
## centered message toasts and the archive terminal modal.

const UI := preload("res://scripts/ui_style.gd")
const TerminalModal := preload("res://scripts/terminal_modal.gd")

var _level_name_label: Label
var _status_label: Label
var _message_panel: PanelContainer
var _message_label: Label
var _modal: Control
var _message_tween: Tween
var _death_overlay: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Top-left readout
	_level_name_label = UI.label("SECTOR 01 // THE ECHO", UI.orbitron(600), 13, UI.CYAN)
	UI.glow(_level_name_label, UI.CYAN, 2)
	_level_name_label.position = Vector2(24, 32 - UI.orbitron(600).get_ascent(13))
	root.add_child(_level_name_label)

	_status_label = UI.label("", UI.mono(), 12, UI.CYAN)
	_status_label.position = Vector2(24, 50 - UI.mono().get_ascent(12))
	_status_label.size = Vector2(560, 0)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status_label)

	root.add_child(_build_key_legend())

	# Centered message toast (modal-box look)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_bottom = -60
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	_message_panel = PanelContainer.new()
	var sb := UI.modal_panel()
	sb.bg_color = Color(UI.MODAL_BG, 0.94)
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	_message_panel.add_theme_stylebox_override("panel", sb)
	_message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_message_panel.modulate.a = 0.0
	center.add_child(_message_panel)
	_message_label = UI.label("SYSTEM READY", UI.orbitron(600), 16, UI.CYAN)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_constant_override("line_spacing", 6)
	_message_panel.add_child(_message_label)

	_death_overlay = _build_death_overlay()
	root.add_child(_death_overlay)

	_modal = TerminalModal.new()
	_modal.pause_tree = true
	root.add_child(_modal)


## Web #bottom-bar: keycap legend on the left, version tag on the right.
func _build_key_legend() -> Control:
	var bar := PanelContainer.new()
	var sb := UI.box(Color(5 / 255.0, 12 / 255.0, 20 / 255.0, 0.75), Color(UI.CYAN, 0.2), 1, 4)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	bar.add_theme_stylebox_override("panel", sb)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_left = 6
	bar.offset_right = -6
	bar.offset_top = -34
	bar.offset_bottom = -6

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	bar.add_child(row)

	var groups := [
		[["A", "D"], "Move", UI.TEXT_MUTED],
		[["W"], "Jump", UI.TEXT_MUTED],
		[["SPACE"], "Deploy Shadow", UI.TEXT_MUTED],
		[["F"], "Shadow Flip (REVERSE)", UI.ORANGE],
		[["E"], "Interact / Read", UI.TEXT_MUTED],
		[["R"], "Quick Reset", UI.TEXT_MUTED],
	]
	for g in groups:
		var group := HBoxContainer.new()
		group.add_theme_constant_override("separation", 5)
		for k in g[0]:
			var cap := UI.keycap(k)
			cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			group.add_child(cap)
		group.add_child(UI.label(g[1], UI.mono(), 11, g[2]))
		row.add_child(group)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	var tag := UI.label("CYBER ECHO REVERSAL SIMULATION // V2.0", UI.mono(), 11, UI.CYAN)
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(tag)
	return bar


func set_level_name(n: String) -> void:
	_level_name_label.text = n.to_upper().replace(" — ", " - ")


func set_shadow_status(status: String) -> void:
	_status_label.text = status
	# Web colour coding: violet = reversed, orange = replaying, cyan = recording.
	var color := UI.CYAN
	if "<<" in status or "REVERS" in status:
		color = UI.VIOLET
	elif ">>" in status or "DEPLOY" in status or "DISPATCH" in status:
		color = UI.ORANGE
	_status_label.add_theme_color_override("font_color", color)


func show_message(text: String, duration: float = 2.0) -> void:
	if _message_tween and _message_tween.is_valid():
		_message_tween.kill()

	_message_label.text = text
	_message_panel.pivot_offset = _message_panel.size / 2.0
	_message_panel.scale = Vector2(0.95, 0.95)

	_message_tween = create_tween()
	_message_tween.parallel().tween_property(_message_panel, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
	_message_tween.parallel().tween_property(_message_panel, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT)
	_message_tween.tween_interval(duration)
	_message_tween.tween_property(_message_panel, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)


## Opens the archive terminal modal (pauses gameplay until acknowledged).
func show_terminal(title: String, text: String) -> void:
	_modal.open(title, text)


## Web death flash: red wash with "SIGNAL SEVERED" text, fading out over `duration`.
func show_death(duration: float = 0.7) -> void:
	_death_overlay.visible = true
	_death_overlay.modulate.a = 1.0
	create_tween().tween_property(_death_overlay, "modulate:a", 0.0, duration)


func _build_death_overlay() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	var wash := ColorRect.new()
	wash.color = Color(1.0, 30 / 255.0, 60 / 255.0, 0.49)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(wash)
	for spec in [["SIGNAL SEVERED // SEQUENCE TERMINATED", UI.orbitron(800), 24, 320.0],
			["VOID INTEGRITY FAILURE. REBOOTING RECORD...", UI.mono(), 14, 350.0]]:
		var l := UI.label(spec[0], spec[1], spec[2], Color.WHITE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(0, spec[3] - (spec[1] as Font).get_ascent(spec[2]))
		l.size = Vector2(960, 0)
		overlay.add_child(l)
	return overlay
