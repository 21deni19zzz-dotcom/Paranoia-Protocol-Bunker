extends Control
## Full-screen note viewer. Opens via show_note(NoteResource). Esc closes.

@onready var title_label: Label = $Panel/Margin/VBox/Title
@onready var content_label: RichTextLabel = $Panel/Margin/VBox/Content
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_button.pressed.connect(close)
	EventBus.note_found.connect(_on_note_found)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func show_note(note: NoteResource) -> void:
	if note == null:
		return
	title_label.text = note.title
	content_label.text = note.content
	visible = true
	get_tree().paused = true


func close() -> void:
	visible = false
	get_tree().paused = false


func _on_note_found(note_id: String) -> void:
	# Lazy lookup — the caller with the resource is responsible for show_note.
	# We keep this hook so notes marked via EventBus can be displayed if registered later.
	pass
