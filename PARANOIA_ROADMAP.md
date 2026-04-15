# PARANOIA PROTOCOL: BUNKER — Пошаговый план разработки
# Этот файл — детальная инструкция для Claude Code
# Каждый шаг — отдельный промпт. Выполняй по порядку.

---

## PHASE 1 — FOUNDATION (Базовые настройки)

### 1.1 Настройка project.godot
- Убедись что config/name = "Paranoia Protocol: Bunker"
- Установи window/size/viewport_width = 1920
- Установи window/size/viewport_height = 1080
- Установи window/stretch/mode = "canvas_items"
- Установи application/config/description = "Psychological horror FPS set in an underground bunker"
- Установи application/boot_splash/bg_color = Color(0, 0, 0, 1) (чёрный)

### 1.2 Структура папок (если не создана)
Создай папки:
- systems/paranoia/
- systems/inventory/
- systems/flashlight/
- systems/npc/
- systems/audio/
- systems/save/
- systems/events/
- scenes/levels/
- scenes/ui/
- scenes/props/
- assets/textures/
- assets/fonts/
- assets/materials/
- assets/audio/ambience/
- assets/audio/sfx/
- assets/audio/music/

### 1.3 EventBus (глобальная шина событий)
Создай файл: systems/events/event_bus.gd
```
Autoload синглтон "EventBus"
Сигналы:
- paranoia_changed(new_value: float)
- item_collected(item_name: String)
- item_used(item_name: String)
- flashlight_toggled(is_on: bool)
- flashlight_battery_changed(percent: float)
- door_interaction(door_id: String, is_locked: bool)
- note_found(note_id: String)
- npc_trust_changed(npc_id: String, trust: float)
- hallucination_triggered(type: String)
- checkpoint_reached(checkpoint_id: String)
- game_saved()
- game_loaded()
```
Зарегистрируй EventBus как Autoload в project.godot.

### 1.4 GameManager (менеджер состояния игры)
Создай файл: systems/events/game_manager.gd
```
Autoload синглтон "GameManager"
Переменные:
- current_level: String = ""
- is_paused: bool = false
- game_time: float = 0.0
- difficulty: int = 1 (1=normal, 2=hard)

Функции:
- pause_game() / resume_game()
- change_level(level_path: String)
- get_play_time() -> String (форматированное время)
```
Зарегистрируй GameManager как Autoload в project.godot.

---

## PHASE 2 — CORE SYSTEMS (Ключевые механики)

### 2.1 Система паранойи (systems/paranoia/)

#### 2.1.1 paranoia_manager.gd
```
Autoload синглтон "ParanoiaManager"
- paranoia_level: float = 0.0 (0.0 - 100.0)
- max_paranoia: float = 100.0
- decay_rate: float = 0.5 (в секунду, естественное снижение при свете)
- growth_rate: float = 1.0 (в секунду, рост в темноте)

Пороги эффектов:
- 0-20: Нормально (CALM)
- 20-40: Лёгкое беспокойство (UNEASY) — тихие шёпоты
- 40-60: Тревога (ANXIOUS) — лёгкое искажение экрана, тени двигаются
- 60-80: Страх (FEARFUL) — сильное искажение, слуховые галлюцинации
- 80-100: Паника (PANIC) — экран трясётся, ложные враги, двери "исчезают"

Функции:
- add_paranoia(amount: float)
- reduce_paranoia(amount: float)
- get_state() -> String ("CALM"/"UNEASY"/"ANXIOUS"/"FEARFUL"/"PANIC")
- _process(delta): авто-рост в темноте, авто-снижение при свете

Сигналы испускать через EventBus.
```

#### 2.1.2 paranoia_effects.gd (Node, добавляется к Camera3D)
```
Визуальные эффекты в зависимости от paranoia_level:
- Виньетка (усиливается с ростом паранойи)
- Chromatic aberration (хроматическая аберрация)
- Дрожание камеры (интенсивность зависит от уровня)
- Шум/зернистость (grain)
- Случайные "глитчи" экрана на высоких уровнях

Использовать WorldEnvironment + шейдеры из shaders/
Подписаться на EventBus.paranoia_changed
```

