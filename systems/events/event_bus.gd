extends Node
## Global event bus singleton.
## Decouples systems via signals — emit here, subscribe from anywhere.
## Signals are referenced across files via EventBus.<name>.emit(...) which the
## static analyzer cannot detect — silence unused-signal warnings for this file.
@warning_ignore_start("unused_signal")

# Paranoia
signal paranoia_changed(new_value: float)
signal hallucination_triggered(type: String)

# Inventory
signal item_collected(item_name: String)
signal item_used(item_name: String)

# Flashlight
signal flashlight_toggled(is_on: bool)
signal flashlight_battery_changed(percent: float)

# World interaction
signal door_interaction(door_id: String, is_locked: bool)
signal note_found(note_id: String)

# NPC
signal npc_trust_changed(npc_id: String, trust: float)

# Game flow
signal checkpoint_reached(checkpoint_id: String)
signal game_saved()
signal game_loaded()
