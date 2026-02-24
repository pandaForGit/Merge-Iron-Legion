extends Area2D

signal destroyed(tower: Area2D)
signal spawn_enemy_requested(pos: Vector2, enemy_type: int, difficulty: float)

var tower_type: int = 0
var tower_id: int = 0
var hp: float = 300.0
var max_hp: float = 300.0
var damage: float = 20.0
var attack_range: float = 150.0
var attack_cooldown: float = 1.2
var display_name: String = "防御炮台"
var base_color: Color = Color(0.80, 0.30, 0.30)
var region: int = 1

var spawn_interval: float = 12.0
var spawn_type: int = 0
var _difficulty_mult: float = 1.0

var _attack_timer: float = 0.0
var _spawn_timer: float = 0.0
var _current_target: Node2D = null
var is_active: bool = true

var _damage_flash_timer: float = 0.0
const FLASH_DURATION := 0.12


func init_tower(type: int, id: int, pos: Vector2, region_num: int = 1, difficulty_mult: float = 1.0) -> void:
	tower_type = type
	tower_id = id
	region = region_num
	position = pos
	_difficulty_mult = difficulty_mult

	var data: Dictionary = {}
	var types: Array = Cfg.enemy_tower_types()
	if type >= 0 and type < types.size():
		data = types[type]

	display_name = data.get("name", "防御塔")
	max_hp = data.get("hp", 300) * difficulty_mult
	hp = max_hp
	damage = data.get("damage", 20) * difficulty_mult
	attack_range = data.get("attack_range", 150.0)
	attack_cooldown = data.get("cooldown", 1.2)
	spawn_interval = data.get("spawn_interval", 12.0)
	spawn_type = data.get("spawn_type", 0)
	base_color = Cfg.arr_to_color(data.get("color", [0.80, 0.30, 0.30]))

	_spawn_timer = randf_range(3.0, spawn_interval)

	add_to_group("enemy_towers")


func get_enemy_type() -> int:
	return tower_type


func _process(delta: float) -> void:
	if not is_active:
		return

	if GameManager.state != GameManager.GameState.PLAYING:
		queue_redraw()
		return

	if _damage_flash_timer > 0:
		_damage_flash_timer -= delta

	# 攻击逻辑
	if not _current_target or not is_instance_valid(_current_target) or not _current_target.is_active:
		_current_target = _find_nearest_unit()

	if _current_target:
		var dist: float = global_position.distance_to(_current_target.global_position)
		if dist <= attack_range:
			_attack_timer += delta
			if _attack_timer >= attack_cooldown:
				_attack_timer = 0.0
				_do_attack()
		else:
			_current_target = null

	# 生产敌人
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_request_spawn_enemy()

	queue_redraw()


func _find_nearest_unit() -> Node2D:
	var units: Array = get_tree().get_nodes_in_group("units")
	var best: Node2D = null
	var best_dist: float = attack_range + 1.0
	for u in units:
		if not u.is_active:
			continue
		var d: float = global_position.distance_to(u.global_position)
		if d < best_dist:
			best_dist = d
			best = u
	return best


func _do_attack() -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	if _current_target.has_method("take_damage"):
		_current_target.take_damage(damage)
	if not is_instance_valid(_current_target) or not _current_target.is_active:
		_current_target = null


func _request_spawn_enemy() -> void:
	var spawn_pos := Vector2(global_position.x - 30, global_position.y + randf_range(-20, 20))
	spawn_enemy_requested.emit(spawn_pos, spawn_type, _difficulty_mult)


func take_damage(amount: float) -> void:
	hp -= amount
	_damage_flash_timer = FLASH_DURATION
	if hp <= 0:
		_die()


func _die() -> void:
	is_active = false
	remove_from_group("enemy_towers")
	GameManager.on_tower_destroyed_callback(tower_type)
	destroyed.emit(self)
	queue_free()


# --- 绘制 ---

func _draw() -> void:
	var size := Vector2(28, 28)
	var half := size / 2

	var draw_color := base_color
	if _damage_flash_timer > 0:
		draw_color = Color.WHITE

	# 塔身（八边形）
	var points: PackedVector2Array = PackedVector2Array()
	var r := half.x
	for i in 8:
		var angle: float = i * TAU / 8 - TAU / 16
		points.append(Vector2(cos(angle) * r, sin(angle) * r))
	draw_colored_polygon(points, draw_color)
	draw_polyline(points + PackedVector2Array([points[0]]), draw_color.lightened(0.4), 2.0)

	# 内部十字（表示炮口）
	var cross_size := r * 0.4
	draw_line(Vector2(-cross_size, 0), Vector2(cross_size, 0), Color.WHITE * Color(1, 1, 1, 0.5), 2.0)
	draw_line(Vector2(0, -cross_size), Vector2(0, cross_size), Color.WHITE * Color(1, 1, 1, 0.5), 2.0)

	# 名称
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(-12, -half.y - 10), display_name.left(2), HORIZONTAL_ALIGNMENT_CENTER, 28, 11, Color.WHITE)

	# HP条
	var bar_w: float = 30.0
	var bar_h: float = 5.0
	var bar_y: float = half.y + 4
	draw_rect(Rect2(Vector2(-bar_w / 2, bar_y), Vector2(bar_w, bar_h)), Color(0.2, 0.05, 0.05))
	var hp_ratio: float = clampf(hp / max_hp, 0.0, 1.0)
	var hp_color := Color(0.85, 0.15, 0.15) if hp_ratio > 0.3 else Color(1.0, 0.3, 0.1)
	draw_rect(Rect2(Vector2(-bar_w / 2, bar_y), Vector2(bar_w * hp_ratio, bar_h)), hp_color)

	# 生产进度条（塔底部）
	if GameManager.state == GameManager.GameState.PLAYING and spawn_interval > 0:
		var prog: float = clampf(_spawn_timer / spawn_interval, 0.0, 1.0)
		var prog_y: float = bar_y + bar_h + 3
		draw_rect(Rect2(Vector2(-bar_w / 2, prog_y), Vector2(bar_w, 3)), Color(0.1, 0.1, 0.1, 0.5))
		draw_rect(Rect2(Vector2(-bar_w / 2, prog_y), Vector2(bar_w * prog, 3)), Color(0.9, 0.6, 0.2, 0.8))

	# 攻击范围指示
	draw_arc(Vector2.ZERO, attack_range, 0, TAU, 32, Color(0.8, 0.2, 0.2, 0.08), 1.0)
