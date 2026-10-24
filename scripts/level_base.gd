## Base class for every level in SHADOW.exe.
## Manages the wall grid, signal wiring between player / shadow / plates / exit,
## evaluates weight-based pressure plates, handles Shadow Flip, and draws the neon grid.
extends Node2D

## Display name shown on the HUD.
@export var level_name: String = "LEVEL"

## Optional subtitle.
@export var level_subtitle: String = ""

## Tile size in pixels.
const TILE_SIZE: int = 64

## Number of columns in the grid (960 / 64).
var grid_width: int = 15

## Number of rows in the grid (640 / 64).
var grid_height: int = 10

## Set of cells that count as impassable walls.
var wall_cells: Array[Vector2i] = []

## Cached node references.
var _player: Node2D = null
var _shadow: Node2D = null
var _exit: Node2D = null
var _plates: Array[Node2D] = []
var _doors: Array[Node2D] = []
var _hud: Node = null

## Screen flash duration for Shadow Flip.
var _flash_timer: float = 0.0


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	setup_walls()

	# Locate child nodes.
	_player = _find_child_by_script("player")
	_shadow = _find_child_by_script("shadow")
	_exit = _find_child_by_script("exit_zone")
	_hud = _find_child_by_script("hud")

	for child in get_children():
		var s: Script = child.get_script() as Script
		if s == null:
			continue
		var path: String = s.resource_path
		if path.ends_with("pressure_plate.gd"):
			_plates.append(child)
		elif path.ends_with("door.gd"):
			_doors.append(child)

	# Wire signals.
	if _player:
		if _player.has_signal("moved"):
			_player.moved.connect(_on_player_moved)
		if _player.has_signal("recording_complete"):
			_player.recording_complete.connect(_on_recording_complete)
		if _player.has_signal("flip_requested"):
			_player.flip_requested.connect(_on_flip_requested)

	if _shadow:
		if _shadow.has_signal("stepped_on"):
			_shadow.stepped_on.connect(_on_shadow_stepped)
		if _shadow.has_signal("flipped"):
			_shadow.flipped.connect(_on_shadow_flipped)

	if _exit and _exit.has_signal("player_reached_exit"):
		_exit.player_reached_exit.connect(_on_exit_reached)

	_evaluate_plates()
	queue_redraw()


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		queue_redraw()

	if Input.is_action_just_pressed("restart"):
		GameData.restart_level()


# ── Virtual: override in concrete levels to define walls ─────────────────────

func setup_walls() -> void:
	wall_cells.clear()
	for x in range(grid_width):
		wall_cells.append(Vector2i(x, 0))
		wall_cells.append(Vector2i(x, grid_height - 1))
	for y in range(1, grid_height - 1):
		wall_cells.append(Vector2i(0, y))
		wall_cells.append(Vector2i(grid_width - 1, y))


# ── Queries ──────────────────────────────────────────────────────────────────

func is_wall(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return true
	return pos in wall_cells


func is_door_blocking(pos: Vector2i) -> bool:
	for door in _doors:
		if door.get("grid_pos") == pos and not door.get("is_open"):
			return true
	return false


# ── Pressure Plate Evaluation ────────────────────────────────────────────────

func _evaluate_plates() -> void:
	var p_pos: Vector2i = _player.get("grid_pos") if _player else Vector2i(-999, -999)
	var s_active: bool = _shadow.visible if _shadow else false
	var s_pos: Vector2i = _shadow.get("grid_pos") if _shadow else Vector2i(-999, -999)

	for plate in _plates:
		if plate.has_method("update_pressure"):
			plate.update_pressure(p_pos, s_active, s_pos)


# ── Signal handlers ──────────────────────────────────────────────────────────

func _on_player_moved(gpos: Vector2i) -> void:
	_evaluate_plates()
	if _exit and _exit.has_method("check_player"):
		_exit.check_player(gpos)


func _on_shadow_stepped(_gpos: Vector2i) -> void:
	_evaluate_plates()


func _on_recording_complete() -> void:
	if _player == null or _shadow == null:
		return
	var positions: Array[Vector2i] = _player.get("recorded_positions")
	if positions.is_empty():
		return
	_shadow.start_replay(positions, false)
	AudioManager.play_shadow_deploy()

	if _hud and _hud.has_method("set_shadow_status"):
		_hud.set_shadow_status("SHADOW DEPLOYED — Press [F] for SHADOW FLIP (Reversal)")


func _on_flip_requested() -> void:
	if _shadow == null:
		return
	var positions: Array[Vector2i] = _player.get("recorded_positions")
	if not _shadow.visible and not positions.is_empty():
		# Deploy directly in reverse!
		_shadow.start_replay(positions, true)
		AudioManager.play_shadow_flip()
		_trigger_flip_effect(true)
	elif _shadow.visible:
		_shadow.flip()


func _on_shadow_flipped(is_reversed: bool) -> void:
	_trigger_flip_effect(is_reversed)
	_evaluate_plates()


func _trigger_flip_effect(is_reversed: bool) -> void:
	_flash_timer = 0.25
	queue_redraw()
	if _hud and _hud.has_method("set_shadow_status"):
		if is_reversed:
			_hud.set_shadow_status("<< SHADOW FLIP: REVERSAL ENGAGED << (Press F to re-flip)")
		else:
			_hud.set_shadow_status(">> SHADOW: FORWARD PLAYBACK >> (Press F to flip)")
	if _hud and _hud.has_method("show_message"):
		_hud.show_message("SHADOW FLIP — REVERSAL", 1.2)


func _on_exit_reached() -> void:
	AudioManager.play_victory()
	GameData.next_level()


# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var total_w := grid_width * TILE_SIZE
	var total_h := grid_height * TILE_SIZE

	# Dark digital background.
	draw_rect(Rect2(0, 0, total_w, total_h), Color(0.015, 0.02, 0.04, 1.0), true)

	# Faint cyan grid lines.
	var line_color := Color(0.0, 0.9, 1.0, 0.06)
	for x in range(grid_width + 1):
		draw_line(Vector2(x * TILE_SIZE, 0), Vector2(x * TILE_SIZE, total_h), line_color, 1.0)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * TILE_SIZE), Vector2(total_w, y * TILE_SIZE), line_color, 1.0)

	# Wall cells — dark block with crisp neon glow outline.
	var wall_fill := Color(0.08, 0.1, 0.16, 1.0)
	var wall_outline := Color(0.0, 0.85, 1.0, 0.45)
	for cell in wall_cells:
		var rect := Rect2(cell.x * TILE_SIZE, cell.y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
		draw_rect(rect, wall_fill, true)
		draw_rect(rect, wall_outline, false, 1.5)

	# Fullscreen flash on Shadow Flip.
	if _flash_timer > 0.0:
		var alpha: float = (_flash_timer / 0.25) * 0.35
		draw_rect(Rect2(0, 0, total_w, total_h), Color(1.0, 0.2, 0.8, alpha), true)


# ── Helpers ──────────────────────────────────────────────────────────────────

func _find_child_by_script(keyword: String) -> Node2D:
	for child in get_children():
		var s: Script = child.get_script() as Script
		if s and s.resource_path.ends_with(keyword + ".gd"):
			return child as Node2D
	return null
