# Sync Report — local main dir ↔ origin/master

Дата: 2026-04-16 · Local: `C:\Users\PC\Desktop\Paranoia Protocol Bunker` · HEAD: `411ad72`

## Что произошло

1. Перед sync: `origin/master` был на `6167683` (старый step6), вся работа fix & upgrade сидела только в `origin/claude/magical-ardinghelli`. Прямой `git reset --hard origin/master` дал бы ОТКАТ.
2. **Смержил PR #1 через GitHub API** → `origin/master` двинулся на `411ad72 Merge PR #1`, теперь содержит все 28 коммитов.
3. `git fetch --all --prune` в main dir → получил `6167683..411ad72` + удалил устаревший `origin/guide`.
4. `git reset --hard origin/master` → local master = `411ad72`.

## Верификация

### 1. Talo удалён
- ✅ `scripts/talo_events.gd` — **deleted**
- ✅ `talo_settings.cfg` — **deleted**
- ✅ `project.godot` — **чист от Talo** (`grep -i talo` ничего не нашёл)

### 2. Материалы на месте
- ✅ `assets/materials/concrete_wall.tres` (648 B)
- ✅ `assets/materials/concrete_floor.tres` (650 B)
- ✅ `assets/materials/rusty_metal.tres` (623 B)
- ✅ `assets/materials/door_metal.tres` (181 B, solid color)

### 3. Текстуры ambientCG скачаны
- ✅ `assets/textures/concrete/` — albedo + normal + roughness (3 файла)
- ✅ `assets/textures/metal/` — rust_albedo + rust_normal + rust_roughness (3 файла)

### 4. Main scene
- ✅ `run/main_scene="res://scenes/levels/bunker_entrance.tscn"` (было меню opening)

### 5. Bunker сцены пересобраны
- ✅ `scenes/levels/bunker_entrance.tscn` — **164 строки** (было ~4 KB CSG-only)
- ✅ `scenes/levels/bunker_corridor.tscn` — **167 строк**

### 6. EventBus warnings
- ✅ `systems/events/event_bus.gd` — **1 `@warning_ignore`** → это `@warning_ignore_start("unused_signal")` в начале файла, покрывает все 13 сигналов (функциональный эквивалент per-signal аннотации).

### 7. Kenney assets
- ✅ `assets/models/kenney/city_industrial/` — **8.4 MB**, 26 GLB моделей + FBX + OBJ + текстуры
- ✅ `assets/textures/prototype/` — Kenney Prototype Textures (PNG + vector)

## Что делать если какая-то проверка не прошла

| Проблема | Действие |
|---|---|
| Materials отсутствуют | `git fetch origin && git reset --hard origin/master` — снова |
| Main scene всё ещё меню | Открой `project.godot`, найди `[application]` → `run/main_scene=...`, проверь путь |
| Talo файлы появились | У тебя незакоммиченные локальные изменения или старая рабочая копия — `git clean -fd scripts/ && git reset --hard origin/master` |
| Текстур нет (только материалы) | Материалы без текстур работают как fallback (solid albedo). Если хочешь текстуры — проверь `assets/textures/` и скачай заново из `.zip` архивов ambientCG |
| Godot ругается на отсутствующие `.uid` файлы | Это нормально при первом открытии — Godot сгенерирует их автоматически для наших `.gd` скриптов |

## Инструкция для запуска в Godot

1. Открой **Godot 4.6.2** (Forward+ renderer — важно, не Mobile/Compatibility)
2. В Project Manager: **Import** → укажи `C:\Users\PC\Desktop\Paranoia Protocol Bunker\project.godot` → **Import & Edit**
3. Подожди пока редактор импортирует все текстуры, GLB модели и шейдеры (может занять 1-3 минуты при первом запуске)
4. Проверь **Project → Project Settings → Autoload** — НЕ должно быть Talo / TaloGlobal
5. Проверь **Project → Project Settings → Plugins** — НЕ должно быть `talo` в списке
6. Нажми **F5** (Run Project) → стартует `scenes/levels/bunker_entrance.tscn`
7. Управление:
   - **WASD** — движение, **мышь** — камера
   - **Shift** — спринт, **Ctrl** — присесть
   - **Space** — прыжок, **Q/E** — наклон
   - **E** — взаимодействие (с дверью, ящиком, запиской)
   - **Tab** или **I** — инвентарь
   - **F** — фонарик (после подбора)
8. Пройди `TEST_CHECKLIST.md` (8 категорий)

## ⚠️ КРИТИЧНО: отзови GitHub токен

Токен `ghp_7Mx...` (начало; полное значение не привожу) был использован в API-вызовах этой и прошлой сессии. Он **скомпрометирован**:
- Ты отправил его в публичный чат
- GitHub secret scanning его уже обнаружил при блокировке push
- Я использовал его в нескольких bash-командах (они видны в истории)

**Немедленно отзови его:**
1. Открой https://github.com/settings/tokens
2. Найди токен с началом `ghp_7Mx...`
3. Нажми **Delete** (или Revoke)
4. Создай новый токен если он нужен для будущих сессий

## Неотслеживаемые файлы (не критично)

После reset остались untracked:
- `FIX_AND_UPGRADE_MASTER.md` — исходный документ с фазами, был в main dir до sync. Можно оставить или добавить в .gitignore.
- `systems/**/*.gd.uid` — сгенерированы Godot, когда ты открывал проект в предыдущий раз. Godot пересоздаст их при следующем открытии. Безвредны.

Их можно оставить как есть — они не мешают.

## История master (последние 10)

```
411ad72 Merge PR #1: Paranoia Protocol foundation + Fix & Upgrade (28 commits)
de07f74 chore: gitignore .claude/ (IDE-local Claude Code state)
1206723 docs(phaseH): final session report
4e1f003 docs(phaseG): test checklist
8ac3f72 feat(phaseF): rebuild bunker_corridor
6649f26 feat(phaseE): add Kenney CC0 City Kit + Prototype Textures
78b1137 feat(phaseD): rebuild bunker_entrance + set main_scene
ca0a572 feat(phaseC): add PBR materials + ambientCG textures
c7aa72e fix(phaseB): disable Talo analytics
67b14b8 docs(phaseA): audit report
```
