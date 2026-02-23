extends Node2D

const UnitScene: PackedScene = preload("res://scenes/unit.tscn")
const EnemyScene: PackedScene = preload("res://scenes/enemy.tscn")

var current_wave: int = 0
var enemies_alive: int = 0
var wave_active: bool = false
var _breach_count: int = 0
var _max_breaches: int = 5


func _ready() -> void:
	_max_breaches = Cfg.max_breaches()
	GameManager.unit_spawn_requested.connect(_on_unit_spawn_requested)
	GameManager.enemy_breached.connect(_on_enemy_breached)


func start_wave() -> void:
	current_wave += 1
	GameManager.wave = current_wave
	GameManager.state = GameManager.GameState.WAVE_ACTIVE
	wave_active = true
	_spawn_wave_enemies()


func _spawn_wave_enemies() -> void:
	var base_count: int = Cfg.wave_base_enemy_count() + current_wave * Cfg.wave_enemies_per_wave()
	var spawn_delay: float = Cfg.wave_spawn_delay()

	for i in base_count:
		var timer := get_tree().create_timer(spawn_delay * i)
		timer.timeout.connect(_spawn_single_enemy.bind(current_wave))


func _spawn_single_enemy(wave_num: int) -> void:
	var rules: Array = Cfg.wave_spawn_rules()
	var roll: float = randf()
	var etype: int = 0

	for rule in rules:
		if wave_num >= rule["min_wave"] and roll < rule["chance"]:
			etype = rule["enemy_type"]
			break

	var spawn_y: float = randf_range(Cfg.spawn_y_min(), Cfg.spawn_y_max())
	var spawn_pos := Vector2(Cfg.battlefield_right() + Cfg.spawn_x_offset(), spawn_y)

	var wave_mult: float = 1.0 + (wave_num - 1) * Cfg.wave_difficulty_scaling()

	var enemy: Area2D = EnemyScene.instantiate()
	enemy.init_enemy(etype, spawn_pos, wave_mult)
	add_child(enemy)
	enemies_alive += 1
	enemy.tree_exited.connect(_on_enemy_removed)


func _on_enemy_removed() -> void:
	enemies_alive -= 1
	if wave_active and enemies_alive <= 0:
		wave_active = false
		GameManager.wave_cleared.emit()


func _on_unit_spawn_requested(world_pos: Vector2, unit_type: int, level: int) -> void:
	spawn_unit(unit_type, level, world_pos)


func spawn_unit(type: int, level: int, pos: Vector2) -> void:
	var unit: Area2D = UnitScene.instantiate()
	unit.init_unit(type, level, pos)
	add_child(unit)


func _on_enemy_breached() -> void:
	_breach_count += 1
	if _breach_count >= _max_breaches:
		GameManager.state = GameManager.GameState.GAME_OVER


func add_extra_life() -> void:
	_max_breaches += 1


func get_breach_count() -> int:
	return _breach_count


func get_max_breaches() -> int:
	return _max_breaches
