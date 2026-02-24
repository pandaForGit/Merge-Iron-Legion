extends Control

var _overlay: ColorRect
var _panel: ColorRect
var _title_label: Label
var _stats_container: VBoxContainer
var _restart_btn: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func show_result(is_victory: bool) -> void:
	_clear_ui()
	_build_ui(is_victory)
	visible = true


func _clear_ui() -> void:
	for child in get_children():
		child.queue_free()


func _build_ui(is_victory: bool) -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.75)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	_panel = ColorRect.new()
	_panel.position = Vector2(60, 200)
	_panel.size = Vector2(600, 700)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)

	var border := ColorRect.new()
	border.position = Vector2(57, 197)
	border.size = Vector2(606, 706)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)
	move_child(border, _panel.get_index())

	if is_victory:
		_panel.color = Color(0.08, 0.15, 0.08, 0.97)
		border.color = Color(0.4, 0.7, 0.3, 0.6)
	else:
		_panel.color = Color(0.15, 0.08, 0.08, 0.97)
		border.color = Color(0.7, 0.3, 0.3, 0.6)

	# 标题
	_title_label = Label.new()
	if is_victory:
		_title_label.text = "🏆 胜利！"
	else:
		_title_label.text = "💀 战败"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.position = Vector2(60, 230)
	_title_label.size = Vector2(600, 60)
	_title_label.add_theme_font_size_override("font_size", 42)
	if is_victory:
		_title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))
	else:
		_title_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	add_child(_title_label)

	# 副标题
	var subtitle := Label.new()
	if is_victory:
		subtitle.text = "所有敌方建筑已被摧毁！"
	else:
		subtitle.text = "防线被突破，基地沦陷..."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(60, 290)
	subtitle.size = Vector2(600, 30)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.75, 0.7))
	add_child(subtitle)

	# 统计数据
	_stats_container = VBoxContainer.new()
	_stats_container.position = Vector2(100, 350)
	_stats_container.size = Vector2(520, 350)
	_stats_container.add_theme_constant_override("separation", 12)
	_stats_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stats_container)

	_add_stat_line("⏱ 用时", GameManager.get_elapsed_time_string())

	var victory_total: int = Cfg.map_victory_towers_destroyed()
	_add_stat_line("🏰 摧毁防御塔", "%d / %d" % [GameManager.towers_destroyed, victory_total])

	_add_stat_line("📍 推进区域", "第 %d 区域" % GameManager.current_region)

	_add_stat_line("💰 剩余金币", str(GameManager.gold))

	var relics_text := ""
	if GameManager.active_relics.size() > 0:
		for r in GameManager.active_relics:
			var rd: Dictionary = GameManager.RELIC_DATA[r]
			relics_text += rd["icon"] + " " + rd["name"] + "  "
	else:
		relics_text = "无"
	_add_stat_line("🎁 获得遗物", relics_text)

	var cmd_data: Dictionary = GameManager.COMMANDER_DATA[GameManager.current_commander]
	_add_stat_line("🎖 指挥官", cmd_data["icon"] + " " + cmd_data["name"])

	# 重新开始按钮
	_restart_btn = Button.new()
	_restart_btn.text = "🔄 重新开始"
	_restart_btn.position = Vector2(180, 770)
	_restart_btn.size = Vector2(360, 55)
	_restart_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_restart_btn.add_theme_font_size_override("font_size", 22)

	var btn_style := StyleBoxFlat.new()
	if is_victory:
		btn_style.bg_color = Color(0.25, 0.5, 0.25, 0.95)
	else:
		btn_style.bg_color = Color(0.5, 0.25, 0.25, 0.95)
	btn_style.corner_radius_top_left = 10
	btn_style.corner_radius_top_right = 10
	btn_style.corner_radius_bottom_left = 10
	btn_style.corner_radius_bottom_right = 10
	_restart_btn.add_theme_stylebox_override("normal", btn_style)

	var hover_style := btn_style.duplicate()
	hover_style.bg_color = btn_style.bg_color.lightened(0.2)
	_restart_btn.add_theme_stylebox_override("hover", hover_style)

	_restart_btn.pressed.connect(_on_restart)
	add_child(_restart_btn)


func _add_stat_line(label_text: String, value_text: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 10)
	_stats_container.add_child(hbox)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(180, 30)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.6))
	hbox.add_child(lbl)

	var val := Label.new()
	val.text = value_text
	val.custom_minimum_size = Vector2(300, 30)
	val.add_theme_font_size_override("font_size", 18)
	val.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	val.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hbox.add_child(val)


func _on_restart() -> void:
	get_tree().reload_current_scene()
