extends Control

var gold_label: Label
var progress_label: Label
var state_label: Label
var info_label: Label
var region_label: Label
var breach_label: Label
var relic_bar: Label
var start_btn: Button
var speed_btn: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_connect_signals()
	_update_gold(GameManager.gold)
	_update_tower_progress(0)


func _build_ui() -> void:
	var top_bg := ColorRect.new()
	top_bg.color = Color(0.08, 0.10, 0.08, 0.9)
	top_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bg.offset_bottom = 70
	top_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_bg)

	gold_label = Label.new()
	gold_label.text = "💰 " + str(Cfg.starting_gold())
	gold_label.position = Vector2(20, 12)
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	add_child(gold_label)

	progress_label = Label.new()
	progress_label.text = "🏰 0 / " + str(Cfg.map_victory_towers_destroyed())
	progress_label.position = Vector2(20, 42)
	progress_label.add_theme_font_size_override("font_size", 16)
	progress_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	add_child(progress_label)

	region_label = Label.new()
	region_label.text = "📍 区域 1"
	region_label.position = Vector2(220, 12)
	region_label.add_theme_font_size_override("font_size", 20)
	region_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	add_child(region_label)

	breach_label = Label.new()
	var mb: int = Cfg.max_breaches()
	breach_label.text = "❤ " + str(mb) + "/" + str(mb)
	breach_label.position = Vector2(220, 42)
	breach_label.add_theme_font_size_override("font_size", 16)
	breach_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	add_child(breach_label)

	state_label = Label.new()
	state_label.text = "⚙ 建设阶段"
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state_label.position = Vector2(400, 12)
	state_label.size = Vector2(200, 30)
	state_label.add_theme_font_size_override("font_size", 18)
	state_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.7))
	add_child(state_label)

	# 加速按钮
	speed_btn = Button.new()
	speed_btn.text = "▶ 1x"
	speed_btn.position = Vector2(610, 8)
	speed_btn.size = Vector2(100, 28)
	speed_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	speed_btn.add_theme_font_size_override("font_size", 14)
	var spd_style := StyleBoxFlat.new()
	spd_style.bg_color = Color(0.3, 0.4, 0.5, 0.9)
	spd_style.corner_radius_top_left = 6
	spd_style.corner_radius_top_right = 6
	spd_style.corner_radius_bottom_left = 6
	spd_style.corner_radius_bottom_right = 6
	speed_btn.add_theme_stylebox_override("normal", spd_style)
	var spd_hover := spd_style.duplicate()
	spd_hover.bg_color = Color(0.4, 0.5, 0.6, 0.95)
	speed_btn.add_theme_stylebox_override("hover", spd_hover)
	speed_btn.pressed.connect(_on_speed_pressed)
	add_child(speed_btn)

	start_btn = Button.new()
	start_btn.text = "⚔ 开始战斗"
	start_btn.position = Vector2(430, 40)
	start_btn.size = Vector2(280, 28)
	start_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	start_btn.add_theme_font_size_override("font_size", 15)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.6, 0.25, 0.2, 0.9)
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	start_btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover := btn_style.duplicate()
	btn_hover.bg_color = Color(0.75, 0.3, 0.25, 0.95)
	start_btn.add_theme_stylebox_override("hover", btn_hover)
	start_btn.pressed.connect(_on_start_btn_pressed)
	add_child(start_btn)

	info_label = Label.new()
	info_label.text = "👆 放置建筑，拖拽合并升级。右键移除建筑。点击「开始」进攻！"
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.position = Vector2(0, 620)
	info_label.size = Vector2(720, 30)
	info_label.add_theme_font_size_override("font_size", 14)
	info_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.6, 0.8))
	add_child(info_label)

	relic_bar = Label.new()
	relic_bar.text = ""
	relic_bar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic_bar.position = Vector2(0, 645)
	relic_bar.size = Vector2(720, 25)
	relic_bar.add_theme_font_size_override("font_size", 18)
	relic_bar.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5, 0.9))
	add_child(relic_bar)


func _connect_signals() -> void:
	GameManager.gold_changed.connect(_update_gold)
	GameManager.tower_destroyed.connect(_update_tower_progress)
	GameManager.game_state_changed.connect(_update_state)
	GameManager.region_unlocked.connect(_update_region)
	GameManager.enemy_breached.connect(_update_breach)
	GameManager.relic_chosen.connect(_update_relics)
	GameManager.game_speed_changed.connect(_update_speed_btn)


func _update_gold(amount: int) -> void:
	gold_label.text = "💰 " + str(amount)


func _update_tower_progress(destroyed_count: int) -> void:
	var total: int = Cfg.map_victory_towers_destroyed()
	progress_label.text = "🏰 已摧毁 %d / %d" % [destroyed_count, total]
	if destroyed_count >= total:
		progress_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))


func _update_region(region: int) -> void:
	region_label.text = "📍 区域 " + str(region)


func _update_breach() -> void:
	var left: int = GameManager.get_breach_remaining()
	breach_label.text = "❤ %d/%d" % [left, GameManager.max_breaches]
	if left <= 1:
		breach_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))


func _update_state(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.SETUP:
			state_label.text = "⚙ 建设阶段"
			start_btn.disabled = false
			start_btn.text = "⚔ 开始战斗"
		GameManager.GameState.PLAYING:
			state_label.text = "⚔ 战斗中"
			start_btn.disabled = true
			start_btn.text = "⚔ 战斗中..."
		GameManager.GameState.RELIC_SELECT:
			state_label.text = "🎁 选择遗物(暂停)"
			start_btn.disabled = true
			start_btn.text = "🎁 选择中..."
		GameManager.GameState.VICTORY:
			state_label.text = "🏆 胜利！"
			start_btn.disabled = true
			start_btn.text = "🏆 胜利！"
		GameManager.GameState.GAME_OVER:
			state_label.text = "💀 游戏结束"
			start_btn.disabled = true
			start_btn.text = "游戏结束"


func _on_start_btn_pressed() -> void:
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node and main_node.has_method("start_battle"):
		main_node.start_battle()
		show_info("⚔ 战斗开始！单位自动侦测视野内敌人攻击！")


func _on_speed_pressed() -> void:
	if GameManager.state == GameManager.GameState.PLAYING:
		GameManager.toggle_game_speed()


func _update_speed_btn(new_speed: float) -> void:
	if new_speed >= Cfg.game_speed_fast():
		speed_btn.text = "⏩ 2x"
	else:
		speed_btn.text = "▶ 1x"


func _update_relics(_rtype: int) -> void:
	var icons := ""
	for r in GameManager.active_relics:
		icons += GameManager.RELIC_DATA[r]["icon"] + " "
	relic_bar.text = icons.strip_edges()


func show_info(text: String) -> void:
	info_label.text = text
