extends Control

var buttons: Dictionary = {}
var selected_highlight: ColorRect
var expand_btn: Button
var remove_btn: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_shop()
	_connect_signals()
	_highlight_selected(GameManager.selected_building)


func _build_shop() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.12, 0.10, 0.95)
	bg.position = Vector2(0, 680)
	bg.size = Vector2(720, 600)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var title := Label.new()
	title.text = "🏗 建筑商店"
	title.position = Vector2(20, 690)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	add_child(title)

	# Row 1: original 4 buildings
	var btn_container := HBoxContainer.new()
	btn_container.position = Vector2(10, 720)
	btn_container.size = Vector2(700, 90)
	btn_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_container.add_theme_constant_override("separation", 8)
	add_child(btn_container)

	for btype in [
		GameManager.BuildingType.GOLD_MINE,
		GameManager.BuildingType.BARRACKS,
		GameManager.BuildingType.CANNON,
		GameManager.BuildingType.TAVERN,
	]:
		var btn := _create_building_button(btype)
		btn_container.add_child(btn)
		buttons[btype] = btn

	# Row 2: dock + airfield
	var btn_container2 := HBoxContainer.new()
	btn_container2.position = Vector2(10, 818)
	btn_container2.size = Vector2(700, 90)
	btn_container2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_container2.add_theme_constant_override("separation", 8)
	add_child(btn_container2)

	for btype in [
		GameManager.BuildingType.DOCK,
		GameManager.BuildingType.AIRFIELD,
	]:
		var btn := _create_building_button(btype)
		btn_container2.add_child(btn)
		buttons[btype] = btn

	# 移除建筑按钮
	remove_btn = Button.new()
	remove_btn.text = "🗑 移除模式: 关"
	remove_btn.position = Vector2(350, 818)
	remove_btn.size = Vector2(170, 90)
	remove_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	remove_btn.add_theme_font_size_override("font_size", 15)
	var rm_style := StyleBoxFlat.new()
	rm_style.bg_color = Color(0.5, 0.2, 0.2, 0.9)
	rm_style.corner_radius_top_left = 8
	rm_style.corner_radius_top_right = 8
	rm_style.corner_radius_bottom_left = 8
	rm_style.corner_radius_bottom_right = 8
	remove_btn.add_theme_stylebox_override("normal", rm_style)
	var rm_hover := rm_style.duplicate()
	rm_hover.bg_color = Color(0.6, 0.25, 0.25, 0.95)
	remove_btn.add_theme_stylebox_override("hover", rm_hover)
	remove_btn.pressed.connect(_on_remove_pressed)
	add_child(remove_btn)

	selected_highlight = ColorRect.new()
	selected_highlight.color = Color(0.4, 0.6, 0.3, 0.15)
	selected_highlight.size = Vector2(700, 100)
	selected_highlight.position = Vector2(10, 715)
	selected_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(selected_highlight)
	move_child(selected_highlight, bg.get_index() + 1)

	# 行扩展按钮
	expand_btn = Button.new()
	_update_expand_btn_text()
	expand_btn.position = Vector2(10, 920)
	expand_btn.size = Vector2(700, 40)
	expand_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	expand_btn.add_theme_font_size_override("font_size", 16)
	var expand_style := StyleBoxFlat.new()
	expand_style.bg_color = Color(0.2, 0.4, 0.6, 0.9)
	expand_style.corner_radius_top_left = 6
	expand_style.corner_radius_top_right = 6
	expand_style.corner_radius_bottom_left = 6
	expand_style.corner_radius_bottom_right = 6
	expand_btn.add_theme_stylebox_override("normal", expand_style)
	var expand_hover := expand_style.duplicate()
	expand_hover.bg_color = Color(0.25, 0.5, 0.7, 0.95)
	expand_btn.add_theme_stylebox_override("hover", expand_hover)
	expand_btn.pressed.connect(_on_expand_pressed)
	add_child(expand_btn)

	var desc_container := VBoxContainer.new()
	desc_container.position = Vector2(10, 970)
	desc_container.size = Vector2(700, 200)
	desc_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desc_container)

	var descriptions: Dictionary = {
		GameManager.BuildingType.GOLD_MINE: "自动产出金币，相邻建筑+20%",
		GameManager.BuildingType.BARRACKS: "训练步兵(陆军)，相邻+速度",
		GameManager.BuildingType.CANNON: "远程固定射击，相邻+射程",
		GameManager.BuildingType.TAVERN: "随机召唤各类兵种",
		GameManager.BuildingType.DOCK: "训练海兵(水军)，水路突击",
		GameManager.BuildingType.AIRFIELD: "训练空军，无视地形",
	}

	for btype in descriptions:
		var line := Label.new()
		var bname: String = GameManager.BUILDING_NAMES[btype]
		var cost: int = GameManager.BUILDING_COSTS[btype]
		line.text = "%s ($%d): %s" % [bname, cost, descriptions[btype]]
		line.add_theme_font_size_override("font_size", 13)
		line.add_theme_color_override("font_color", Color(0.65, 0.7, 0.65))
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_container.add_child(line)


