# PARANOIA PROTOCOL: BUNKER — Master Fix & Upgrade Task

**Запусти это в Claude Code одним куском. Работай автономно, не спрашивай подтверждения. После каждой фазы делай git commit.**

---

## КОНТЕКСТ ПРОБЛЕМЫ

Предыдущая сессия создала 20 систем, но игра выглядит как примитивные CSG-боксы без материалов на зелёной траве. Ошибки:
- Talo analytics addon спамит 401 ошибками (нет токена)
- Warnings про unused signals и integer division
- Main scene не установлен на bunker_entrance
- CSG-геометрия генерилась программно без материалов и часто с кривыми координатами
- Нет реальных 3D-ассетов — только solid colors

**ЦЕЛЬ**: Превратить это в играбельную демку с нормальной визуалкой за одну автономную сессию.

---

## PHASE A — ПОЛНЫЙ АУДИТ (делаем первым!)

### A.1 Собери диагностику
```bash
# Проверь структуру
find . -name "*.gd" -not -path "./.git/*" -not -path "./addons/*" | head -30
find . -name "*.tscn" -not -path "./.git/*" | head -30

# Посмотри autoloads
grep -A 20 "\[autoload\]" project.godot

# Проверь main scene
grep "run/main_scene" project.godot
```

### A.2 Создай файл AUDIT_REPORT.md с:
- Список всех autoloads и их статус (работает / ошибка)
- Список всех .tscn файлов с их размером
- Список всех найденных warnings и errors из логов Godot (если есть .godot/editor.log)
- Список отсутствующих ассетов (текстуры, звуки, шрифты)

---

## PHASE B — ПОЧИНКА (критические ошибки)

### B.1 Отключи Talo полностью
```
- В project.godot в секции [editor_plugins] убери строку "talo"
- Удали файлы:
  - scripts/talo_events.gd
  - scripts/talo_events.gd.uid
  - talo_settings.cfg
- Если в autoload есть talo — убери
- Если в сценах есть ссылки на TaloManager — закомментируй с пометкой "DISABLED: talo removed"
```

### B.2 Почини warnings в EventBus
В `systems/events/event_bus.gd` перед КАЖДЫМ `signal` добавь:
```gdscript
@warning_ignore("unused_signal")
signal paranoia_changed(new_value: float)
```
И так для всех 12 сигналов.

### B.3 Почини integer division
Найди все места с делением `int / int` и сделай float:
```bash
grep -rn "/ 60" systems/ --include="*.gd"
grep -rn "/ 100" systems/ --include="*.gd"
```
Замени `game_time / 60` → `game_time / 60.0` и т.д.

### B.4 Почини типизацию в SaveManager
В `systems/save/save_manager.gd` найди места где ищется flashlight через get_node — добавь типизацию или Variant cast.

### B.5 Коммит
```bash
git add -A
git commit -m "fix: disable talo, fix warnings, fix integer division"
```

---

## PHASE C — МАТЕРИАЛЫ И ТЕКСТУРЫ

### C.1 Скачай базовые текстуры бетона (через bash + curl)
Создай папку `assets/textures/concrete/` и скачай CC0-текстуры с ambientCG:
```bash
mkdir -p assets/textures/concrete assets/textures/metal assets/textures/props

# Concrete (1K версия, 512x512 для оптимизации будет запечена)
curl -L -o assets/textures/concrete/concrete_albedo.jpg \
  "https://ambientcg.com/get?file=Concrete036_1K-JPG_Color.jpg"

curl -L -o assets/textures/concrete/concrete_normal.jpg \
  "https://ambientcg.com/get?file=Concrete036_1K-JPG_NormalGL.jpg"

curl -L -o assets/textures/concrete/concrete_roughness.jpg \
  "https://ambientcg.com/get?file=Concrete036_1K-JPG_Roughness.jpg"

# Rusty metal
curl -L -o assets/textures/metal/rust_albedo.jpg \
  "https://ambientcg.com/get?file=Metal009_1K-JPG_Color.jpg"

curl -L -o assets/textures/metal/rust_normal.jpg \
  "https://ambientcg.com/get?file=Metal009_1K-JPG_NormalGL.jpg"

curl -L -o assets/textures/metal/rust_roughness.jpg \
  "https://ambientcg.com/get?file=Metal009_1K-JPG_Roughness.jpg"
```

