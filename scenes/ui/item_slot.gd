extends PanelContainer
class_name InventorySlot
## Single inventory grid cell. Based on ThiDiamondDev horror-fps-template pattern.

signal slot_pressed(slot: InventorySlot)

@onready var button: Button = $Button
@onready var quantity_label: Label = $Button/QuantityLabel

var item: ItemResource = null
var count: int = 0
var selected: bool = false
var empty: bool = true
var index: int = -1


func _ready() -> void:
	button.pressed.connect(func() -> void: slot_pressed.emit(self))


func set_item(new_item: ItemResource, new_count: int) -> void:
	empty = false
	item = new_item
	count = new_count
	button.icon = new_item.item_icon
	button.text = "" if new_item.item_icon else new_item.item_name
	quantity_label.text = str(new_count) if new_count > 1 else ""


func clear_slot() -> void:
	empty = true
	selected = false
	item = null
	count = 0
	button.icon = null
	button.text = ""
	quantity_label.text = ""
	modulate = Color.WHITE


func set_selected(value: bool) -> void:
	selected = value
	modulate = Color(0.7, 1.0, 0.7) if value else Color.WHITE
