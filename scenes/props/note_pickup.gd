extends Area3D
class_name NotePickup
## In-world readable note. Interact to open viewer, emits EventBus.note_found.

@export var note: NoteResource
@export var paranoia_on_read: float = 10.0

var _triggered: bool = false


func interact() -> void:
	if _triggered or note == null:
		return
	_triggered = true
	note.is_read = true
	EventBus.note_found.emit(note.note_id)
	if paranoia_on_read > 0.0:
		ParanoiaManager.add_paranoia(paranoia_on_read)
