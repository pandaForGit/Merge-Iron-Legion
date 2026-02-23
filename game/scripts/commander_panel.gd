extends Control

# 指挥官选择面板（开局或波间切换）

var _buttons: Dictionary = {}
var _desc_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_highlight_selected(GameManager.current_commander)
	GameManager.commander_changed.connect(_highlight_selected)


func _build_ui() -> void:
	# 面板背景
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.12, 0.10, 0.90)
	bg.position = Vector2(0, 1080)
	bg.size = Vector2(720, 200)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# 标题
	var title := Label.new()
	title.text = "🎖 指挥官"
	title.position = Vector2(20, 1085)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	add_child(title)

	# 指挥官按钮（横排3个）
	var btn_container := HBoxContainer.new()
	btn_container.position = Vector2(20, 1115)
	btn_container.size = Vector2(680, 60)
	btn_container.add_theme_constant_override("separation", 10)
	btn_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(btn_container)

	for cmd in [GameManager.Commander.BALANCED, GameManager.Commander.PRODUCER, GameManager.Commander.FIREPOWER]:
		var data: Dictionary = GameManager.COMMANDER_DATA[cmd]
		var btn := Button.new()
		btn.text = data["icon"] + " " + data["name"]
		btn.custom_minimum_size = Vector2(215, 55)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.add_theme_font_size_override("font_size", 15)

		var style := StyleBoxFlat.new()
		style.bg_color = data["color"].darkened(0.5)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.border_width_bottom = 2
		style.border_color = data["color"].lightened(0.1)
		btn.add_theme_stylebox_override("normal", style)

		var hover := style.duplicate()
		hover.bg_color = data["color"].darkened(0.2)
		btn.add_theme_stylebox_override("hover", hover)

		btn.pressed.connect(_on_commander_selected.bind(cmd))
		btn_container.add_child(btn)
		_buttons[cmd] = btn

	# 描述
	_desc_label = Label.new()
	_desc_label.position = Vector2(20, 1185)
	_desc_label.size = Vector2(680, 25)
	_desc_label.add_theme_font_size_override("font_size", 13)
	_desc_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.6))
	add_child(_desc_label)
	_update_desc(GameManager.current_commander)


func _on_commander_selected(cmd: int) -> void:
	GameManager.current_commander = cmd


func _highlight_selected(cmd: int) -> void:
	for c in _buttons:
		var btn: Button = _buttons[c]
		if c == cmd:
			btn.modulate = Color(1.3, 1.3, 1.0)
		else:
			btn.modulate = Color(0.6, 0.6, 0.6)
	_update_desc(cmd)


func _update_desc(cmd: int) -> void:
	if _desc_label:
		var data: Dictionary = GameManager.COMMANDER_DATA[cmd]
		_desc_label.text = "当前: " + data["name"] + " — " + data["desc"]
