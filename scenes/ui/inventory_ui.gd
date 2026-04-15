extends Control
## Inventory window. Toggle with Tab/I. Pauses tree while open.

@onready var grid: GridContainer = $Panel/Margin/VBox/Grid
@onready var desc_label: Label = $Panel/Margin/VBox/Description
@onready var use_button: Button = $Panel/Margin/VBox/UseButton
@onready var title_label: Label = $Panel/Margin/VBox/Title

const SLOT_COUNT: int = 8

var _selected_name: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	use_button.pressed.connect(_on_use_pressed)
	EventBus.item_collected.connect(func(_n: String) -> void: _refresh())
	EventBus.item_used.connect(func(_n: String) -> void: _refresh())


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
		_refresh()


func _refresh() -> void:
	for c in grid.get_children():
		c.queue_free()
	var items: Array = InventoryManager.get_all_items()
	for i in range(SLOT_COUNT):
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(96, 96)
		if i < items.size():
			var slot: Dictionary = items[i]
			var res: ItemResource = slot.resource
			btn.text = "%s\nx%d" % [res.item_name, slot.count]
			btn.pressed.connect(_on_slot_pressed.bind(res))
		else:
			btn.text = ""
			btn.disabled = true
		grid.add_child(btn)
	if _selected_name == "" or not InventoryManager.has_item(_selected_name):
		desc_label.text = ""
		use_button.disabled = true


func _on_slot_pressed(res: ItemResource) -> void:
	_selected_name = res.item_name
	desc_label.text = res.item_description
	use_button.disabled = false


func _on_use_pressed() -> void:
	if _selected_name != "":
		InventoryManager.use_item(_selected_name)
		_refresh()
