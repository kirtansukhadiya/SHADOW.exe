## Shared world rendering for side-scroll levels, mirroring the web build's
## LevelRunner.draw(): cyber grid background, hazard void glow and neon solids.
## Use via: const WebWorld := preload("res://scripts/web_world.gd")
extends RefCounted

const UI := preload("res://scripts/ui_style.gd")
const WebFX := preload("res://scripts/web_fx.gd")

const W := 960.0
const H := 640.0

static var _glow_tex: Texture2D


## Soft radial glow texture (white -> transparent), used to fake canvas shadowBlur.
static func glow_texture() -> Texture2D:
	if _glow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		t.width = 64
		t.height = 64
		_glow_tex = t
	return _glow_tex


static func draw_glow(ci: CanvasItem, center: Vector2, radius: float, color: Color) -> void:
	ci.draw_texture_rect(glow_texture(), Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, color)


## Call once from a level's _ready(): hides the scenes' old ColorRect visuals
## on plain StaticBody2D geometry (so draw_level can render them web-style)
## and adds the particle / screen-shake layer.
static func setup_level(level: Node2D) -> void:
	for body in _geometry_bodies(level):
		for child in body.get_children():
			if child is ColorRect:
				child.visible = false
	var fx := WebFX.new()
	level.add_child(fx)


static func draw_level(level: Node2D) -> void:
	# 1. Background + cyber grid
	level.draw_rect(Rect2(0, 0, W, H), UI.BG)
	var grid := Color(UI.CYAN, 0.04)
	for x in range(0, int(W), 40):
		level.draw_line(Vector2(x, 0), Vector2(x, H), grid, 1.0)
	for y in range(0, int(H), 40):
		level.draw_line(Vector2(0, y), Vector2(W, y), grid, 1.0)

	# Hazard void glow for pits
	level.draw_rect(Rect2(0, 590, W, 50), Color(1.0, 30 / 255.0, 60 / 255.0, 0.06))

	# 2. Solids
	for r in solid_rects(level):
		if r.position.y >= 540.0:
			r.end.y = H  # ground runs to the bottom edge, as in the web build
		level.draw_rect(r, _solid_color(r))
		level.draw_rect(r, UI.CYAN, false, 1.5)
		level.draw_line(r.position, Vector2(r.end.x, r.position.y), UI.CYAN, 2.5)


## Rects (in level space) of all static level geometry, excluding doors.
static func solid_rects(level: Node2D) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for body in _geometry_bodies(level):
		for child in body.get_children():
			var local_pts := PackedVector2Array()
			if child is CollisionShape2D and child.shape is RectangleShape2D:
				var half: Vector2 = child.shape.size / 2.0
				for c in [Vector2(-half.x, -half.y), Vector2(half.x, half.y)]:
					local_pts.append(child.position + c)
			elif child is CollisionPolygon2D:
				for p in child.polygon:
					local_pts.append(child.position + p)
			if local_pts.is_empty():
				continue
			var r := Rect2(level.to_local(body.to_global(local_pts[0])), Vector2.ZERO)
			for p in local_pts:
				r = r.expand(level.to_local(body.to_global(p)))
			out.append(r)
	return out


static func _geometry_bodies(level: Node2D) -> Array[StaticBody2D]:
	var out: Array[StaticBody2D] = []
	for child in level.get_children():
		# Doors are StaticBody2D too but carry their own script and drawing.
		if child is StaticBody2D and child.get_script() == null:
			out.append(child)
	return out


## Web palette: roofs, thin platforms, ground and pillars use different fills.
static func _solid_color(r: Rect2) -> Color:
	if r.position.y <= 0.5:
		return Color("#0d1829")
	if r.size.y <= 20.0:
		return Color("#101c2e")
	if r.position.y >= 550.0:
		return Color("#0a121e")
	return Color("#0c1626")
