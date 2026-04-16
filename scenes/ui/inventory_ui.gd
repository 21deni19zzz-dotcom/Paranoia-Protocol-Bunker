extends Control
## Inventory window (ThiDiamondDev-derived slot-grid pattern).
## Toggle with Tab/I. Pauses tree, releases mouse on open, re-captures on close.

const SlotScene: PackedScene = preload("res://scenes/ui/item_slot.tscn")
const SLOT_COUNT: int = 8

@onready var grid: GridContainer = $Panel/Margin/VBox/Body/Grid
@onready var title_label: Label = $Panel/Margin/VBox/Body/Details/Title
@onready var desc_label: Label = $Panel/Margin/VBox/Body/Details/Description
@onready var icon_preview: TextureRect = $Panel/Margin/VBox/Body/Details/IconPreview
@onready var use_button: Button = $Panel/Margin/VBox/Body/Details/UseButton
@onready var drop_button: Button = $Panel/Margin/VBox/Body/Details/DropButton

var _slots: Array[InventorySlot] = []
var _selected: InventorySlot = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_grid()
	use_button.pressed.connect(_on_use_pressed)
	drop_button.pressed.connect(_on_drop_pressed)
	EventBus.item_collected.connect(func(_n: String) -> void: _refresh())
	EventBus.item_used.connect(func(_n: String) -> void: _refresh())
	_update_details(null)


func _build_grid() -> void:
	for i: int in range(SLOT_COUNT):
		var slot: InventorySlot = SlotScene.instantiate()
		slot.index = i
		grid.add_child(slot)
		slot.slot_pressed.connect(_on_slot_pressed)
		_slots.append(slot)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB or event.keycode == KEY_I:
			_toggle()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and visible:
			_toggle()
			get_viewport().set_input_as_handled()


func _toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_refresh()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_deselect()


func _refresh() -> void:
	for slot: InventorySlot in _slots:
		slot.clear_slot()
	var items: Array = InventoryManager.get_all_items()
	for i: int in range(items.size()):
		if i >= SLOT_COUNT:
			break
		var entry: Dictionary = items[i]
		var res: ItemResource = entry.resource
		if res:
			_slots[i].set_item(res, int(entry.count))


func _on_slot_pressed(slot: InventorySlot) -> void:
	if slot.empty:
		return
	if _selected == slot:
		_deselect()
		return
	if _selected:
		_selected.set_selected(false)
	_selected = slot
	slot.set_selected(true)
	_update_details(slot.item)


func _deselect() -> void:
	if _selected:
		_selected.set_selected(false)
		_selected = null
	_update_details(null)


func _update_details(item: ItemResource) -> void:
	if item == null:
		title_label.text = ""
		desc_label.text = ""
		icon_preview.texture = null
		use_button.disabled = true
		drop_button.disabled = true
		return
	title_label.text = item.item_name
	desc_label.text = item.item_description
	icon_preview.texture = item.item_icon
	use_button.disabled = false
	drop_button.disabled = item.item_type == ItemResource.ItemType.KEY_ITEM


func _on_use_pressed() -> void:
	if _selected == null or _selected.item == null:
		return
	var item_name: String = _selected.item.item_name
	InventoryManager.use_item(item_name)
	_refresh()
	_deselect()


func _on_drop_pressed() -> void:
	if _selected == null or _selected.item == null:
		return
	InventoryManager.remove_item(_selected.item.item_name, 1)
	_refresh()
	_deselect()
