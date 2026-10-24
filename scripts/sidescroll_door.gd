## Platformer laser blast door for SHADOW.exe side-scroll demo.
extends StaticBody2D

const WebWorld := preload("res://scripts/web_world.gd")
const UI := preload("res://scripts/ui_style.gd")

@export var door_height: float = 100.0
@export var door_width: float = 18.0

var is_open: bool = false
@onready var col_shape: CollisionShape2D = $CollisionShape2D
var _time_alive: float = 0.0
## 0 = closed, 1 = fully retracted (animated like the web build).
var _open_amount: float = 0.0


func _ready() -> void:
	set_open(false)


func _process(delta: float) -> void:
	_time_alive += delta
	_open_amount = move_toward(_open_amount, 1.0 if is_open else 0.0, delta * 3.5)
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
	var h := door_height
	var w := door_width
	var top := -h * 0.5
	var housing := Color("#0a1626")

	# Door frame housings (top and bottom)
	for y in [top - 8.0, top + h]:
		var r := Rect2(-w * 0.5 - 4, y, w + 8, 8)
		draw_rect(r, housing)
		draw_rect(r, UI.CYAN, false, 1.0)

	# Barrier retracts upward as the door opens
	var cur_h := h * (1.0 - _open_amount)
	if cur_h > 2.0:
		draw_rect(Rect2(-w * 0.5, top, w, cur_h), Color("#06101c"))
		# Red forcefield beam with glow
		draw_line(Vector2(0, top), Vector2(0, top + cur_h), Color(UI.RED, 0.25), 9.0)
		draw_line(Vector2(0, top), Vector2(0, top + cur_h), UI.RED, 3.0)
		# Leading edge pulse
		draw_line(Vector2(-w * 0.5 + 2, top + cur_h), Vector2(w * 0.5 - 2, top + cur_h), Color.WHITE, 1.0)