func _create_building_button(btype: int) -> Button:
	var btn := Button.new()
	var bname: String = GameManager.BUILDING_NAMES[btype]
	var cost: int = GameManager.BUILDING_COSTS[btype]
	btn.text = bname + "\n$" + str(cost)
	btn.custom_minimum_size = Vector2(120, 85)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	var bcolor: Color = GameManager.BUILDING_COLORS[btype]
	style.bg_color = bcolor.darkened(0.3)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_bottom = 3
	style.border_color = bcolor.lightened(0.2)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = bcolor.darkened(0.1)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = bcolor.lightened(0.1)
	pressed_style.border_color = Color.WHITE
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(_on_building_selected.bind(btype))

	return btn


func _connect_signals() -> void:
	GameManager.gold_changed.connect(_update_affordability)
	GameManager.building_selected.connect(_highlight_selected)
	GameManager.remove_mode_changed.connect(_update_remove_btn)


func _on_building_selected(btype: int) -> void:
	if GameManager.is_remove_mode:
		GameManager.toggle_remove_mode()
	GameManager.selected_building = btype


func _on_remove_pressed() -> void:
	GameManager.toggle_remove_mode()


func _update_remove_btn(enabled: bool) -> void:
	if enabled:
		remove_btn.text = "🗑 移除模式: 开"
		var active_style := StyleBoxFlat.new()
		active_style.bg_color = Color(0.7, 0.2, 0.2, 0.95)
		active_style.corner_radius_top_left = 8
		active_style.corner_radius_top_right = 8
		active_style.corner_radius_bottom_left = 8
		active_style.corner_radius_bottom_right = 8
		remove_btn.add_theme_stylebox_override("normal", active_style)
	else:
		remove_btn.text = "🗑 移除模式: 关"
		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color(0.5, 0.2, 0.2, 0.9)
		normal_style.corner_radius_top_left = 8
		normal_style.corner_radius_top_right = 8
		normal_style.corner_radius_bottom_left = 8
		normal_style.corner_radius_bottom_right = 8
		remove_btn.add_theme_stylebox_override("normal", normal_style)


func _on_expand_pressed() -> void:
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node and main_node.grid_manager:
		if main_node.grid_manager.expand_grid():
			_update_expand_btn_text()


func _update_expand_btn_text() -> void:
	var main_node = get_tree().root.get_node_or_null("Main")
	var cost: int = 0
	var can_exp: bool = true
	if main_node and main_node.grid_manager:
		cost = main_node.grid_manager.get_expansion_cost()
		can_exp = main_node.grid_manager.can_expand()
	else:
		cost = Cfg.row_expansion_cost_base()

	if can_exp:
		expand_btn.text = "📐 扩展土地 (+1行)  $" + str(cost)
		expand_btn.disabled = not GameManager.can_afford_amount(cost)
	else:
		expand_btn.text = "📐 土地已达最大"
		expand_btn.disabled = true


func _highlight_selected(btype: int) -> void:
	for bt in buttons:
		var btn: Button = buttons[bt]
		if bt == btype:
			btn.modulate = Color(1.2, 1.2, 1.0)
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)


func _update_affordability(_gold: int) -> void:
	for btype in buttons:
		var btn: Button = buttons[btype]
		var can_afford := GameManager.can_afford(btype)
		btn.disabled = not can_afford
		if not can_afford:
			btn.modulate = Color(0.4, 0.4, 0.4)
		elif btype == GameManager.selected_building:
			btn.modulate = Color(1.2, 1.2, 1.0)
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)

	_update_expand_btn_text()
