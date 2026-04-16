# Audit Report — before Fix & Upgrade session

Дата: 2026-04-16. Ветка: `claude/magical-ardinghelli`. Worktree: `.claude/worktrees/magical-ardinghelli`.

## Autoloads (из `project.godot`)

| Autoload | Path / UID | Статус |
|---|---|---|
| AppConfig | `uid://cjke6crjg14a0` | ✓ template (меню) |
| SceneLoader | `uid://cbwmrnp0af35y` | ✓ template |
| ProjectMusicController | `uid://r5t485lr3p7t` | ✓ template |
| ProjectUISoundController | `uid://cc37235kj4384` | ✓ template |
| InputIconMapperGlobal | `uid://done0t0ojxyp1` | ✓ template |
| GamePiecesEventBus | `uid://cm31gl2cxmt6y` | ✓ addon |
| SoundFxMgr | `res://scenes/sound_fx/sound_fx_mgr.tscn` | ✓ addon |
| **Talo** | `uid://cf5txmco4tia4` | ❌ **ERROR** — спамит 401 без API token |
| **TaloGlobal** | `res://scripts/talo_events.gd` | ❌ зависит от Talo |
| co | `uid://bjkb7sfgdaofj` | ✓ template |
| ImpactMgr | `uid://dsun3ccikxe7v` | ✓ template |
| SceneRenderManager | `uid://mbume3uiijsw` | ✓ template |
| EventBus | `res://systems/events/event_bus.gd` | ✓ наш |
| GameManager | `res://systems/events/game_manager.gd` | ✓ наш |
| ParanoiaManager | `res://systems/paranoia/paranoia_manager.gd` | ✓ наш |
| InventoryManager | `res://systems/inventory/inventory_manager.gd` | ✓ наш |
| SaveManager | `res://systems/save/save_manager.gd` | ✓ наш |

## Сцены (.tscn)

| Файл | Размер (B) | Примечание |
|---|---|---|
| scenes/levels/main.tscn | 11393 | template demo |
| scenes/levels/main2.tscn | 10252 | template demo |
| scenes/levels/bunker_entrance.tscn | 4343 | roadmap, CSG без материалов |
| scenes/levels/bunker_corridor.tscn | 3275 | roadmap, CSG без материалов |
| scenes/ui/game_hud.tscn | 2466 | HUD |
| scenes/ui/inventory_ui.tscn | 2018 | инвентарь |
| scenes/ui/note_viewer_ui.tscn | 1893 | просмотр записок |

## Warnings / Errors статус

| Категория | Статус | Где |
|---|---|---|
| Talo 401 network spam | ❌ активно | Talo addon |
| unused_signal x13 | ✓ **починено ранее** (`fc22c34`, `@warning_ignore_start`) | systems/events/event_bus.gd |
| integer_division | ✓ **починено ранее** (`@warning_ignore`) | systems/events/game_manager.gd L35-L37 |
| unsafe_property_access (flashlight) | ✓ **починено ранее** (cast → FlashlightSystem) | systems/save/save_manager.gd L35-L38 |
| main_scene не на bunker_entrance | ❌ → `scenes/menus/opening/opening_with_logo.tscn` | project.godot |

## Отсутствующие ассеты

- `assets/textures/` — **не существует**
- `assets/materials/` — **пустая**
- Реальные `.ogg` / `.wav` для `assets/audio/ambience|sfx|music` — **нет** (только пустые папки)
- Шрифты с Cyrillic — не добавлены (использует default)

## Присутствующие ассеты

- `assets/models/kaykit-dungeon-remastered/` — KayKit CC0 GLB (cabinet, chair, closet, drawer, door, table, props) — уже импортировано, эквивалент Kenney Industrial Kit
- `assets/kenney_input-prompts/` — иконки клавиш
- `assets/cursors/`, `assets/logos/` — template

## План починки

Phase B → Talo off. Phase C → concrete/metal materials. Phase D → bunker_entrance rebuild + main_scene. Phase E → попытка Kenney (или fallback на KayKit). Phase F → bunker_corridor rebuild + battery pickup + scene transition. Phase G → TEST_CHECKLIST. Phase H → FINAL_REPORT + push.