Если ambientCG недоступен — используй fallback через solid color materials (см. C.2).

### C.2 Создай материалы в assets/materials/

Создай 4 файла через `create_file`:

**assets/materials/concrete_wall.tres**:
```
[gd_resource type="StandardMaterial3D" load_steps=2 format=3]

[ext_resource type="Texture2D" path="res://assets/textures/concrete/concrete_albedo.jpg" id="1"]

[resource]
albedo_color = Color(0.55, 0.52, 0.48, 1)
albedo_texture = ExtResource("1")
metallic = 0.0
roughness = 0.9
uv1_scale = Vector3(2, 2, 2)
```

**assets/materials/concrete_floor.tres**: аналогично, `uv1_scale = Vector3(4, 4, 4)`, `albedo_color = Color(0.35, 0.33, 0.30, 1)`

**assets/materials/rusty_metal.tres**: textures из metal/, `metallic = 0.6`, `roughness = 0.7`

**assets/materials/door_metal.tres**: `albedo_color = Color(0.25, 0.22, 0.20, 1)`, `metallic = 0.8`, `roughness = 0.4`

Если текстуры не скачались — используй только `albedo_color` без текстур (fallback).

### C.3 Коммит
```bash
git commit -am "feat: concrete and metal materials with PBR textures"
```

---

## PHASE D — ПЕРЕСОЗДАНИЕ BUNKER_ENTRANCE

### D.1 Удали старый и создай с нуля
```bash
rm scenes/levels/bunker_entrance.tscn
rm scenes/levels/bunker_entrance.tscn.uid 2>/dev/null || true
```

### D.2 Создай правильную комнату 6x4x3м

Полный `scenes/levels/bunker_entrance.tscn`:

```
[gd_scene load_steps=10 format=3 uid="uid://bbunker01"]

[ext_resource type="Material" path="res://assets/materials/concrete_wall.tres" id="1"]
[ext_resource type="Material" path="res://assets/materials/concrete_floor.tres" id="2"]
[ext_resource type="Material" path="res://assets/materials/rusty_metal.tres" id="3"]
[ext_resource type="Material" path="res://assets/materials/door_metal.tres" id="4"]
[ext_resource type="PackedScene" path="res://addons/player/player.tscn" id="5"]
[ext_resource type="PackedScene" path="res://addons/game_pieces/amnesia_door/amnesia_door.tscn" id="6"]
[ext_resource type="PackedScene" path="res://addons/game_pieces/interactable_door/interactable_door.tscn" id="7"]

[sub_resource type="BoxMesh" id="BoxMesh_floor"]
size = Vector3(6, 0.2, 4)

[sub_resource type="BoxShape3D" id="BoxShape3D_floor"]
size = Vector3(6, 0.2, 4)

[node name="BunkerEntrance" type="Node3D"]

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_01")

[node name="Floor" type="StaticBody3D" parent="."]

[node name="FloorMesh" type="MeshInstance3D" parent="Floor"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("BoxMesh_floor")
surface_material_override/0 = ExtResource("2")

[node name="FloorCollision" type="CollisionShape3D" parent="Floor"]
shape = SubResource("BoxShape3D_floor")

# Ceiling
[node name="Ceiling" type="StaticBody3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 0)

[node name="CeilingMesh" type="MeshInstance3D" parent="Ceiling"]
mesh = SubResource("BoxMesh_floor")
surface_material_override/0 = ExtResource("1")

[node name="CeilingCollision" type="CollisionShape3D" parent="Ceiling"]
shape = SubResource("BoxShape3D_floor")

# Walls (4 штуки — используй CSGBox3D с use_collision=true для простоты)
[node name="WallNorth" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, -2)
size = Vector3(6, 3, 0.2)
use_collision = true
material = ExtResource("1")

[node name="WallSouth" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 2)
size = Vector3(6, 3, 0.2)
use_collision = true
material = ExtResource("1")

[node name="WallEast" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3, 1.5, 0)
size = Vector3(0.2, 3, 4)
use_collision = true
material = ExtResource("1")

[node name="WallWest" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -3, 1.5, 0)
size = Vector3(0.2, 3, 4)
use_collision = true
material = ExtResource("1")

# Лампа с мерцанием
[node name="FlickerLamp" type="OmniLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.7, 0)
light_color = Color(1, 0.85, 0.6, 1)
light_energy = 2.0
omni_range = 6.0

[node name="LampAnimation" type="AnimationPlayer" parent="FlickerLamp"]
# Настрой анимацию мерцания: light_energy 2.0 → 0.3 → 2.0 → 0.1 → 2.0 в loop

# Стол
[node name="Table" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.5, 0.4, -1.5)
size = Vector3(1.2, 0.8, 0.6)
use_collision = true
material = ExtResource("3")

# Spawn точка игрока
[node name="PlayerSpawn" type="Marker3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1.5)

[node name="Player" parent="." instance=ExtResource("5")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1.5)

# Входная дверь (заперта)
[node name="EntranceDoor" parent="." instance=ExtResource("7")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1.9)

# Ящик с фонариком
[node name="FlashlightDrawer" parent="." instance=ExtResource("6")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2.8, 0.8, 0)
```

