extends Area2D

var unit_type: int = GameManager.UnitType.INFANTRY
var level: int = 1
var hp: float = 50.0
var max_hp: float = 50.0
var damage: float = 15.0
var speed: float = 40.0
var attack_range: float = 35.0
var attack_cooldown: float = 0.8

var _attack_timer: float = 0.0
var _current_target: Node2D = null
var is_active: bool = true


func init_unit(type: int, lv: int, pos: Vector2) -> void:
	unit_type = type
	level = lv
	position = pos
	_apply_stats()
	add_to_group("units")


func _apply_stats() -> void:
	var base: Dictionary = GameManager.UNIT_BASE_STATS[unit_type]
	var lv_mult: float = GameManager.get_level_multiplier(level)
	max_hp = base["hp"] * lv_mult * GameManager.get_hp_multiplier()
	hp = max_hp
	damage = base["damage"] * lv_mult * GameManager.get_damage_multiplier()
	speed = base["speed"] * (1.0 + (level - 1) * Cfg.unit_level_speed_bonus()) * GameManager.get_speed_multiplier()
	attack_range = GameManager.UNIT_ATTACK_RANGES[unit_type]
	attack_cooldown = GameManager.UNIT_ATTACK_COOLDOWNS[unit_type] / GameManager.get_attack_speed_multiplier()
	scale = Vector2.ONE * (Cfg.unit_scale_base() + level * Cfg.unit_scale_per_level())


func _process(delta: float) -> void:
	if not is_active:
		return

	if not _current_target or not is_instance_valid(_current_target):
		_current_target = _find_nearest_enemy()

	if _current_target:
		var dist: float = global_position.distance_to(_current_target.global_position)
		if dist <= attack_range:
			_attack_timer += delta
			if _attack_timer >= attack_cooldown:
				_attack_timer = 0.0
				_do_attack()
		else:
			global_position.x += speed * delta
	else:
		global_position.x += speed * delta

	if global_position.x > Cfg.battlefield_right() + Cfg.unit_exit_offset():
		_die()

	queue_redraw()


func _find_nearest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var best: Node2D = null
	var best_dist: float = 9999.0
	for e in enemies:
		if not e.is_active:
			continue
		var d: float = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best


func _do_attack() -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	var dmg: float = _calc_damage(_current_target)
	_current_target.take_damage(dmg)
	if not is_instance_valid(_current_target) or not _current_target.is_active:
		_current_target = null


func _calc_damage(target: Node2D) -> float:
	var dmg: float = damage
	if not target.has_method("get_enemy_type"):
		return dmg
	var etype: int = target.get_enemy_type()
	match unit_type:
		GameManager.UnitType.INFANTRY:
			if etype == 2: dmg *= GameManager.COUNTER_BONUS
			elif etype == 1: dmg *= GameManager.COUNTER_PENALTY
		GameManager.UnitType.TANK:
			if etype == 0: dmg *= GameManager.COUNTER_BONUS
			elif etype == 2: dmg *= GameManager.COUNTER_PENALTY
		GameManager.UnitType.ARTILLERY:
			if etype == 1: dmg *= GameManager.COUNTER_BONUS
			elif etype == 0: dmg *= GameManager.COUNTER_PENALTY
	return dmg


func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0:
		_die()


func _die() -> void:
	is_active = false
	remove_from_group("units")
	queue_free()


# --- 绘制（占位色块）---

func _draw() -> void:
	var base_color: Color = GameManager.UNIT_COLORS.get(unit_type, Color.WHITE)
	var half := Vector2(10, 16)

	draw_rect(Rect2(-half, half * 2), base_color)
	draw_rect(Rect2(-half, half * 2), base_color.lightened(0.35), false, 1.5)

	for i in level:
		var stripe_y: float = -half.y + 4 + i * 6
		draw_line(Vector2(-half.x + 2, stripe_y), Vector2(half.x - 2, stripe_y), Color(1, 1, 0.6, 0.4), 1.0)

	var font: Font = ThemeDB.fallback_font
	var label: String = GameManager.UNIT_LABELS.get(unit_type, "?")
	draw_string(font, Vector2(-6, 4), label, HORIZONTAL_ALIGNMENT_CENTER, 14, 13, Color.WHITE)

	draw_string(font, Vector2(-4, 16), str(level), HORIZONTAL_ALIGNMENT_CENTER, 10, 10, Color(1, 1, 0.6))

	var bar_w: float = 18.0
	var bar_y: float = -half.y - 6
	draw_rect(Rect2(Vector2(-bar_w / 2, bar_y), Vector2(bar_w, 3)), Color(0.3, 0.1, 0.1))
	var hp_ratio: float = clampf(hp / max_hp, 0.0, 1.0)
	var hp_color: Color = Color(0.2, 0.8, 0.2) if hp_ratio > 0.5 else Color(0.8, 0.6, 0.1) if hp_ratio > 0.25 else Color(0.8, 0.2, 0.1)
	draw_rect(Rect2(Vector2(-bar_w / 2, bar_y), Vector2(bar_w * hp_ratio, 3)), hp_color)