#### 2.1.3 paranoia_audio.gd (Node для звуковых эффектов)
```
Звуковые эффекты по порогам:
- UNEASY: Тихий ambient гул
- ANXIOUS: Шёпоты (случайные, тихие)
- FEARFUL: Громкие стуки, дыхание
- PANIC: Крики, скрежет

Использовать AudioStreamPlayer для каждого слоя
Плавный crossfade между уровнями
```

### 2.2 Система фонарика (systems/flashlight/)

#### 2.2.1 flashlight_system.gd
```
Добавляется как child к Player Head/Camera3D
- is_on: bool = false
- battery: float = 100.0 (0.0 - 100.0)
- drain_rate: float = 2.0 (% в секунду)
- recharge_amount: float = 50.0 (от батарейки)
- flicker_threshold: float = 15.0 (начинает мерцать)

Компоненты:
- SpotLight3D (угол 35°, дальность 12м, цвет тёплый жёлтый)
- AudioStreamPlayer3D (звук щелчка вкл/выкл)

Функции:
- toggle() — вкл/выкл (клавиша F)
- drain(delta) — расход батареи
- recharge(amount) — подзарядка от батарейки
- _flicker_effect() — мерцание при низком заряде

Влияние на паранойю:
- Фонарик ВКЛ + батарея > 20%: paranoia decay_rate * 1.5
- Фонарик ВЫКЛ или батарея < 10%: paranoia growth_rate * 2.0

Испускать сигналы через EventBus.
```

### 2.3 Система инвентаря (systems/inventory/)

#### 2.3.1 item_resource.gd (Resource)
```
extends Resource
class_name ItemResource
- item_name: String
- item_description: String (на русском)
- item_icon: Texture2D
- item_type: enum {CONSUMABLE, KEY_ITEM, NOTE, BATTERY, TOOL}
- is_stackable: bool
- max_stack: int = 1
- use_action: String (имя функции для вызова)
```

#### 2.3.2 inventory_manager.gd (Autoload)
```
Autoload "InventoryManager"
- items: Array[Dictionary] = [] (каждый: {resource: ItemResource, count: int})
- max_slots: int = 8

Функции:
- add_item(item: ItemResource, count: int = 1) -> bool
- remove_item(item_name: String, count: int = 1) -> bool
- has_item(item_name: String) -> bool
- get_item_count(item_name: String) -> int
- use_item(item_name: String)
- get_all_items() -> Array

Испускать сигналы через EventBus.
```

#### 2.3.3 inventory_ui.gd + inventory_ui.tscn (scenes/ui/)
```
Control нода, открывается по клавише Tab/I
- Сетка 2x4 слотов
- Каждый слот: TextureRect + Label (количество)
- Описание выбранного предмета внизу
- Кнопка "Использовать"
- Анимация открытия/закрытия
- Во время инвентаря — пауза (get_tree().paused = true)

Стилизация:
- Тёмный полупрозрачный фон
- Шрифт: любой с поддержкой кириллицы
- Цвета: серый/зелёный милитари стиль
```

### 2.4 Система записок (systems/inventory/)

#### 2.4.1 note_resource.gd (Resource)
```
extends Resource
class_name NoteResource
- note_id: String
- title: String (русский)
- content: String (русский, многострочный текст)
- is_read: bool = false
```

#### 2.4.2 note_viewer_ui.gd + note_viewer_ui.tscn (scenes/ui/)
```
Полноэкранное окно с текстом записки
- Фон: текстура мятой бумаги
- Шрифт: рукописный или печатная машинка
- Кнопка "Закрыть" (Esc)
- Опционально: звук открытия бумаги
```

---

## PHASE 3 — ПЕРВЫЙ УРОВЕНЬ (bunker_entrance)

