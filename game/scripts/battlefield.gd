extends Node2D

const UnitScene: PackedScene = preload("res://scenes/unit.tscn")
const EnemyScene: PackedScene = preload("res://scenes/enemy.tscn")
const EnemyTowerScene: PackedScene = preload("res://scenes/enemy_tower.tscn")

var _towers: Array = []
var _tower_id_counter: int = 0
var _region_towers_alive: Dictionary = {}


func _ready() -> void:
	GameManager.unit_spawn_requested.connect(_on_unit_spawn_requested)
	_spawn_region_towers(1)


func _spawn_region_towers(region: int) -> void:
	var towers_per_region: int = Cfg.map_towers_per_region()
	var spawn_positions: Array = Cfg.enemy_tower_spawn_positions()
	var tower_type_count: int = Cfg.enemy_tower_type_count()

	var start_idx: int = (region - 1) * towers_per_region
	var difficulty_mult: float = 1.0 + (region - 1) * 0.5

	_region_towers_alive[region] = 0

	for i in towers_per_region:
		var pos_idx: int = start_idx + i
		if pos_idx >= spawn_positions.size():
			break

		var pos_data: Dictionary = spawn_positions[pos_idx]
		var spawn_pos := Vector2(pos_data.get("x", 360), pos_data.get("y", 300))

		var tower_type: int = i % tower_type_count

		_tower_id_counter += 1
		var tower: Area2D = EnemyTowerScene.instantiate()
		tower.init_tower(tower_type, _tower_id_counter, spawn_pos, region, difficulty_mult)
		tower.destroyed.connect(_on_tower_destroyed)
		tower.spawn_enemy_requested.connect(_on_tower_spawn_enemy)
		add_child(tower)
		_towers.append(tower)
		_region_towers_alive[region] += 1

	GameManager.total_towers += towers_per_region


func _on_tower_destroyed(tower: Area2D) -> void:
	_towers.erase(tower)
	var r: int = tower.region
	if _region_towers_alive.has(r):
		_region_towers_alive[r] -= 1

	if _region_towers_alive.get(r, 0) <= 0:
		_on_region_cleared(r)


func _on_region_cleared(region: int) -> void:
	var max_regions: int = Cfg.map_max_regions()
	var next_region: int = region + 1

	if next_region <= max_regions:
		var bonus: int = Cfg.map_expansion_base_bonus() + region * Cfg.map_expansion_bonus_per_level()
		GameManager.gold += bonus
		GameManager.current_region = next_region
		GameManager.region_unlocked.emit(next_region)
		_spawn_region_towers(next_region)


func _on_tower_spawn_enemy(pos: Vector2, enemy_type: int, difficulty: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	var enemy_type_clamped: int = clampi(enemy_type, 0, Cfg.enemy_type_count() - 1)
	var enemy: Area2D = EnemyScene.instantiate()
	enemy.init_enemy(enemy_type_clamped, pos, difficulty)
	add_child(enemy)


func _on_unit_spawn_requested(world_pos: Vector2, unit_type: int, level: int) -> void:
	spawn_unit(unit_type, level, world_pos)


func spawn_unit(type: int, level: int, pos: Vector2) -> void:
	var unit: Area2D = UnitScene.instantiate()
	unit.init_unit(type, level, pos)
	add_child(unit)


func get_towers_alive() -> int:
	return _towers.size()


func get_region_towers_alive(region: int) -> int:
	return _region_towers_alive.get(region, 0)
