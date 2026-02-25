extends Node

signal gold_changed(new_amount: int)
signal game_state_changed(new_state: GameState)
signal building_selected(type: BuildingType)
signal unit_spawn_requested(world_pos: Vector2, unit_type: UnitType, level: int)
signal tower_destroyed(tower_id: int)
signal region_unlocked(region: int)
signal all_towers_cleared
signal enemy_breached
signal relic_chosen(relic_type: RelicType)
signal commander_changed(cmd: Commander)
signal game_speed_changed(new_speed: float)
signal remove_mode_changed(enabled: bool)

enum GameState { SETUP, PLAYING, RELIC_SELECT, VICTORY, GAME_OVER }
enum BuildingType { GOLD_MINE, BARRACKS, CANNON, TAVERN, DOCK, AIRFIELD }
enum UnitType { INFANTRY, TANK, ARTILLERY, MARINE, AIR_FORCE }
enum RelicType {
	GOLD_BOOST, DAMAGE_BOOST, SPEED_BOOST, HP_BOOST,
	PROD_SPEED, ATTACK_SPEED, MERGE_DISCOUNT, EXTRA_LIFE,
}
enum Commander { BALANCED, PRODUCER, FIREPOWER }

# ====== 从 Cfg 加载的常量 ======

var GRID_COLS: int = 8
var GRID_ROWS: int = 2
var GRID_MAX_ROWS: int = 8
var CELL_SIZE: int = 64

var BUILDING_COSTS: Dictionary = {}
var BUILDING_NAMES: Dictionary = {}
var BUILDING_COLORS: Dictionary = {}
var PRODUCTION_INTERVALS: Dictionary = {}

var GOLD_MINE_OUTPUT: int = 10
var ADJACENT_BUFF: float = 0.2

var UNIT_NAMES: Dictionary = {}
var UNIT_BASE_STATS: Dictionary = {}
var UNIT_ATTACK_RANGES: Dictionary = {}
var UNIT_ATTACK_COOLDOWNS: Dictionary = {}
var UNIT_VISION_RANGES: Dictionary = {}
var UNIT_MOVE_TYPES: Dictionary = {}
var UNIT_COLORS: Dictionary = {}
var UNIT_LABELS: Dictionary = {}
var MAX_UNIT_LEVEL: int = 3

var ENEMY_TYPES: Dictionary = {}
var ENEMY_TOWER_TYPES: Array = []

var COUNTER_BONUS: float = 1.5
var COUNTER_PENALTY: float = 0.7

var MERGE_DISTANCE: float = 40.0
var BATTLEFIELD_TOP: float = -400.0
var BATTLEFIELD_BOTTOM: float = 680.0

var RELIC_DATA: Dictionary = {}
var COMMANDER_DATA: Dictionary = {}

# ====== 运行时状态 ======

var active_relics: Array = []
var elapsed_time: float = 0.0
var breach_count: int = 0
var max_breaches: int = 5

var current_game_speed: float = 1.0
var _pre_pause_speed: float = 1.0
var is_remove_mode: bool = false

var current_commander: Commander = Commander.BALANCED:
	set(value):
		current_commander = value
		commander_changed.emit(value)

var gold: int = 2000:
	set(value):
		gold = max(0, value)
		gold_changed.emit(gold)

var towers_destroyed: int = 0
var total_towers: int = 0
var current_region: int = 1

var state: GameState = GameState.SETUP:
	set(value):
		state = value
		game_state_changed.emit(state)

var selected_building: BuildingType = BuildingType.GOLD_MINE:
	set(value):
		selected_building = value
		building_selected.emit(value)


func _ready() -> void:
	_load_from_config()


func _process(delta: float) -> void:
	if state == GameState.PLAYING:
		elapsed_time += delta


