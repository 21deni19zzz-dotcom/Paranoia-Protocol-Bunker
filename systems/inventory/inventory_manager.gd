extends Node
## Global inventory state. Autoload singleton "InventoryManager".
## Storage: Array of {resource: ItemResource, count: int}.

const MAX_SLOTS: int = 8

var items: Array = []


func add_item(item: ItemResource, count: int = 1) -> bool:
	if item == null or count <= 0:
		return false

	# Try to stack onto an existing slot
	if item.is_stackable:
		for slot in items:
			var res: ItemResource = slot.resource
			if res and res.item_name == item.item_name and slot.count < res.max_stack:
				var space: int = res.max_stack - slot.count
				var add: int = mini(space, count)
				slot.count += add
				count -= add
				EventBus.item_collected.emit(item.item_name)
				if count <= 0:
					return true

	# Remaining goes into new slots
	while count > 0:
		if items.size() >= MAX_SLOTS:
			return false
		var put: int = 1
		if item.is_stackable:
			put = mini(count, item.max_stack)
		items.append({"resource": item, "count": put})
		count -= put
		EventBus.item_collected.emit(item.item_name)
	return true


func remove_item(item_name: String, count: int = 1) -> bool:
	var remaining: int = count
	for i in range(items.size() - 1, -1, -1):
		var slot: Dictionary = items[i]
		var res: ItemResource = slot.resource
		if res and res.item_name == item_name:
			var take: int = mini(slot.count, remaining)
			slot.count -= take
			remaining -= take
			if slot.count <= 0:
				items.remove_at(i)
			if remaining <= 0:
				return true
	return remaining == 0


func has_item(item_name: String) -> bool:
	return get_item_count(item_name) > 0


func get_item_count(item_name: String) -> int:
	var total: int = 0
	for slot in items:
		var res: ItemResource = slot.resource
		if res and res.item_name == item_name:
			total += slot.count
	return total


func use_item(item_name: String) -> void:
	for slot in items:
		var res: ItemResource = slot.resource
		if res and res.item_name == item_name:
			if res.use_action != "" and has_method(res.use_action):
				call(res.use_action, res)
			EventBus.item_used.emit(item_name)
			if res.item_type != ItemResource.ItemType.KEY_ITEM:
				remove_item(item_name, 1)
			return


func get_all_items() -> Array:
	return items.duplicate()


func clear() -> void:
	items.clear()
