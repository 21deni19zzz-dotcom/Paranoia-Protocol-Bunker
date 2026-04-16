extends Area3D
class_name DoorSceneLoader
## Place behind a door. When the player enters the area, change scene.
## Works regardless of door state — the player must have opened it to walk through.

@export var target_scene: String = ""
@export var checkpoint_id: String = ""

var _fired: bool = false


func _ready() -> void:
	if target_scene == "":
		push_warning("DoorSceneLoader missing target_scene")
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _fired:
		return
	if not body.is_in_group(&"player"):
		return
	_fired = true
	if checkpoint_id != "":
		EventBus.checkpoint_reached.emit(checkpoint_id)
	GameManager.change_level(target_scene)