func _load_from_config() -> void:
	GRID_COLS = Cfg.grid_cols()
	GRID_ROWS = Cfg.grid_initial_rows()
	GRID_MAX_ROWS = Cfg.grid_max_rows()
	CELL_SIZE = Cfg.grid_cell_size()

	for btype in [BuildingType.GOLD_MINE, BuildingType.BARRACKS, BuildingType.CANNON, BuildingType.TAVERN, BuildingType.DOCK, BuildingType.AIRFIELD]:
		BUILDING_COSTS[btype] = Cfg.building_cost(btype)
		BUILDING_NAMES[btype] = Cfg.building_name(btype)
		BUILDING_COLORS[btype] = Cfg.building_color(btype)
		PRODUCTION_INTERVALS[btype] = Cfg.building_production_interval(btype)

	GOLD_MINE_OUTPUT = Cfg.gold_mine_output()
	ADJACENT_BUFF = Cfg.adjacent_buff()

	for utype in [UnitType.INFANTRY, UnitType.TANK, UnitType.ARTILLERY, UnitType.MARINE, UnitType.AIR_FORCE]:
		var d: Dictionary = Cfg.unit_data(utype)
		UNIT_BASE_STATS[utype] = {"hp": d.get("hp", 50), "damage": d.get("damage", 15), "speed": d.get("speed", 40)}
		UNIT_ATTACK_RANGES[utype] = d.get("attack_range", 35.0)
		UNIT_ATTACK_COOLDOWNS[utype] = d.get("attack_cooldown", 1.0)
		UNIT_VISION_RANGES[utype] = d.get("vision_range", 200.0)
		UNIT_MOVE_TYPES[utype] = d.get("move_type", "land")
		UNIT_COLORS[utype] = Cfg.arr_to_color(d.get("color", [0.5, 0.5, 0.5]))
		UNIT_LABELS[utype] = d.get("label", "?")
		UNIT_NAMES[utype] = d.get("name", "???")

	MAX_UNIT_LEVEL = Cfg.unit_max_level()

	for i in Cfg.enemy_type_count():
		var ed: Dictionary = Cfg.enemy_data(i)
		ENEMY_TYPES[i] = {
			"name": ed.get("name", "???"),
			"hp": ed.get("hp", 40),
			"damage": ed.get("damage", 8),
			"speed": ed.get("speed", 30),
			"color": Cfg.arr_to_color(ed.get("color", [0.7, 0.2, 0.2])),
			"attack_range": ed.get("attack_range", 25.0),
			"cooldown": ed.get("cooldown", 1.0),
		}

	ENEMY_TOWER_TYPES = Cfg.enemy_tower_types()

	COUNTER_BONUS = Cfg.counter_bonus()
	COUNTER_PENALTY = Cfg.counter_penalty()

	MERGE_DISTANCE = Cfg.merge_distance()
	BATTLEFIELD_TOP = Cfg.battlefield_top()
	BATTLEFIELD_BOTTOM = Cfg.battlefield_bottom()

	max_breaches = Cfg.max_breaches()
	gold = Cfg.starting_gold()

	for rtype in RelicType.values():
		var rd: Dictionary = Cfg.relic_data(rtype)
		RELIC_DATA[rtype] = {
			"name": rd.get("name", "???"),
			"desc": rd.get("desc", ""),
			"icon": rd.get("icon", "?"),
			"value": rd.get("value", 0.0),
			"color": Cfg.arr_to_color(rd.get("color", [0.5, 0.5, 0.5])),
		}

	for cmd in [Commander.BALANCED, Commander.PRODUCER, Commander.FIREPOWER]:
		var cd: Dictionary = Cfg.commander_data(cmd)
		COMMANDER_DATA[cmd] = {
			"name": cd.get("name", "???"),
			"desc": cd.get("desc", ""),
			"icon": cd.get("icon", "?"),
			"color": Cfg.arr_to_color(cd.get("color", [0.5, 0.5, 0.5])),
		}


# ====== 游戏速度控制 ======

func toggle_game_speed() -> void:
	if current_game_speed >= Cfg.game_speed_fast():
		set_game_speed(Cfg.game_speed_normal())
	else:
		set_game_speed(Cfg.game_speed_fast())

func set_game_speed(spd: float) -> void:
	current_game_speed = spd
	Engine.time_scale = spd
	game_speed_changed.emit(spd)

func pause_for_relic() -> void:
	_pre_pause_speed = current_game_speed
	Engine.time_scale = 0.0

func resume_from_relic() -> void:
	Engine.time_scale = _pre_pause_speed


# ====== 移除建筑模式 ======

