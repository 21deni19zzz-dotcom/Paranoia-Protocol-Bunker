extends Node
## Minimal level transition helper. Call from anywhere:
##   LevelTransition.transition_to("res://scenes/levels/bunker_corridor.tscn")
## Also emits EventBus.checkpoint_reached for SaveManager autosave.

class_name LevelTransition


static func transition_to(level_path: String, checkpoint_id: String = "") -> void:
	if checkpoint_id != "":
		EventBus.checkpoint_reached.emit(checkpoint_id)
	GameManager.change_level(level_path)
