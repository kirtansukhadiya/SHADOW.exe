## Platformer laser blast door for SHADOW.exe side-scroll demo.
extends StaticBody2D

@export var door_height: float = 100.0
@export var door_width: float = 18.0

var is_open: bool = false
@onready var col_shape: CollisionShape2D = $CollisionShape2D
var _time_alive: float = 0.0


func _ready() -> void:
	set_open(false)


func _process(delta: float) -> void:
	_time_alive += delta
	queue_redraw()


func set_open(open_state: bool) -> void:
	if is_open == open_state:
		return
	is_open = open_state
	if col_shape:
		col_shape.set_deferred("disabled", is_open)
	if is_open:
		AudioManager.play_door_open()
	queue_redraw()


func _draw() -> void:
	var t := _time_alive
	var h := door_height
	var w := door_width

	if is_open:
		# Open green/cyan frame
		draw_rect(Rect2(-w * 0.5, -h * 0.5, w, h), Color(0.0, 1.0, 0.6, 0.25), false, 1.5)
	else:
		# Closed red security laser forcefield
		draw_rect(Rect2(-w * 0.5, -h * 0.5, w, h), Color(0.9, 0.1, 0.2, 0.7), true)
		draw_rect(Rect2(-w * 0.5, -h * 0.5, w, h), Color(1.0, 0.3, 0.4, 0.95), false, 2.0)
		# Animated laser beams
		var num_beams := maxi(int(h / 18.0), 3)
		for i in range(num_beams):
			var y_pos := -h * 0.5 + float(i) * 18.0 + 9.0 + sin(t * 12.0 + float(i)) * 2.0
			draw_line(Vector2(-w * 0.5, y_pos), Vector2(w * 0.5, y_pos), Color(1.0, 0.9, 0.9, 0.9), 1.5)
