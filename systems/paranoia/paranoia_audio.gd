extends Node
class_name ParanoiaAudio
## Audio layers that crossfade based on paranoia state.
## Each @export slot takes an AudioStreamPlayer (node path) you create in the scene.
## The stream assignment is done in the editor (or via code later) so this file
## stays asset-agnostic — placeholder ambience files live under assets/audio/.

@export var uneasy_player_path: NodePath
@export var anxious_player_path: NodePath
@export var fearful_player_path: NodePath
@export var panic_player_path: NodePath
@export var fade_speed: float = 1.5
@export var target_db: float = -6.0

var _uneasy: AudioStreamPlayer
var _anxious: AudioStreamPlayer
var _fearful: AudioStreamPlayer
var _panic: AudioStreamPlayer

# Track desired volume per layer
var _desired: Dictionary = {}


func _ready() -> void:
	_uneasy = _fetch(uneasy_player_path)
	_anxious = _fetch(anxious_player_path)
	_fearful = _fetch(fearful_player_path)
	_panic = _fetch(panic_player_path)
	for p in [_uneasy, _anxious, _fearful, _panic]:
		if p:
			p.volume_db = -80.0
			_desired[p] = -80.0
			if p.stream:
				p.play()
	EventBus.paranoia_changed.connect(_on_paranoia_changed)


func _fetch(path: NodePath) -> AudioStreamPlayer:
	if path == NodePath():
		return null
	return get_node_or_null(path) as AudioStreamPlayer


func _process(delta: float) -> void:
	for p in _desired.keys():
		if p == null:
			continue
		var cur: float = p.volume_db
		var tgt: float = _desired[p]
		p.volume_db = move_toward(cur, tgt, fade_speed * 60.0 * delta)


func _on_paranoia_changed(_value: float) -> void:
	var state: String = ParanoiaManager.get_state()
	_set_layer(_uneasy, state == ParanoiaManager.STATE_UNEASY or _above(state, ParanoiaManager.STATE_UNEASY))
	_set_layer(_anxious, _above_or_eq(state, ParanoiaManager.STATE_ANXIOUS))
	_set_layer(_fearful, _above_or_eq(state, ParanoiaManager.STATE_FEARFUL))
	_set_layer(_panic, state == ParanoiaManager.STATE_PANIC)


func _set_layer(p: AudioStreamPlayer, active: bool) -> void:
	if p == null:
		return
	_desired[p] = target_db if active else -80.0


const _ORDER: Array[String] = [
	"CALM", "UNEASY", "ANXIOUS", "FEARFUL", "PANIC",
]


func _above(state: String, threshold: String) -> bool:
	return _ORDER.find(state) > _ORDER.find(threshold)


func _above_or_eq(state: String, threshold: String) -> bool:
	return _ORDER.find(state) >= _ORDER.find(threshold)
