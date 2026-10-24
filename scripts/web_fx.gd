## Particle bursts and screen shake for side-scroll levels, matching the web
## build's particle pool and screenShake. Added to a level by WebWorld.setup_level().
## Find it from anywhere with: get_tree().get_first_node_in_group("web_fx")
extends Node2D

var _particles: Array[Dictionary] = []
var _shake: float = 0.0


func _ready() -> void:
	add_to_group("web_fx")
	z_index = 50
	process_mode = Node.PROCESS_MODE_PAUSABLE


## Emits `count` particles from `pos`. Radial = evenly spaced angles, else random.
func burst(pos: Vector2, color: Color, count: int, speed_min: float, speed_max: float, size: float, life: float, radial: bool = false) -> void:
	for i in count:
		var angle := TAU * i / count if radial else randf() * TAU
		var spd := randf_range(speed_min, speed_max)
		add(pos, Vector2(cos(angle), sin(angle)) * spd, color, size, life)


func add(pos: Vector2, vel: Vector2, color: Color, size: float, life: float) -> void:
	_particles.append({"pos": pos, "vel": vel, "color": color, "size": size, "life": life, "max": life})


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _process(delta: float) -> void:
	for i in range(_particles.size() - 1, -1, -1):
		var p := _particles[i]
		p.pos += p.vel * delta
		p.life -= delta
		if p.life <= 0.0:
			_particles.remove_at(i)

	# Shake the view (not the nodes) so recorded positions stay exact.
	var offset := Vector2.ZERO
	if _shake > 0.0:
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
		_shake = maxf(0.0, _shake - delta * 25.0)
	get_viewport().canvas_transform = Transform2D(0.0, offset)
	queue_redraw()


func _exit_tree() -> void:
	get_viewport().canvas_transform = Transform2D.IDENTITY


func _draw() -> void:
	for p in _particles:
		var a := clampf(p.life / p.max, 0.0, 1.0)
		var s: float = p.size
		draw_rect(Rect2(p.pos - Vector2(s, s) / 2.0, Vector2(s, s)), Color(p.color, a))
