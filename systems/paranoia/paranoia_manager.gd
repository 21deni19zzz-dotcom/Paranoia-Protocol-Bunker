extends Node
## Paranoia state singleton.
## Drives perception distortions, audio cues, hallucinations.

const STATE_CALM: String = "CALM"
const STATE_UNEASY: String = "UNEASY"
const STATE_ANXIOUS: String = "ANXIOUS"
const STATE_FEARFUL: String = "FEARFUL"
const STATE_PANIC: String = "PANIC"

@export var paranoia_level: float = 0.0
@export var max_paranoia: float = 100.0
@export var decay_rate: float = 0.5  # per second under light
@export var growth_rate: float = 1.0  # per second in darkness

# Multipliers from external systems (e.g. flashlight on multiplies decay)
var decay_multiplier: float = 1.0
var growth_multiplier: float = 1.0

# Set by world/lighting probes; default true so empty scenes don't auto-spike
var is_in_light: bool = true


func _process(delta: float) -> void:
	var prev: float = paranoia_level
	if is_in_light:
		paranoia_level -= decay_rate * decay_multiplier * delta
	else:
		paranoia_level += growth_rate * growth_multiplier * delta
	paranoia_level = clampf(paranoia_level, 0.0, max_paranoia)
	if not is_equal_approx(prev, paranoia_level):
		EventBus.paranoia_changed.emit(paranoia_level)


func add_paranoia(amount: float) -> void:
	paranoia_level = clampf(paranoia_level + amount, 0.0, max_paranoia)
	EventBus.paranoia_changed.emit(paranoia_level)


func reduce_paranoia(amount: float) -> void:
	paranoia_level = clampf(paranoia_level - amount, 0.0, max_paranoia)
	EventBus.paranoia_changed.emit(paranoia_level)


func get_state() -> String:
	if paranoia_level < 20.0:
		return STATE_CALM
	elif paranoia_level < 40.0:
		return STATE_UNEASY
	elif paranoia_level < 60.0:
		return STATE_ANXIOUS
	elif paranoia_level < 80.0:
		return STATE_FEARFUL
	else:
		return STATE_PANIC


func get_normalized() -> float:
	return paranoia_level / max_paranoia
