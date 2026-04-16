extends Node
class_name ParanoiaEffects
## Visual effects driven by paranoia level.
## Attach as child of Camera3D. Controls a child WorldEnvironment's adjustments
## and camera shake. Stronger shader work (CA, glitch) relies on existing
## shaders under shaders/ — this script updates their parameters.

@export var camera_path: NodePath
@export var world_env_path: NodePath
@export var shake_max: float = 0.06
@export var vignette_max: float = 1.2

var _camera: Camera3D
var _env: Environment
var _shake_time: float = 0.0
var _base_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	if camera_path != NodePath():
		_camera = get_node_or_null(camera_path) as Camera3D
	else:
		_camera = get_parent() as Camera3D
	if _camera:
		_base_offset = _camera.position
	if world_env_path != NodePath():
		var we: WorldEnvironment = get_node_or_null(world_env_path) as WorldEnvironment
		if we:
			_env = we.environment
	EventBus.paranoia_changed.connect(_on_paranoia_changed)


func _process(delta: float) -> void:
	if _camera == null:
		return
	var t: float = ParanoiaManager.get_normalized()
	# Camera shake: stronger as paranoia rises
	_shake_time += delta * (4.0 + 20.0 * t)
	var amp: float = shake_max * t
	_camera.position = _base_offset + Vector3(
		sin(_shake_time * 1.7) * amp,
		cos(_shake_time * 2.1) * amp,
		0.0,
	)


func _on_paranoia_changed(value: float) -> void:
	if _env == null:
		return
	var t: float = value / ParanoiaManager.max_paranoia
	# Vignette + grain + darken tint scale with paranoia.
	if _env.adjustment_enabled == false:
		_env.adjustment_enabled = true
	_env.adjustment_saturation = lerpf(1.0, 0.5, t)
	_env.adjustment_contrast = lerpf(1.0, 1.2, t)
	# Environment doesn't have a direct vignette in Godot 4 by default; we lean on
	# post-process shaders for CA/glitch/TV static and use fog for depth at panic.
	_env.fog_enabled = t > 0.3
	_env.fog_density = lerpf(0.0, 0.05, t)