### 3.1 Комната входа (scenes/levels/bunker_entrance.tscn)
```
Размер: 6м x 4м x 3м (длина x ширина x высота)
Материалы: бетон, ржавый металл

Объекты:
1. Стены — CSGBox3D или MeshInstance3D, материал бетона
2. Пол — бетон с трещинами
3. Потолок — бетон с трубами
4. Входная дверь (позади игрока) — LockableInteractableDoor, ЗАБЛОКИРОВАНА снаружи
5. Дверь дальше — InteractableDoor, ведёт в следующую комнату
6. Мигающая лампа — OmniLight3D + AnimationPlayer:
   - Цикл: вкл 2с → мерцание 0.5с → выкл 1с → вкл
   - Тёплый жёлтый цвет, радиус 4м
7. Стол — CSGBox3D (1.2м x 0.6м x 0.8м)
8. Записка на столе — Area3D + CollisionShape3D:
   - При взаимодействии: открывает note_viewer
   - Текст: "День 1. Дверь захлопнулась. Снаружи что-то происходит. 
     Нашёл фонарик, но батарейки почти сели. 
     Нужно найти выход. Не доверяй теням."
9. Ящик — AmnesiaDrawer с фонариком внутри (ItemResource type: TOOL)
10. Труба на стене — слегка подтекает (ParticleSystem, капли воды)
11. Вентиляция — звук гула (AudioStreamPlayer3D, loop)

Освещение:
- Основное: мигающая лампа
- Дополнительно: слабый DirectionalLight (имитация дальнего света)
- WorldEnvironment: тёмный, fog слабый

Spawn точка игрока:
- Marker3D "PlayerSpawn" у входной двери, лицом к комнате

Триггеры:
- При подборе фонарика: туториал "Нажмите F для фонарика"
- При чтении записки: paranoia += 10
```

### 3.2 Комната коридора (scenes/levels/bunker_corridor.tscn)
```
Размер: 10м x 2.5м x 2.8м (узкий длинный коридор)

Объекты:
1. Длинный коридор с поворотом
2. Одна работающая лампа в начале
3. Разбитые лампы дальше (полная темнота)
4. Труба с паром (ParticleSystem + звук)
5. Запертая дверь сбоку (нужен ключ — найдётся позже)
6. Дверь в конце — ведёт в следующую зону
7. На полу: батарейка для фонарика (ItemResource type: BATTERY)
8. Надпись на стене: "ОНИ СЛЫШАТ" (кровью/краской)

Эффекты:
- При входе в тёмную зону: paranoia += 5/сек
- Случайный звук шагов за спиной (hallucination при paranoia > 30)
- Мерцание дальней лампы когда игрок приближается
```

### 3.3 HUD (scenes/ui/game_hud.tscn)
```
Элементы:
1. Индикатор батареи фонарика (правый нижний угол):
   - Иконка батарейки + полоска заряда
   - Зелёный > 50%, жёлтый 20-50%, красный < 20%

2. Индикатор паранойи (левый нижний угол):
   - НЕ числовой! Визуальная подсказка:
   - Иконка глаза, меняет цвет: белый → жёлтый → оранжевый → красный
   - При высокой паранойе: иконка пульсирует

3. Подсказка взаимодействия (центр экрана, снизу):
   - "[E] Открыть" / "[E] Подобрать" / "[E] Прочитать"
   - Появляется при наведении на интерактивный объект

4. Кроссхейр (центр экрана):
   - Маленькая точка, белая
   - Меняет цвет при наведении на объект

5. Уведомления (верх экрана):
   - "Подобрано: Фонарик"
   - "Батарея пополнена"
   - Fadeout через 3 секунды
```

---

## PHASE 4 — SAVE/LOAD & POLISH

### 4.1 Система сохранения (systems/save/)

