extends ItemResource
class_name CraftItemResource
## An item that can be crafted from other items.
## `items_needed` — array of ItemResource required (with item_name + count via max_stack).

@export var items_needed: Array[Resource] = []
