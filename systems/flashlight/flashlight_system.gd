extends Node3D
class_name FlashlightSystem
## Player flashlight. Attach as child of head/camera.
## Owns a SpotLight3D and AudioStreamPlayer3D.

@export var is_on: bool = false
@export var battery: float = 100.0
@export var drain_rate: float = 2.0  # %/sec
@export var flicker_threshold: float = 15.0
@export var min_battery_to_emit: float = 1.0

@export var spot_light_path: NodePath
@export var click_audio_path: NodePath

var _spot: SpotLight3D
var _click: AudioStreamPlayer3D
var _flicker_timer: float = 0.0
var _base_energy: float = 4.0


func _ready() -> void:
	if spot_light_path != NodePath():
		_spot = get_node_or_null(spot_light_path) as SpotLight3D
	if click_audio_path != NodePath():
		_click = get_node_or_null(click_audio_path) as AudioStreamPlayer3D
	if _spot:
		_base_energy = _spot.light_energy
		_spot.visible = is_on


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and Input.is_key_pressed(KEY_F):
		# fallback handled below
		pass
	# Direct F key toggle (interact is also F by default; this is a placeholder hook)


func _process(delta: float) -> void:
	if is_on and battery > 0.0:
		battery = maxf(0.0, battery - drain_rate * delta)
		EventBus.flashlight_battery_changed.emit(battery)
		if battery <= flicker_threshold:
			_apply_flicker(delta)
		else:
			if _spot:
				_spot.light_energy = _base_energy
		if battery <= 0.0:
			_set_on(false)
		_update_paranoia_modifiers()


func toggle() -> void:
	if not is_on and battery <= min_battery_to_emit:
		return
	_set_on(not is_on)
	if _click:
		_click.play()


func recharge(amount: float) -> void:
	battery = clampf(battery + amount, 0.0, 100.0)
	EventBus.flashlight_battery_changed.emit(battery)


func _set_on(value: bool) -> void:
	is_on = value
	if _spot:
		_spot.visible = is_on
	EventBus.flashlight_toggled.emit(is_on)
	_update_paranoia_modifiers()


func _apply_flicker(delta: float) -> void:
	_flicker_timer -= delta
	if _flicker_timer <= 0.0:
		_flicker_timer = randf_range(0.05, 0.25)
		if _spot:
			_spot.light_energy = _base_energy * randf_range(0.2, 1.0)


func _update_paranoia_modifiers() -> void:
	# Flashlight ON with healthy battery: faster decay, slower growth
	# OFF or near-dead: faster growth
	if not Engine.has_singleton("ParanoiaManager") and not is_instance_valid(ParanoiaManager):
		return
	if is_on and battery > 20.0:
		ParanoiaManager.decay_multiplier = 1.5
		ParanoiaManager.growth_multiplier = 1.0
	elif not is_on or battery < 10.0:
		ParanoiaManager.decay_multiplier = 1.0
		ParanoiaManager.growth_multiplier = 2.0
	else:
		ParanoiaManager.decay_multiplier = 1.0
		ParanoiaManager.growth_multiplier = 1.0
