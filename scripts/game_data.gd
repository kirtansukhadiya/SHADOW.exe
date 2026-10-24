## Autoload singleton that manages global game state, level progression,
## and scene transitions for SHADOW.exe.
extends Node

## Index of the currently active level (0-based).
var current_level: int = 0

## Ordered list of level scene paths (Side-Scrolling Main Campaign).
var level_scenes: Array[String] = [
	"res://scenes/sidescroll/SideLevel1.tscn",
	"res://scenes/sidescroll/SideLevel2.tscn",
	"res://scenes/sidescroll/SideLevel3.tscn",
]

## Top-down levels preserved in archive.
var topdown_scenes: Array[String] = [
	"res://scenes/levels/Level1.tscn",
	"res://scenes/levels/Level2.tscn",
	"res://scenes/levels/Level3.tscn",
]

## Global tile size used by the grid system (pixels).
const TILE_SIZE: int = 64


## Advance to the next level. If all levels are complete, show the victory screen.
func next_level() -> void:
	current_level += 1
	if current_level >= level_scenes.size():
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
	else:
		get_tree().change_scene_to_file(level_scenes[current_level])


## Reload the current level from scratch.
func restart_level() -> void:
	get_tree().change_scene_to_file(level_scenes[current_level])


## Return to the title / main-menu scene.
func go_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


## Jump to an arbitrary level by index and change scene.
func load_level(index: int) -> void:
	current_level = clampi(index, 0, level_scenes.size() - 1)
	get_tree().change_scene_to_file(level_scenes[current_level])
