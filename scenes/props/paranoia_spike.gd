extends Area3D
class_name ParanoiaSpike
## One-shot paranoia spike when the player enters the area.

@export var amount: float = 20.0

var _fired: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _fired or not body.is_in_group(&"player"):
		return
	_fired = true
	ParanoiaManager.add_paranoia(amount)
