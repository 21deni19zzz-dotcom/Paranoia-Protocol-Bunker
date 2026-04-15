extends Node
## Save/load singleton. Autoload "SaveManager".
## Slots stored as user://saves/slot_N.save (JSON).

const SAVE_DIR: String = "user://saves"

var read_notes: Array[String] = []
var opened_doors: Array[String] = []


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	EventBus.note_found.connect(func(id: String) -> void:
		if id not in read_notes:
			read_notes.append(id))
	EventBus.door_interaction.connect(func(door_id: String, _locked: bool) -> void:
		if door_id not in opened_doors:
			opened_doors.append(door_id))
	EventBus.checkpoint_reached.connect(func(_id: String) -> void: auto_save())


func _slot_path(slot: int) -> String:
	return "%s/slot_%d.save" % [SAVE_DIR, slot]


func save_game(slot: int = 0) -> bool:
	var player: Node3D = get_tree().get_first_node_in_group(&"player") as Node3D
	var pos: Vector3 = Vector3.ZERO
	var rot: Vector3 = Vector3.ZERO
	if player:
		pos = player.global_position
		rot = player.global_rotation

	var flashlight_battery: float = 100.0
	var fl: Node = get_tree().get_first_node_in_group(&"flashlight")
	if fl and "battery" in fl:
		flashlight_battery = fl.battery

	var data: Dictionary = {
		"player_position": [pos.x, pos.y, pos.z],
		"player_rotation": [rot.x, rot.y, rot.z],
		"current_level": GameManager.current_level,
		"paranoia_level": ParanoiaManager.paranoia_level,
		"flashlight_battery": flashlight_battery,
		"inventory_items": _serialize_inventory(),
		"read_notes": read_notes,
		"opened_doors": opened_doors,
		"game_time": GameManager.game_time,
	}
	var f: FileAccess = FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	EventBus.game_saved.emit()
	return true


func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false
	var f: FileAccess = FileAccess.open(_slot_path(slot), FileAccess.READ)
	if f == null:
		return false
	var txt: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed
	ParanoiaManager.paranoia_level = data.get("paranoia_level", 0.0)
	GameManager.game_time = data.get("game_time", 0.0)
	read_notes = data.get("read_notes", [])
	opened_doors = data.get("opened_doors", [])
	# Level/player pos/flashlight are applied by their owners after scene load.
	EventBus.game_loaded.emit()
	return true


func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func delete_save(slot: int = 0) -> void:
	var path: String = _slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func auto_save() -> void:
	save_game(0)


func _serialize_inventory() -> Array:
	var out: Array = []
	for slot in InventoryManager.get_all_items():
		var res: ItemResource = slot.resource
		if res == null:
			continue
		out.append({
			"item_name": res.item_name,
			"count": slot.count,
			"resource_path": res.resource_path,
		})
	return out