**ВАЖНО**: Environment создай через SubResource с:
- background_mode = 1 (Sky с чёрным)
- ambient_light_color = Color(0.05, 0.05, 0.07)
- ambient_light_energy = 0.3
- fog_enabled = true, fog_density = 0.05, fog_color тёмный
- tonemap_mode = 2 (Filmic)
- glow_enabled = true

### D.3 Установи main scene
В `project.godot` в секции `[application]`:
```
run/main_scene="res://scenes/levels/bunker_entrance.tscn"
```

### D.4 Коммит
```bash
git commit -am "feat: rebuild bunker_entrance with proper geometry, materials and lighting"
```

---

## PHASE E — УСТАНОВКА KENNEY ASSETS (бонусная визуалка)

### E.1 Скачай Kenney Industrial Kit
```bash
mkdir -p assets/models/kenney
cd assets/models/kenney

# Kenney CC0 Industrial Kit — модели для индустриальных помещений
curl -L -o industrial-kit.zip \
  "https://kenney.nl/media/pages/assets/industrial-kit/6cc53d97ae-1677586195/industrial-kit.zip"

unzip -o industrial-kit.zip -d industrial/
rm industrial-kit.zip

# Prototype Textures — базовые текстуры для быстрой разработки
curl -L -o prototype.zip \
  "https://kenney.nl/media/pages/assets/prototype-textures/3c0ac5bb4e-1677693527/prototype-textures.zip"

unzip -o prototype.zip -d prototype/
rm prototype.zip

cd ../../..
```

Если curl не скачивает (404, firewall) — пропусти этот шаг, игра будет на CSG материалах.

### E.2 Импортируй модели
Godot автоматически импортирует .obj/.fbx при первом запуске. Просто убедись что файлы на месте:
```bash
ls -la assets/models/kenney/industrial/ 2>/dev/null | head -10
```

### E.3 Коммит
```bash
git commit -am "feat: add Kenney CC0 industrial kit and prototype textures"
```

---

## PHASE F — ДОРАБОТКА ВТОРОЙ КОМНАТЫ

### F.1 Пересоздай bunker_corridor.tscn
Аналогично bunker_entrance, но:
- Размер 10м x 2.5м x 2.8м (длинный коридор)
- Только ОДНА рабочая лампа в начале, остальные выключены
- Надпись "ОНИ СЛЫШАТ" на стене (Label3D с красным цветом)
- На полу: батарейка (CSGBox3D 0.1x0.05x0.03 с rusty_metal материалом + Area3D для подбора)
- Дверь соединения с bunker_entrance
- Тумaнность fog_density = 0.15 (сильнее)

### F.2 Соедини сцены
В двери `EntranceDoor` в bunker_entrance добавь скрипт: при открытии → загрузить bunker_corridor.

### F.3 Коммит
```bash
git commit -am "feat: bunker_corridor with atmosphere and progression"
```

