extends Area3D
class_name FlashlightPickup
## Pickup trigger: on interact, adds flashlight to inventory AND
## instantiates a FlashlightSystem under Player/Head/Camera3D.

@export var item: ItemResource

var _taken: bool = false


func interact() -> void:
	if _taken:
		return
	_taken = true
	if item:
		InventoryManager.add_item(item, 1)
	_attach_flashlight_to_player()
	queue_free()


func _attach_flashlight_to_player() -> void:
	var player: Node = get_tree().get_first_node_in_group(&"player")
	if player == null:
		push_warning("FlashlightPickup: no player in scene")
		return
	var camera: Node3D = player.find_child("Camera3D", true, false) as Node3D
	if camera == null:
		push_warning("FlashlightPickup: no Camera3D under player")
		return
	# Avoid duplicate attach
	for c: Node in camera.get_children():
		if c is FlashlightSystem:
			return
	var fl: FlashlightSystem = FlashlightSystem.new()
	fl.name = "FlashlightSystem"
	camera.add_child(fl)
