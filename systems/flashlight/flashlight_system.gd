extends Node3D
class_name FlashlightSystem
## Self-contained player flashlight. Instantiate as child of Player/Head/Camera3D.
## Auto-creates its SpotLight3D child on _ready. F toggles. Adds itself to group "flashlight".

@export var is_on: bool = false
@export var battery: float = 100.0
@export var drain_rate: float = 2.0  # %/sec
@export var flicker_threshold: float = 15.0
@export var min_battery_to_start: float = 1.0
@export var spot_angle_deg: float = 35.0
@export var spot_range: float = 12.0
@export var emit_interval: float = 0.5

var _spot: SpotLight3D
var _base_energy: float = 2.0
var _flicker_timer: float = 0.0
var _emit_accum: float = 0.0


func _ready() -> void:
	add_to_group(&"flashlight")
	_spot = SpotLight3D.new()
	_spot.light_color = Color(1.0, 0.87, 0.65)
	_spot.light_energy = _base_energy
	_spot.spot_range = spot_range
	_spot.spot_angle = spot_angle_deg
	_spot.shadow_enabled = true
	_spot.visible = is_on
	add_child(_spot)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		toggle()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if is_on and battery > 0.0:
		battery = maxf(0.0, battery - drain_rate * delta)
		if battery <= flicker_threshold:
			_apply_flicker(delta)
		else:
			if _spot:
				_spot.light_energy = _base_energy
		if battery <= 0.0:
			_set_on(false)
	_emit_accum += delta
	if _emit_accum >= emit_interval:
		_emit_accum = 0.0
		EventBus.flashlight_battery_changed.emit(battery)
	_update_paranoia_modifiers()


func toggle() -> void:
	if not is_on and battery <= min_battery_to_start:
		return
	_set_on(not is_on)


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
	if not is_instance_valid(ParanoiaManager):
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