---

## PHASE G — ТЕСТИРОВАНИЕ И САМОПРОВЕРКА

### G.1 Проверь что всё работает
```bash
# Проверь что Godot парсит project.godot без ошибок
# (headless режим если установлен Godot в PATH)
which godot && godot --headless --check-only --path . 2>&1 | head -30

# Если нет Godot — просто проверь синтаксис .gd файлов
for f in $(find systems -name "*.gd"); do
  echo "=== $f ==="
  head -3 "$f"
done
```

### G.2 Создай TEST_CHECKLIST.md
Напиши файл TEST_CHECKLIST.md с пунктами что юзер должен проверить в Godot:
```markdown
# Чеклист ручной проверки в Godot 4.6

## Запуск
- [ ] Открыть project.godot в Godot 4.6
- [ ] Никаких критических ошибок при загрузке (warnings OK)
- [ ] F5 → стартует bunker_entrance

## Графика
- [ ] Видно бетонный пол, стены, потолок (не зелёная трава!)
- [ ] Лампа мерцает
- [ ] Виден стол, ящик, дверь
- [ ] Игрок видит сцену от первого лица

## Механики
- [ ] WASD — движение
- [ ] Мышь — поворот камеры
- [ ] Shift — спринт
- [ ] Ctrl — присесть
- [ ] E — взаимодействие (у двери, ящика)
- [ ] Tab — открыть инвентарь
- [ ] F — фонарик (после подбора)

## Системы
- [ ] Открытие ящика → фонарик в инвентарь
- [ ] Включение фонарика → свет работает
- [ ] Стоять в темноте → паранойя растёт (смотри в debug если нет UI)
- [ ] Записка на столе → открывается note_viewer
```

### G.3 Коммит
```bash
git commit -am "docs: add test checklist for manual verification"
```

---

## PHASE H — ФИНАЛЬНЫЙ ОТЧЁТ

### H.1 Создай FINAL_REPORT.md в корне проекта

```markdown
# Paranoia Protocol: Bunker — Сессия Fix & Upgrade

## Что сделано в этой сессии

### Починено
- [статус] Talo addon отключён
- [статус] Warnings в EventBus (12 сигналов)
- [статус] Integer division в GameManager
- [статус] Типизация SaveManager

### Добавлено
- [статус] 4 PBR материала (concrete_wall, concrete_floor, rusty_metal, door_metal)
- [статус] Текстуры ambientCG (concrete, metal) — [скачаны / fallback на solid]
- [статус] Kenney Industrial Kit — [скачан / пропущен]

### Пересоздано
- [статус] bunker_entrance.tscn (правильная геометрия 6x4x3м)
- [статус] bunker_corridor.tscn (10м коридор)
- [статус] Main scene указывает на bunker_entrance

## Статистика
- Commits в этой сессии: [число]
- Строк кода: [число]
- Новых файлов: [число]

## Что осталось (next session)
- [ ] Анимация мерцания лампы (настроить AnimationPlayer вручную в Godot)
- [ ] NPC система (Phase 3)
- [ ] Audio sources с real .ogg файлами
- [ ] Save slots UI
- [ ] Подключение Kenney моделей к сценам

## Что нужно проверить юзеру вручную
См. TEST_CHECKLIST.md
```

### H.2 Push на GitHub
```bash
git push origin master 2>&1 || echo "Push failed, check remote"
```

### H.3 Финальный коммит
```bash
git add -A
git commit -am "docs: final session report with status of all fixes"
git push
```

---

## ГЛАВНЫЕ ПРАВИЛА РАБОТЫ

1. **Если что-то не скачивается** — не ломай проект, сделай fallback и зафиксируй в отчёте
2. **Никаких вопросов** — ты работаешь автономно, используй свои `--dangerously-skip-permissions`
3. **Коммить часто** — после каждой phase отдельный коммит
4. **Следуй Karpathy guidelines**: минимум кода, хирургические правки, не рефакторь то что не сломано
5. **Если упираешься в стенку** — зафиксируй проблему в FINAL_REPORT.md и продолжай следующую phase

**Погнали! Удачи!**
