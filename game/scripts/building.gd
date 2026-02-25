extends Node

var building_type: int = 0
var grid_pos: Vector2i = Vector2i.ZERO
var level: int = 1
var adjacent_count: int = 0

var _production_timer: float = 0.0


func get_production_progress() -> float:
	var interval: float = GameManager.PRODUCTION_INTERVALS.get(building_type, 0.0)
	if interval <= 0.0:
		return 0.0
	var buff_mult: float = 1.0 + adjacent_count * Cfg.adjacent_buff()
	var production_mult: float = GameManager.get_production_multiplier()
	var effective_interval: float = interval / (buff_mult * production_mult)
	if effective_interval <= 0.0:
		return 0.0
	return clampf(_production_timer / effective_interval, 0.0, 1.0)


func init_building(type: int, pos: Vector2i) -> void:
	building_type = type
	grid_pos = pos
	name = "Building_%d_%d" % [pos.x, pos.y]


func _process(delta: float) -> void:
	var interval: float = GameManager.PRODUCTION_INTERVALS.get(building_type, 0.0)
	if interval <= 0.0:
		return

	var buff_mult: float = 1.0 + adjacent_count * Cfg.adjacent_buff()
	var production_mult: float = GameManager.get_production_multiplier()
	var effective_interval: float = interval / (buff_mult * production_mult)

	_production_timer += delta
	if _production_timer >= effective_interval:
		_production_timer -= effective_interval
		_produce()


func _produce() -> void:
	var buff_mult: float = 1.0 + adjacent_count * Cfg.adjacent_buff()
	var level_mult: float = GameManager.get_level_multiplier(level)

	match building_type:
		GameManager.BuildingType.GOLD_MINE:
			var gold_mult: float = GameManager.get_gold_multiplier()
			var amount: int = int(Cfg.gold_mine_output() * level_mult * buff_mult * gold_mult)
			GameManager.gold += amount

		GameManager.BuildingType.BARRACKS:
			_spawn_unit(GameManager.UnitType.INFANTRY)

		GameManager.BuildingType.DOCK:
			_spawn_unit(GameManager.UnitType.MARINE)

		GameManager.BuildingType.AIRFIELD:
			_spawn_unit(GameManager.UnitType.AIR_FORCE)

		GameManager.BuildingType.TAVERN:
			var random_type: int = randi() % Cfg.unit_type_count()
			_spawn_unit(random_type)


func _spawn_unit(unit_type: int) -> void:
	var grid_mgr = get_parent()
	if not grid_mgr:
		return
	var spawn_pos: Vector2 = grid_mgr.grid_to_world_center(grid_pos)
	spawn_pos.y -= GameManager.CELL_SIZE
	GameManager.unit_spawn_requested.emit(spawn_pos, unit_type, level)
