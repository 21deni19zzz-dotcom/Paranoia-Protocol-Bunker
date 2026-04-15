extends Resource
class_name NoteResource
## In-world readable note (papers, journals, scrawlings).

@export var note_id: String = ""
@export var title: String = ""
@export_multiline var content: String = ""
@export var is_read: bool = false
