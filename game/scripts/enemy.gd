extends Area2D

var enemy_type: int = 0
var hp: float = 40.0
var max_hp: float = 40.0
var damage: float = 8.0
var speed: float = 30.0
var attack_range: float = 25.0
var attack_cooldown: float = 1.0
var display_name: String = "机器步兵"
var base_color: Color = Color(0.7, 0.2, 0.2)

var _attack_timer: float = 0.0
var _current_target: Node2D = null
var is_active: bool = true


func init_enemy(type: int, pos: Vector2, wave_mult: float = 1.0) -> void:
	enemy_type = type
	position = pos
	var data: Dictionary = GameManager.ENEMY_TYPES[type]
	display_name = data["name"]
	max_hp = data["hp"] * wave_mult
	hp = max_hp
	damage = data["damage"] * wave_mult
	speed = data["speed"]
	attack_range = data["attack_range"]
	attack_cooldown = data["cooldown"]
	base_color = data["color"]
	add_to_group("enemies")


func get_enemy_type() -> int:
	return enemy_type


func _process(delta: float) -> void:
	if not is_active:
		return

	if not _current_target or not is_instance_valid(_current_target):
		_current_target = _find_nearest_unit()

	if _current_target:
		var dist: float = global_position.distance_to(_current_target.global_position)
		if dist <= attack_range:
			_attack_timer += delta
			if _attack_timer >= attack_cooldown:
				_attack_timer = 0.0
				_do_attack()
		else:
			global_position.x -= speed * delta
	else:
		global_position.x -= speed * delta

	if global_position.x < Cfg.battlefield_left():
		is_active = false
		GameManager.enemy_breached.emit()
		queue_free()
		return

	queue_redraw()


func _find_nearest_unit() -> Node2D:
	var units: Array = get_tree().get_nodes_in_group("units")
	var best: Node2D = null
	var best_dist: float = 9999.0
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


func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0:
		_die()


func _die() -> void:
	is_active = false
	remove_from_group("enemies")
	var reward: int = Cfg.enemy_kill_base_reward() + enemy_type * Cfg.enemy_kill_reward_per_type()
	GameManager.gold += reward
	queue_free()


# --- 绘制 ---

func _draw() -> void:
	var half := Vector2(12, 12)

	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0, -half.y),
		Vector2(half.x, 0),
		Vector2(0, half.y),
		Vector2(-half.x, 0),
	])
	draw_colored_polygon(points, base_color)
	draw_polyline(points + PackedVector2Array([points[0]]), base_color.lightened(0.4), 1.5)

	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(-5, 5), display_name.left(1), HORIZONTAL_ALIGNMENT_CENTER, 12, 11, Color.WHITE)

	var bar_w: float = 20.0
	var bar_y: float = -half.y - 6
	draw_rect(Rect2(Vector2(-bar_w / 2, bar_y), Vector2(bar_w, 3)), Color(0.2, 0.05, 0.05))
	var hp_ratio: float = clampf(hp / max_hp, 0.0, 1.0)
	draw_rect(Rect2(Vector2(-bar_w / 2, bar_y), Vector2(bar_w * hp_ratio, 3)), Color(0.85, 0.15, 0.15))
