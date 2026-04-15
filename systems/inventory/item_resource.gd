extends Resource
class_name ItemResource
## Data container for a single inventory item type.

enum ItemType {
	CONSUMABLE,
	KEY_ITEM,
	NOTE,
	BATTERY,
	TOOL,
}

@export var item_name: String = ""
@export_multiline var item_description: String = ""
@export var item_icon: Texture2D
@export var item_type: ItemType = ItemType.TOOL
@export var is_stackable: bool = false
@export var max_stack: int = 1
## Function name on InventoryManager (or attached handler) to call on use.
@export var use_action: String = ""
