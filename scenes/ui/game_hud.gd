extends CanvasLayer
## In-game HUD: battery bar, paranoia eye, interaction prompt, crosshair, toasts.

@onready var battery_bar: ProgressBar = $Margin/HUDRoot/BatteryBox/BatteryBar
@onready var battery_icon: ColorRect = $Margin/HUDRoot/BatteryBox/BatteryIcon
@onready var paranoia_icon: ColorRect = $Margin/HUDRoot/ParanoiaIcon
@onready var interaction_label: Label = $Margin/HUDRoot/InteractionLabel
@onready var crosshair: ColorRect = $Margin/HUDRoot/Crosshair
@onready var toast_label: Label = $Margin/HUDRoot/ToastLabel

const COLOR_GREEN: Color = Color(0.3, 0.9, 0.3)
const COLOR_YELLOW: Color = Color(0.95, 0.9, 0.2)
const COLOR_RED: Color = Color(0.95, 0.2, 0.2)
const COLOR_WHITE: Color = Color(1, 1, 1)
const COLOR_ORANGE: Color = Color(0.95, 0.55, 0.15)

var _toast_timer: float = 0.0
var _pulse_time: float = 0.0


func _ready() -> void:
	EventBus.flashlight_battery_changed.connect(_on_battery_changed)
	EventBus.paranoia_changed.connect(_on_paranoia_changed)
	EventBus.item_collected.connect(_on_item_collected)
	if toast_label:
		toast_label.modulate.a = 0.0


func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if toast_label:
			toast_label.modulate.a = clampf(_toast_timer / 1.0, 0.0, 1.0)
	_pulse_time += delta
	if paranoia_icon and ParanoiaManager.paranoia_level > 60.0:
		var p: float = 0.6 + 0.4 * sin(_pulse_time * 6.0)
		paranoia_icon.modulate.a = p


func _on_battery_changed(percent: float) -> void:
	if battery_bar:
		battery_bar.value = percent
	if battery_icon:
		if percent > 50.0:
			battery_icon.color = COLOR_GREEN
		elif percent > 20.0:
			battery_icon.color = COLOR_YELLOW
		else:
			battery_icon.color = COLOR_RED


func _on_paranoia_changed(value: float) -> void:
	if not paranoia_icon:
		return
	if value < 25.0:
		paranoia_icon.color = COLOR_WHITE
	elif value < 50.0:
		paranoia_icon.color = COLOR_YELLOW
	elif value < 75.0:
		paranoia_icon.color = COLOR_ORANGE
	else:
		paranoia_icon.color = COLOR_RED
	if value <= 60.0:
		paranoia_icon.modulate.a = 1.0


func show_interaction(text: String) -> void:
	if interaction_label:
		interaction_label.text = text
		interaction_label.visible = text != ""


func _on_item_collected(item_name: String) -> void:
	show_toast("Подобрано: %s" % item_name)


func show_toast(text: String) -> void:
	if not toast_label:
		return
	toast_label.text = text
	toast_label.modulate.a = 1.0
	_toast_timer = 3.0