#### 4.1.1 save_manager.gd (Autoload)
```
Autoload "SaveManager"
Сохраняет в user://saves/

Данные для сохранения:
- player_position: Vector3
- player_rotation: Vector3
- current_level: String
- paranoia_level: float
- flashlight_battery: float
- inventory_items: Array
- read_notes: Array[String]
- opened_doors: Array[String]
- game_time: float

Функции:
- save_game(slot: int = 0)
- load_game(slot: int = 0)
- has_save(slot: int = 0) -> bool
- delete_save(slot: int = 0)
- auto_save() — вызывается при checkpoint_reached
```

### 4.2 Настройка PSX шейдеров
```
В shaders/ уже есть:
- psx_post_process — PS1 стиль
- retro — даунскейл
- tv_static_border — ТВ помехи

Задачи:
- Настроить psx_post_process: снизить разрешение текстур, vertex snapping
- tv_static_border: активировать на высоких уровнях паранойи
- Добавить CRT-эффект для экрана паузы
```

### 4.3 Меню (адаптация шаблона)
```
В scenes/menus/ уже есть полная система.
Нужно:
- Заменить текст на русский: "Новая игра", "Продолжить", "Настройки", "Выход"
- Добавить пункт "Загрузить" если есть сохранение
- Фон главного меню: тёмный бункер, мигающий свет
- Музыка: тревожный ambient
```

---

## PHASE 5 — CONTENT & АТМОСФЕРА

### 5.1 Дополнительные записки (создать NoteResource для каждой)
```
Записка 1 (bunker_entrance): "День 1. Дверь захлопнулась..."
Записка 2 (bunker_corridor): "День 3. Вода всё ещё идёт из труб..."
Записка 3 (будущая комната): "День 7. Слышу голоса за стеной. Наверное показалось."
Записка 4: "День 12. Кто-то был здесь пока я спал. Вещи переставлены."
Записка 5: "День ?. Не помню какой сегодня день. Фонарик мигает."
```

### 5.2 Аудио-дизайн
```
Нужные звуки (placeholder или сгенерировать):
- ambience_bunker_loop.ogg — гул вентиляции, тихий drone
- drip_water.ogg — капли воды
- door_metal_open.ogg — металлическая дверь
- door_metal_close.ogg
- drawer_open.ogg — ящик
- flashlight_click.ogg — щелчок фонарика
- footstep_concrete_*.ogg — шаги по бетону (3-4 варианта)
- whisper_*.ogg — шёпоты для паранойи (3-4 варианта)
- heartbeat.ogg — сердцебиение для высокой паранойи
- paper_pickup.ogg — подбор записки
- breath_heavy.ogg — тяжёлое дыхание
- metal_bang.ogg — удар по металлу (галлюцинация)
```

---

## ПОРЯДОК ВЫПОЛНЕНИЯ ДЛЯ CLAUDE CODE

Выполняй строго по порядку. После каждого шага — коммит в git.

1. Phase 1.1 → настрой project.godot
2. Phase 1.2 → создай папки
3. Phase 1.3 → создай EventBus
4. Phase 1.4 → создай GameManager
5. Phase 2.1.1 → создай ParanoiaManager
6. Phase 2.2.1 → создай FlashlightSystem
7. Phase 2.3.1 → создай ItemResource
8. Phase 2.3.2 → создай InventoryManager
9. Phase 2.4.1 → создай NoteResource
10. Phase 3.3 → создай HUD
11. Phase 3.1 → создай bunker_entrance
12. Phase 3.2 → создай bunker_corridor
13. Phase 2.3.3 → создай inventory_ui
14. Phase 2.4.2 → создай note_viewer_ui
15. Phase 2.1.2 → создай paranoia_effects (шейдеры)
16. Phase 2.1.3 → создай paranoia_audio
17. Phase 4.1 → создай SaveManager
18. Phase 4.3 → русифицируй меню
19. Phase 5.1 → создай записки
20. Финальный коммит: "Phase 1-5 complete — Paranoia Protocol: Bunker foundation"
