extends Node
## Global game state manager.

const DIFFICULTY_NORMAL: int = 1
const DIFFICULTY_HARD: int = 2

var current_level: String = ""
var is_paused: bool = false
var game_time: float = 0.0
var difficulty: int = DIFFICULTY_NORMAL


func _process(delta: float) -> void:
	if not is_paused:
		game_time += delta


func pause_game() -> void:
	is_paused = true
	get_tree().paused = true


func resume_game() -> void:
	is_paused = false
	get_tree().paused = false


func change_level(level_path: String) -> void:
	current_level = level_path
	get_tree().change_scene_to_file(level_path)


func get_play_time() -> String:
	var total_seconds: int = int(game_time)
	@warning_ignore("integer_division")
	var hours: int = total_seconds / 3600
	@warning_ignore("integer_division")
	var minutes: int = (total_seconds % 3600) / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