func toggle_remove_mode() -> void:
	is_remove_mode = not is_remove_mode
	remove_mode_changed.emit(is_remove_mode)


# ====== 遗物效果倍率 ======

func get_gold_multiplier() -> float:
	var m := 1.0
	m += Cfg.commander_bonus(current_commander, "gold")
	m += active_relics.count(RelicType.GOLD_BOOST) * Cfg.relic_effect_value(RelicType.GOLD_BOOST)
	return m

func get_damage_multiplier() -> float:
	var m := 1.0
	m += Cfg.commander_bonus(current_commander, "damage")
	m += active_relics.count(RelicType.DAMAGE_BOOST) * Cfg.relic_effect_value(RelicType.DAMAGE_BOOST)
	return m

func get_speed_multiplier() -> float:
	var m := 1.0
	m += Cfg.commander_bonus(current_commander, "speed")
	m += active_relics.count(RelicType.SPEED_BOOST) * Cfg.relic_effect_value(RelicType.SPEED_BOOST)
	return m

func get_hp_multiplier() -> float:
	var m := 1.0
	m += Cfg.commander_bonus(current_commander, "hp")
	m += active_relics.count(RelicType.HP_BOOST) * Cfg.relic_effect_value(RelicType.HP_BOOST)
	return m

func get_production_multiplier() -> float:
	var m := 1.0
	m += Cfg.commander_bonus(current_commander, "production")
	m += active_relics.count(RelicType.PROD_SPEED) * Cfg.relic_effect_value(RelicType.PROD_SPEED)
	return m

func get_attack_speed_multiplier() -> float:
	var m := 1.0
	m += active_relics.count(RelicType.ATTACK_SPEED) * Cfg.relic_effect_value(RelicType.ATTACK_SPEED)
	return m

func has_merge_discount() -> bool:
	return RelicType.MERGE_DISCOUNT in active_relics

func add_relic(relic: RelicType) -> void:
	active_relics.append(relic)
	relic_chosen.emit(relic)

func pick_random_relics(count: int = 0) -> Array:
	if count <= 0:
		count = Cfg.relic_choices_per_wave()
	var pool: Array = RelicType.values()
	pool.shuffle()
	return pool.slice(0, mini(count, pool.size()))


# ====== 经济函数 ======

func can_afford(building_type: BuildingType) -> bool:
	return gold >= BUILDING_COSTS.get(building_type, 9999)

func can_afford_amount(amount: int) -> bool:
	return gold >= amount

func purchase_building(building_type: BuildingType) -> bool:
	if can_afford(building_type):
		gold -= BUILDING_COSTS[building_type]
		return true
	return false

func get_level_multiplier(level: int) -> float:
	return pow(Cfg.level_multiplier_base(), level - 1)

func get_remove_refund(building_type: BuildingType, level: int) -> int:
	var base_cost: int = BUILDING_COSTS.get(building_type, 0)
	var total_invested: float = base_cost * pow(2.0, level - 1)
	return int(total_invested * Cfg.building_remove_refund_ratio())


# ====== 防御塔相关 ======

func on_tower_destroyed_callback(tower_type: int) -> void:
	towers_destroyed += 1
	var bonus: int = Cfg.tower_destroy_base_bonus() + tower_type * Cfg.tower_destroy_bonus_per_level()
	gold += bonus
	tower_destroyed.emit(towers_destroyed)

	var victory_count: int = Cfg.map_victory_towers_destroyed()
	if towers_destroyed >= victory_count:
		state = GameState.VICTORY
		all_towers_cleared.emit()

func get_towers_progress() -> String:
	return "%d / %d" % [towers_destroyed, Cfg.map_victory_towers_destroyed()]


# ====== 突破/失败 ======

func on_enemy_breach() -> void:
	breach_count += 1
	enemy_breached.emit()
	if breach_count >= max_breaches:
		state = GameState.GAME_OVER

func add_extra_life() -> void:
	max_breaches += 1

func get_breach_remaining() -> int:
	return max_breaches - breach_count


# ====== 时间格式化 ======

func get_elapsed_time_string() -> String:
	var mins: int = int(elapsed_time) / 60
	var secs: int = int(elapsed_time) % 60
	return "%d:%02d" % [mins, secs]
