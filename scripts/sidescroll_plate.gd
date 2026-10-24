## Platformer pressure plate for SHADOW.exe side-scroll levels.
## Activates linked doors when pressed by player or shadow.
## Includes a generous release buffer timer so doors remain accessible.
extends Area2D

@export var linked_door_path: NodePath
@export var linked_door_2_path: NodePath
@export var release_delay: float = 0.5

var is_pressed: bool = false
var _occupants: int = 0
var _shadow_present: bool = false
var _release_timer: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()


func _process(delta: float) -> void:
	var occupied := (_occupants > 0) or _shadow_present
	if occupied:
		_release_timer = release_delay
		if not is_pressed:
			_set_pressed(true)
	else:
		if _release_timer > 0.0:
			_release_timer -= delta
			queue_redraw()
			if _release_timer <= 0.0 and is_pressed:
				_set_pressed(false)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_occupants += 1


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_occupants = maxi(_occupants - 1, 0)


func set_shadow_present(present: bool) -> void:
	_shadow_present = present


func _set_pressed(pressed: bool) -> void:
	is_pressed = pressed
	AudioManager.play_plate_activate()
	queue_redraw()
	if linked_door_path != NodePath(""):
		var door: Node = get_node_or_null(linked_door_path)
		if door and door.has_method("set_open"):
			door.set_open(is_pressed)
	if linked_door_2_path != NodePath(""):
		var door2: Node = get_node_or_null(linked_door_2_path)
		if door2 and door2.has_method("set_open"):
			door2.set_open(is_pressed)


func _draw() -> void:
	var col := Color(0.0, 1.0, 0.45, 0.9) if is_pressed else Color(0.0, 0.9, 1.0, 0.6)
	draw_rect(Rect2(-24, -4, 48, 8), Color(0.05, 0.1, 0.2, 0.9), true)
	draw_rect(Rect2(-24, -4, 48, 8), col, false, 2.0)
	if is_pressed:
		var fill_ratio: float = clampf(_release_timer / release_delay, 0.0, 1.0) if (_occupants == 0 and not _shadow_present) else 1.0
		var w := 40.0 * fill_ratio
		draw_rect(Rect2(-w * 0.5, -2, w, 4), col, true)
