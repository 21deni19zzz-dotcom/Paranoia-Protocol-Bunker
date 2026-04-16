extends Area3D
class_name BatteryPickup
## Pickup trigger for a battery. On interact → adds to inventory, frees self.
## Drop an ItemResource (type=BATTERY) via @export.

@export var item: ItemResource
@export var recharge_amount: float = 50.0

var _taken: bool = false


func interact() -> void:
	if _taken or item == null:
		return
	_taken = true
	InventoryManager.add_item(item, 1)
	# Immediately recharge any flashlight in the scene — skipping an extra menu step.
	var fl: FlashlightSystem = get_tree().get_first_node_in_group(&"flashlight") as FlashlightSystem
	if fl:
		fl.recharge(recharge_amount)
	queue_free()
