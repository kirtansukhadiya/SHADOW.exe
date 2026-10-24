## Shared cyber UI styling for SHADOW.exe, mirroring the web build (index.html).
## Use via: const UI := preload("res://scripts/ui_style.gd")
extends RefCounted

const CYAN := Color("#00f0ff")
const CYAN_DIM := Color("#00a0b0")
const ORANGE := Color("#ff7700")
const VIOLET := Color("#d000ff")
const RED := Color("#ff3344")
const BG := Color("#03070d")
const PANEL_BG := Color(6 / 255.0, 14 / 255.0, 25 / 255.0, 0.92)
const MODAL_BG := Color("#06111f")
const BORDER := Color(0.0, 240 / 255.0, 1.0, 0.35)
const TEXT := Color("#e0f4ff")
const TEXT_BODY := Color("#c9e8fb")
const TEXT_MUTED := Color("#8bb3cb")
const TEXT_HINT := Color("#c0dff8")

const _ORBITRON := preload("res://assets/fonts/Orbitron.ttf")
const _MONO := preload("res://assets/fonts/ShareTechMono-Regular.ttf")

static var _orbitron_cache: Dictionary = {}


## Orbitron at the given weight (600 / 700 / 800 / 900).
static func orbitron(weight: int = 600) -> Font:
	if not _orbitron_cache.has(weight):
		var fv := FontVariation.new()
		fv.base_font = _ORBITRON
		fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
		_orbitron_cache[weight] = fv
	return _orbitron_cache[weight]


static func mono() -> Font:
	return _MONO


static var _mono_spaced: FontVariation

## Share Tech Mono with 1px letter-spacing (web #top-nav).
static func mono_spaced() -> Font:
	if _mono_spaced == null:
		_mono_spaced = FontVariation.new()
		_mono_spaced.base_font = _MONO
		_mono_spaced.spacing_glyph = 1
	return _mono_spaced


## Label with font, size and color applied.
static func label(text: String, font: Font, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Adds a soft neon glow to a label (approximates CSS text-shadow).
static func glow(l: Label, color: Color, strength: int = 8) -> void:
	l.add_theme_color_override("font_shadow_color", Color(color, 0.22))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 0)
	l.add_theme_constant_override("shadow_outline_size", strength)


static func box(bg: Color, border: Color, border_w: int = 1, radius: int = 3, glow_color: Color = Color.TRANSPARENT, glow_size: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	if glow_size > 0:
		sb.shadow_color = glow_color
		sb.shadow_size = glow_size
	return sb


## Web "modal-box" panel: dark navy, cyan border, cyan glow.
static func modal_panel() -> StyleBoxFlat:
	var sb := box(MODAL_BG, CYAN, 1, 4, Color(CYAN, 0.35), 18)
	sb.set_content_margin_all(24)
	return sb


## Styles a Button like the web's canvas menu buttons (outlined, tinted, fills on hover).
static func style_menu_button(b: Button, color: Color, font_size: int = 13) -> void:
	b.add_theme_font_override("font", orbitron(700))
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", color)
	b.add_theme_color_override("font_focus_color", color)
	b.add_theme_color_override("font_hover_color", BG)
	b.add_theme_color_override("font_pressed_color", BG)
	var normal := box(Color(CYAN, 0.08), color, 2, 0)
	var hover := box(color, color, 2, 0, Color(color, 0.6), 10)
	var pressed := box(color.darkened(0.2), color, 2, 0)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


## Styles a Button like the web's small top-nav buttons.
static func style_nav_button(b: Button) -> void:
	b.add_theme_font_override("font", mono())
	b.add_theme_font_size_override("font_size", 12)
	b.add_theme_color_override("font_color", CYAN)
	b.add_theme_color_override("font_hover_color", CYAN)
	b.add_theme_color_override("font_focus_color", CYAN)
	var normal := box(Color(CYAN, 0.08), BORDER, 1, 3)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 4
	normal.content_margin_bottom = 4
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(CYAN, 0.25)
	hover.border_color = CYAN
	hover.shadow_color = Color(CYAN, 0.4)
	hover.shadow_size = 6
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


## Web ".key" keycap chip.
static func keycap(text: String) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := box(Color("#091a2d"), Color("#1f4f78"), 1, 3)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	sb.shadow_color = Color.BLACK
	sb.shadow_offset = Vector2(0, 2)
	sb.shadow_size = 1
	p.add_theme_stylebox_override("panel", sb)
	p.add_child(label(text, mono(), 11, CYAN))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p

