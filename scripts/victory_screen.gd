extends Control
## Victory screen shown after completing all levels in SHADOW.exe.
## Layout mirrors the web build's drawVictory().

const UI := preload("res://scripts/ui_style.gd")

const LORE := [
	"The red shadow was the original entity, preserved after system reset.",
	"You were only the projected echo sent forward.",
	"By reversing time and cooperating with your past self,",
	"the recursive containment cycle has shattered.",
]


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#020509")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := _centered("SYSTEM ESCAPE COMPLETE", UI.orbitron(900), 42, UI.CYAN, 150)
	UI.glow(title, UI.CYAN, 10)
	_centered("IDENTITY VERIFIED: YOU ARE THE ECHO.", UI.orbitron(700), 22, UI.ORANGE, 220)
	for i in LORE.size():
		_centered(LORE[i], UI.mono(), 16, UI.TEXT, 280 + i * 30)

	var b := Button.new()
	b.text = "RETURN TO TITLE MENU"
	b.position = Vector2(480 - 140, 460)
	b.size = Vector2(280, 48)
	UI.style_menu_button(b, UI.CYAN)
	b.pressed.connect(_on_return_pressed)
	add_child(b)

	# Fade-in effect
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
			get_viewport().set_input_as_handled()
			_on_return_pressed()


func _centered(text: String, font: Font, size: int, color: Color, baseline_y: float) -> Label:
	var l := UI.label(text, font, size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, baseline_y - font.get_ascent(size))
	l.size = Vector2(960, 0)
	add_child(l)
	return l


func _on_return_pressed() -> void:
	GameData.go_to_title()
