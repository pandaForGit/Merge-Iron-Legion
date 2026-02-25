extends Control

# 波次结束后的遗物选择弹窗：展示3个随机遗物，玩家选1个

signal relic_selected(relic_type: int)

var _relic_options: Array = []
var _buttons: Array = []
var _overlay: ColorRect
var _panel: ColorRect
var _title_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func show_relics(options: Array) -> void:
	_relic_options = options
	_clear_ui()
	_build_ui()
	visible = true


func _clear_ui() -> void:
	for child in get_children():
		child.queue_free()
	_buttons.clear()


func _build_ui() -> void:
	# 半透明遮罩
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	# 弹窗面板
	_panel = ColorRect.new()
	_panel.color = Color(0.12, 0.15, 0.12, 0.95)
	_panel.position = Vector2(40, 300)
	_panel.size = Vector2(640, 500)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)

	# 面板圆角边框（用线条模拟）
	var border := ColorRect.new()
	border.color = Color(0.6, 0.5, 0.2, 0.6)
	border.position = Vector2(38, 298)
	border.size = Vector2(644, 504)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)
	move_child(border, _panel.get_index())

	# 标题
	_title_label = Label.new()
	_title_label.text = "🎁 选择一个遗物"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.position = Vector2(40, 315)
	_title_label.size = Vector2(640, 40)
	_title_label.add_theme_font_size_override("font_size", 28)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	add_child(_title_label)

	# 副标题
	var subtitle := Label.new()
	subtitle.text = "区域 " + str(GameManager.current_region) + " 已突破！选择战利品强化你的军队"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(40, 350)
	subtitle.size = Vector2(640, 25)
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.7, 0.6))
	add_child(subtitle)

	# 遗物按钮（横排3个）
	var start_x: float = 60.0
	var btn_width: float = 195.0
	var btn_height: float = 300.0
	var gap: float = 15.0

	for i in _relic_options.size():
		var rtype: int = _relic_options[i]
		var data: Dictionary = GameManager.RELIC_DATA[rtype]
		var btn := _create_relic_button(rtype, data, i)
		btn.position = Vector2(start_x + i * (btn_width + gap), 390)
		btn.size = Vector2(btn_width, btn_height)
		add_child(btn)
		_buttons.append(btn)


func _create_relic_button(rtype: int, data: Dictionary, idx: int) -> Button:
	var btn := Button.new()
	btn.mouse_filter = Control.MOUSE_FILTER_STOP

	# 按钮内容：图标 + 名称 + 描述
	btn.text = data["icon"] + "\n\n" + data["name"] + "\n\n" + data["desc"]
	btn.add_theme_font_size_override("font_size", 16)

	# 样式
	var style := StyleBoxFlat.new()
	var c: Color = data["color"]
	style.bg_color = c.darkened(0.6)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_bottom = 4
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_color = c.lightened(0.2)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = c.darkened(0.3)
	hover_style.border_color = Color.WHITE
	hover_style.border_width_bottom = 4
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = c.lightened(0.1)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.pressed.connect(_on_relic_chosen.bind(rtype))
	return btn


func _on_relic_chosen(rtype: int) -> void:
	GameManager.add_relic(rtype)
	var data: Dictionary = GameManager.RELIC_DATA[rtype]
	relic_selected.emit(rtype)
	visible = false
	_clear_ui()
