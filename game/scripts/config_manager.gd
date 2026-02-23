extends Node

# 全局配置管理器，从 JSON 加载所有游戏平衡数值
# 修改 config/game_config.json 即可调整游戏难度，无需改代码

const CONFIG_PATH := "res://config/game_config.json"

var _data: Dictionary = {}

# 预构建的类型映射（string key → enum index）
var _building_keys: Array = ["gold_mine", "barracks", "cannon", "tavern"]
var _unit_keys: Array = ["infantry", "tank", "artillery"]
var _commander_keys: Array = ["balanced", "producer", "firepower"]
var _relic_keys: Array = [
	"gold_boost", "damage_boost", "speed_boost", "hp_boost",
	"prod_speed", "attack_speed", "merge_discount", "extra_life"
]


func _ready() -> void:
	_load_config()


func _load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		push_error("ConfigManager: config file not found at " + CONFIG_PATH)
		return
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json_text := file.get_as_text()
	file.close()

	var result = JSON.parse_string(json_text)
	if result == null:
		push_error("ConfigManager: failed to parse JSON config")
		return
	_data = result


func reload() -> void:
	_load_config()


# --- 通用访问器（点分路径） ---

func get_value(path: String, default_value = null):
	var keys: PackedStringArray = path.split(".")
	var current = _data
	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return default_value
	return current


# --- 颜色工具 ---

func arr_to_color(arr: Array) -> Color:
	if arr.size() >= 3:
		return Color(arr[0], arr[1], arr[2])
	return Color.WHITE


# --- Grid ---

func grid_cols() -> int:
	return get_value("grid.cols", 6)

func grid_rows() -> int:
	return get_value("grid.rows", 8)

func grid_cell_size() -> int:
	return get_value("grid.cell_size", 64)

func grid_viewport_width() -> int:
	return get_value("grid.viewport_width", 720)

func grid_offset_y() -> float:
	return get_value("grid.offset_y", 100.0)


# --- Economy ---

func starting_gold() -> int:
	return get_value("economy.starting_gold", 200)

func gold_mine_output() -> int:
	return get_value("economy.gold_mine_output", 10)

func adjacent_buff() -> float:
	return get_value("economy.adjacent_buff", 0.2)

func merge_discount_ratio() -> float:
	return get_value("economy.merge_discount_ratio", 0.5)

func wave_clear_base_bonus() -> int:
	return get_value("economy.wave_clear_base_bonus", 30)

func wave_clear_bonus_per_wave() -> int:
	return get_value("economy.wave_clear_bonus_per_wave", 10)

func enemy_kill_base_reward() -> int:
	return get_value("economy.enemy_kill_base_reward", 5)

func enemy_kill_reward_per_type() -> int:
	return get_value("economy.enemy_kill_reward_per_type", 5)


# --- Buildings（按枚举索引查询） ---

func building_data(enum_idx: int) -> Dictionary:
	if enum_idx < 0 or enum_idx >= _building_keys.size():
		return {}
	var key: String = _building_keys[enum_idx]
	return get_value("buildings." + key, {})

func building_cost(enum_idx: int) -> int:
	return building_data(enum_idx).get("cost", 100)

func building_name(enum_idx: int) -> String:
	return building_data(enum_idx).get("name", "???")

func building_color(enum_idx: int) -> Color:
	var data := building_data(enum_idx)
	return arr_to_color(data.get("color", [0.5, 0.5, 0.5]))

func building_production_interval(enum_idx: int) -> float:
	return building_data(enum_idx).get("production_interval", 5.0)


# --- Units（按枚举索引查询） ---

func unit_data(enum_idx: int) -> Dictionary:
	if enum_idx < 0 or enum_idx >= _unit_keys.size():
		return {}
	var key: String = _unit_keys[enum_idx]
	return get_value("units.types." + key, {})

func unit_max_level() -> int:
	return get_value("units.max_level", 3)

func unit_level_speed_bonus() -> float:
	return get_value("units.level_speed_bonus", 0.2)

func unit_scale_base() -> float:
	return get_value("units.scale_base", 0.8)

func unit_scale_per_level() -> float:
	return get_value("units.scale_per_level", 0.25)


# --- Enemies（按类型索引查询） ---

func enemy_data(type_idx: int) -> Dictionary:
	var types: Array = get_value("enemies.types", [])
	if type_idx < 0 or type_idx >= types.size():
		return {}
	return types[type_idx]

func enemy_type_count() -> int:
	return get_value("enemies.types", []).size()


# --- Combat ---

func counter_bonus() -> float:
	return get_value("combat.counter_bonus", 1.5)

func counter_penalty() -> float:
	return get_value("combat.counter_penalty", 0.7)

func level_multiplier_base() -> float:
	return get_value("combat.level_multiplier_base", 2.0)


# --- Battlefield ---

func battlefield_left() -> float:
	return get_value("battlefield.left_boundary", 50.0)

func battlefield_right() -> float:
	return get_value("battlefield.right_boundary", 720.0)

func spawn_y_min() -> float:
	return get_value("battlefield.spawn_y_min", 130.0)

func spawn_y_max() -> float:
	return get_value("battlefield.spawn_y_max", 580.0)

func spawn_x_offset() -> float:
	return get_value("battlefield.spawn_x_offset", 30.0)

func unit_exit_offset() -> float:
	return get_value("battlefield.unit_exit_offset", 50.0)

func max_breaches() -> int:
	return get_value("battlefield.max_breaches", 5)

func merge_distance() -> float:
	return get_value("battlefield.merge_distance", 40.0)


# --- Waves ---

func wave_base_enemy_count() -> int:
	return get_value("waves.base_enemy_count", 3)

func wave_enemies_per_wave() -> int:
	return get_value("waves.enemies_per_wave", 2)

func wave_spawn_delay() -> float:
	return get_value("waves.spawn_delay", 0.8)

func wave_difficulty_scaling() -> float:
	return get_value("waves.difficulty_scaling_per_wave", 0.15)

func wave_spawn_rules() -> Array:
	return get_value("waves.spawn_rules", [])


# --- Relics（按枚举索引查询） ---

func relic_data(enum_idx: int) -> Dictionary:
	if enum_idx < 0 or enum_idx >= _relic_keys.size():
		return {}
	var key: String = _relic_keys[enum_idx]
	return get_value("relics.effects." + key, {})

func relic_effect_value(enum_idx: int) -> float:
	return relic_data(enum_idx).get("value", 0.0)

func relic_choices_per_wave() -> int:
	return get_value("relics.choices_per_wave", 3)


# --- Commanders（按枚举索引查询） ---

func commander_data(enum_idx: int) -> Dictionary:
	if enum_idx < 0 or enum_idx >= _commander_keys.size():
		return {}
	var key: String = _commander_keys[enum_idx]
	return get_value("commanders." + key, {})

func commander_bonus(enum_idx: int, stat: String) -> float:
	var data := commander_data(enum_idx)
	var bonuses: Dictionary = data.get("bonuses", {})
	return bonuses.get(stat, 0.0)
