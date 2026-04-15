# CLAUDE.md — Paranoia Protocol: Bunker

## Project Overview
First-person psychological horror game set in an underground bunker.
Engine: Godot 4.6.2 | Renderer: Forward Plus | Language: GDScript
Based on: AdeelTariq/First-Person-Horror-Template (fork)

## Architecture

### Core Addons (from template)
- `addons/player/` — FPS controller (305 lines): movement, sprint, crouch, lean, head bob, FOV
- `addons/game_pieces/` — Interactive objects (609 lines): doors, drawers, lockable doors, amnesia-style doors, pickables, breakables
- `addons/interaction_system/` — Raycast-based interaction (481 lines): 3D/2D controllers, interaction containers
- `addons/game_controls/` — Input abstraction layer between input system and game
- `addons/maaacks_menus_template/` — Full menu system: main menu, options, pause, credits
- `addons/hl_impacts/` — Impact effects system
- `addons/sound_fx_manager/` — Sound FX management
- `addons/proton_scatter/` — Prop/object scattering for level design
- `addons/prompt_formatters/` — Input prompt display

### Custom Systems (to build)
- `systems/paranoia/` — Paranoia meter, hallucinations, unreliable narrator
- `systems/inventory/` — Item collection, crafting (reference: ThiDiamondDev/horror-fps-template)
- `systems/flashlight/` — Flashlight with battery drain
- `systems/npc/` — NPC behavior, dialogue, trust system
- `systems/audio/` — Ambient audio, psychological sound triggers
- `systems/save/` — Save/load system

### Key Classes
- `Player` (CharacterBody3D) — Main player controller
- `InteractableDoor` (StaticBody3D) — Standard doors
- `LockableInteractableDoor` extends InteractableDoor — Key-locked doors
- `AmnesiaDrawer` (Node3D) — Drag-to-open drawers
- `Pickable` (RigidBody3D) — Physics-based pickable objects
- `Breakable` (Node) — Destructible objects
- `BaseInteractiveItem` (Area3D) — Base for all interactive items
- `InteractionController` — Manages raycast interactions
- `GamePiecesEventBus` — Event bus for game piece signals

### Scenes
- `scenes/levels/main.tscn` — Primary test level
- `scenes/player/player.tscn` — Player scene override
- `scenes/playground.tscn` — Template playground
- `scenes/menus/` — Full menu system (main, pause, options, credits)

### Shaders
- `shaders/psx_post_process/` — PS1-style post processing
- `shaders/retro/` — Retro downscale effect
- `shaders/tv_static_border/` — TV static border effect

## Coding Guidelines

### Karpathy Principles (MANDATORY)
1. **Think Before Coding** — State assumptions. If unclear, ask. Don't pick silently.
2. **Simplicity First** — Minimum code. No speculative features. 200 lines → 50 lines.
3. **Surgical Changes** — Only touch what's needed. Don't "improve" adjacent code.
4. **Goal-Driven Execution** — Define success criteria. Loop until verified.

### Project-Specific Rules
- All UI text in Russian (game language: Russian)
- Match existing GDScript style from template addons
- New systems go in `systems/` directory, NOT in `addons/`
- Use signals for inter-system communication via event buses
- Never modify template addon code directly — extend via inheritance
- Scene names: snake_case. Classes: PascalCase. Signals: snake_case
- Comments in English for code, Russian for game content strings

### File Organization
```
paranoia-bunker/
├── addons/           # Template addons (DO NOT MODIFY)
├── systems/          # Our custom game systems
│   ├── paranoia/     # Paranoia & hallucination system
│   ├── inventory/    # Inventory & crafting
│   ├── flashlight/   # Flashlight mechanics
│   ├── npc/          # NPC AI & dialogue
│   ├── audio/        # Psychological audio
│   └── save/         # Save/load
├── scenes/
│   ├── levels/       # Game levels (bunker rooms)
│   ├── player/       # Player scene overrides
│   ├── menus/        # Menu system (from template)
│   ├── pieces/       # Interactive objects
│   └── ui/           # In-game UI (HUD, inventory)
├── assets/
│   ├── models/       # 3D models
│   ├── sounds/       # Audio files
│   ├── textures/     # Textures
│   └── fonts/        # Fonts (Cyrillic support required)
├── shaders/          # Visual effects
├── resources/        # Godot resources (.tres)
└── scripts/          # Standalone utility scripts
```

## Development Phases

### Phase 1 — Foundation (current)
- [x] Fork template
- [x] Create CLAUDE.md
- [x] Set up systems/ directory structure
- [x] Rename project to "Paranoia Protocol: Bunker"
- [ ] Create first bunker room level

### Phase 2 — Core Mechanics
- [ ] Paranoia system (meter, visual distortion, hallucinations)
- [ ] Inventory system (port from ThiDiamondDev reference)
- [ ] Flashlight with battery drain
- [ ] Door/key puzzle system

### Phase 3 — Content
- [ ] NPC system with trust mechanics
- [ ] Dialogue system (Russian)
- [ ] Sound design & ambient audio
- [ ] 3-5 bunker rooms with puzzles

### Phase 4 — Polish
- [ ] Save/load system
- [ ] PSX shader tuning
- [ ] Performance optimization
- [ ] Playtesting & balancing

## Quick Reference
- Notion context: notion.so/3425e0d0d94981edab64d7c6e43a7d28
- Template demo: adeeltariq.itch.io/lumboo
- Inventory reference: github.com/ThiDiamondDev/horror-fps-template
- Local path: C:\Users\PC\Desktop\Paranoia Protocol\
