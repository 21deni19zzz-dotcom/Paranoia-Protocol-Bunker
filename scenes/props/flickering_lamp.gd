extends OmniLight3D
## Flickering bunker lamp. State machine: ON (2s) -> FLICKER (0.5s) -> OFF (1s) -> loop.

enum Phase { ON, FLICKER, OFF }

@export var on_time: float = 2.0
@export var flicker_time: float = 0.5
@export var off_time: float = 1.0

var _phase: Phase = Phase.ON
var _timer: float = 0.0
var _base_energy: float = 1.0


func _ready() -> void:
	_base_energy = light_energy
	_timer = on_time


func _process(delta: float) -> void:
	_timer -= delta
	match _phase:
		Phase.ON:
			light_energy = _base_energy
			if _timer <= 0.0:
				_phase = Phase.FLICKER
				_timer = flicker_time
		Phase.FLICKER:
			light_energy = _base_energy * randf_range(0.05, 1.0)
			if _timer <= 0.0:
				_phase = Phase.OFF
				_timer = off_time
		Phase.OFF:
			light_energy = 0.0
			if _timer <= 0.0:
				_phase = Phase.ON
				_timer = on_time
