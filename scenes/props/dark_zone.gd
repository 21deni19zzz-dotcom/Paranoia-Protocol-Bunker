extends Area3D
## When the player enters, forces paranoia growth (overrides is_in_light).

@export var extra_growth_per_sec: float = 5.0

var _player_inside: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if _player_inside:
		ParanoiaManager.is_in_light = false
		ParanoiaManager.add_paranoia(extra_growth_per_sec * delta)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player"):
		_player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group(&"player"):
		_player_inside = false
		ParanoiaManager.is_in_light = true
