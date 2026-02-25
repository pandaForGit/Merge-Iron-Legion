extends Node2D

var grid_manager: Node2D
var battlefield: Node2D
var ui_layer: CanvasLayer
var hud: Control
var shop_panel: Control
var relic_popup: Control
var commander_panel: Control
var result_popup: Control
var camera: Camera2D

var _is_map_dragging: bool = false
var _drag_start_y: float = 0.0
var _cam_start_y: float = 0.0
const DRAG_THRESHOLD := 8.0
var _drag_total_moved: float = 0.0
var _cam_min_y: float = 0.0
var _cam_max_y: float = 640.0


func _ready() -> void:
	_create_scene_tree()
	_connect_signals()
	_update_cam_limits()
	GameManager.state = GameManager.GameState.SETUP


func _create_scene_tree() -> void:
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.position = Vector2(360, 640)
	camera.zoom = Vector2(1, 1)
	camera.enabled = true
	add_child(camera)

	grid_manager = preload("res://scripts/grid_manager.gd").new()
	grid_manager.name = "GridManager"
	add_child(grid_manager)

	var BattlefieldScript = preload("res://scripts/battlefield.gd")
	battlefield = Node2D.new()
	battlefield.set_script(BattlefieldScript)
	battlefield.name = "BattleField"
	add_child(battlefield)

	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 10
	add_child(ui_layer)

	var HudScript = preload("res://scripts/hud.gd")
	hud = Control.new()
	hud.set_script(HudScript)
	hud.name = "HUD"
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(hud)

	var ShopScript = preload("res://scripts/shop_panel.gd")
	shop_panel = Control.new()
	shop_panel.set_script(ShopScript)
	shop_panel.name = "ShopPanel"
	shop_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(shop_panel)

	var CmdScript = preload("res://scripts/commander_panel.gd")
	commander_panel = Control.new()
	commander_panel.set_script(CmdScript)
	commander_panel.name = "CommanderPanel"
	commander_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(commander_panel)

	var RelicScript = preload("res://scripts/relic_popup.gd")
	relic_popup = Control.new()
	relic_popup.set_script(RelicScript)
	relic_popup.name = "RelicPopup"
	relic_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(relic_popup)

	var ResultScript = preload("res://scripts/result_popup.gd")
	result_popup = Control.new()
	result_popup.set_script(ResultScript)
	result_popup.name = "ResultPopup"
	result_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(result_popup)


func _connect_signals() -> void:
	GameManager.region_unlocked.connect(_on_region_unlocked)
	GameManager.all_towers_cleared.connect(_on_victory)
	GameManager.game_state_changed.connect(_on_state_changed)
	GameManager.enemy_breached.connect(_on_enemy_breached)
	relic_popup.relic_selected.connect(_on_relic_selected)


func _update_cam_limits() -> void:
	_cam_max_y = 640.0
	var highest_tower_y: float = 400.0
	var towers = get_tree().get_nodes_in_group("enemy_towers")
	for t in towers:
		if t.global_position.y < highest_tower_y:
			highest_tower_y = t.global_position.y
	_cam_min_y = min(_cam_max_y, highest_tower_y + 200.0)


# --- 垂直地图拖拽 ---

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if event.position.y > 70 and event.position.y < 670:
					_is_map_dragging = true
					_drag_start_y = event.position.y
					_cam_start_y = camera.position.y
					_drag_total_moved = 0.0
			else:
				_is_map_dragging = false

	elif event is InputEventMouseMotion and _is_map_dragging:
		var dy: float = _drag_start_y - event.position.y
		_drag_total_moved += abs(event.position.y - _drag_start_y)
		if _drag_total_moved > DRAG_THRESHOLD:
			_update_cam_limits()
			camera.position.y = clampf(_cam_start_y - dy, _cam_min_y, _cam_max_y)


func start_battle() -> void:
	if GameManager.state == GameManager.GameState.VICTORY:
		return
	if GameManager.state == GameManager.GameState.GAME_OVER:
		return
	GameManager.state = GameManager.GameState.PLAYING
	if hud.has_method("show_info"):
		hud.show_info("⚔ 战斗开始！单位自动侦测并攻击视野内目标！")


func _on_region_unlocked(region: int) -> void:
	_update_cam_limits()
	var bonus_text: int = Cfg.map_expansion_base_bonus() + (region - 1) * Cfg.map_expansion_bonus_per_level()
	if hud.has_method("show_info"):
		hud.show_info("✅ 区域 %d 已解锁！+%d金币  选择遗物..." % [region, bonus_text])

	GameManager.state = GameManager.GameState.RELIC_SELECT
	GameManager.pause_for_relic()
	var options: Array = GameManager.pick_random_relics()
	relic_popup.show_relics(options)


func _on_relic_selected(_rtype: int) -> void:
	GameManager.resume_from_relic()
	var data: Dictionary = GameManager.RELIC_DATA[_rtype]
	if hud.has_method("show_info"):
		hud.show_info("🎁 获得「%s」！继续推进！" % data["name"])

	if _rtype == GameManager.RelicType.EXTRA_LIFE:
		GameManager.add_extra_life()

	GameManager.state = GameManager.GameState.PLAYING


func _on_enemy_breached() -> void:
	if hud.has_method("show_info"):
		var left: int = GameManager.get_breach_remaining()
		hud.show_info("⚠ 敌人突破防线！剩余 %d 次容错" % left)


func _on_victory() -> void:
	if result_popup.has_method("show_result"):
		result_popup.show_result(true)


func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.GAME_OVER:
		if result_popup.has_method("show_result"):
			result_popup.show_result(false)
