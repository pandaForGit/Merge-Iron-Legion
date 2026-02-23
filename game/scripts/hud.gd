extends Control

var gold_label: Label
var wave_label: Label
var state_label: Label
var info_label: Label
var breach_label: Label
var relic_bar: Label
var wave_btn: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_connect_signals()
	_update_gold(GameManager.gold)
	_update_wave(GameManager.wave)


func _build_ui() -> void:
	# 顶部信息栏背景
	var top_bg := ColorRect.new()
	top_bg.color = Color(0.08, 0.10, 0.08, 0.9)
	top_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bg.offset_bottom = 70
	top_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_bg)

	# 金币显示
	gold_label = Label.new()
	gold_label.text = "💰 " + str(Cfg.starting_gold())
	gold_label.position = Vector2(20, 12)
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	add_child(gold_label)

	# 波次显示
	wave_label = Label.new()
	wave_label.text = "🌊 准备中"
	wave_label.position = Vector2(20, 42)
	wave_label.add_theme_font_size_override("font_size", 16)
	wave_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	add_child(wave_label)

	# 突破计数
	breach_label = Label.new()
	var mb: int = Cfg.max_breaches()
	breach_label.text = "❤ " + str(mb) + "/" + str(mb)
	breach_label.position = Vector2(250, 12)
	breach_label.add_theme_font_size_override("font_size", 22)
	breach_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	add_child(breach_label)

	# 游戏状态
	state_label = Label.new()
	state_label.text = "⚙ 建设阶段"
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state_label.position = Vector2(400, 12)
	state_label.size = Vector2(300, 30)
	state_label.add_theme_font_size_override("font_size", 20)
	state_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.7))
	add_child(state_label)

	# 开始波次按钮
	wave_btn = Button.new()
	wave_btn.text = "⚔ 开始波次"
	wave_btn.position = Vector2(430, 38)
	wave_btn.size = Vector2(270, 32)
	wave_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	wave_btn.add_theme_font_size_override("font_size", 16)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.6, 0.25, 0.2, 0.9)
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	wave_btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover := btn_style.duplicate()
	btn_hover.bg_color = Color(0.75, 0.3, 0.25, 0.95)
	wave_btn.add_theme_stylebox_override("hover", btn_hover)
	wave_btn.pressed.connect(_on_wave_btn_pressed)
	add_child(wave_btn)

	# 提示信息（网格下方）
	info_label = Label.new()
	info_label.text = "👆 放置建筑，拖拽同类建筑合并升级，点击「开始波次」"
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.position = Vector2(0, 620)
	info_label.size = Vector2(720, 30)
	info_label.add_theme_font_size_override("font_size", 15)
	info_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.6, 0.8))
	add_child(info_label)

	# 已获得遗物栏
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
	GameManager.wave_changed.connect(_update_wave)
	GameManager.game_state_changed.connect(_update_state)
	GameManager.enemy_breached.connect(_update_breach)
	GameManager.relic_chosen.connect(_update_relics)


func _update_gold(amount: int) -> void:
	gold_label.text = "💰 " + str(amount)


func _update_wave(w: int) -> void:
	if w == 0:
		wave_label.text = "🌊 准备中"
	else:
		wave_label.text = "🌊 第 " + str(w) + " 波"


func _update_state(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.SETUP:
			state_label.text = "⚙ 建设阶段"
			wave_btn.disabled = false
			wave_btn.text = "⚔ 开始波次"
		GameManager.GameState.WAVE_PREP:
			state_label.text = "🔧 备战中"
			wave_btn.disabled = false
			wave_btn.text = "⚔ 下一波"
		GameManager.GameState.WAVE_ACTIVE:
			state_label.text = "⚔ 战斗中!"
			wave_btn.disabled = true
			wave_btn.text = "⏳ 战斗中..."
		GameManager.GameState.RELIC_SELECT:
			state_label.text = "🎁 选择遗物"
			wave_btn.disabled = true
			wave_btn.text = "🎁 选择中..."
		GameManager.GameState.GAME_OVER:
			state_label.text = "💀 游戏结束"
			wave_btn.disabled = true
			wave_btn.text = "游戏结束"


func _update_breach() -> void:
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node and main_node.battlefield:
		var bf = main_node.battlefield
		if bf.has_method("get_breach_count"):
			var left: int = bf.get_max_breaches() - bf.get_breach_count()
			breach_label.text = "❤ " + str(left) + "/" + str(bf.get_max_breaches())
			if left <= 1:
				breach_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))


func _on_wave_btn_pressed() -> void:
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node and main_node.has_method("start_wave"):
		main_node.start_wave()
		show_info("⚔ 敌军来袭！拖拽同类建筑合并，提升产兵等级！")


func _update_relics(_rtype: int) -> void:
	var icons := ""
	for r in GameManager.active_relics:
		icons += GameManager.RELIC_DATA[r]["icon"] + " "
	relic_bar.text = icons.strip_edges()


func show_info(text: String) -> void:
	info_label.text = text
