extends Node2D

var grid_manager: Node2D
var battlefield: Node2D
var ui_layer: CanvasLayer
var hud: Control
var shop_panel: Control
var relic_popup: Control
var commander_panel: Control


func _ready() -> void:
	_create_scene_tree()
	_connect_signals()
	GameManager.state = GameManager.GameState.SETUP


func _create_scene_tree() -> void:
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


func _connect_signals() -> void:
	GameManager.wave_cleared.connect(_on_wave_cleared)
	GameManager.game_state_changed.connect(_on_state_changed)
	relic_popup.relic_selected.connect(_on_relic_selected)


func _on_wave_cleared() -> void:
	var bonus: int = Cfg.wave_clear_base_bonus() + GameManager.wave * Cfg.wave_clear_bonus_per_wave()
	GameManager.gold += bonus
	if hud.has_method("show_info"):
		hud.show_info("✅ 第 %d 波清除！+%d金币  选择遗物..." % [GameManager.wave, bonus])

	GameManager.state = GameManager.GameState.RELIC_SELECT
	var options: Array = GameManager.pick_random_relics()
	relic_popup.show_relics(options)


func _on_relic_selected(_rtype: int) -> void:
	var data: Dictionary = GameManager.RELIC_DATA[_rtype]
	if hud.has_method("show_info"):
		hud.show_info("🎁 获得「%s」！准备下一波..." % data["name"])
	GameManager.state = GameManager.GameState.WAVE_PREP

	if _rtype == GameManager.RelicType.EXTRA_LIFE:
		if battlefield.has_method("add_extra_life"):
			battlefield.add_extra_life()


func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.GAME_OVER:
		if hud.has_method("show_info"):
			var relics_text := ""
			for r in GameManager.active_relics:
				relics_text += GameManager.RELIC_DATA[r]["icon"]
			hud.show_info("💀 游戏结束！最终波次: %d  遗物: %s" % [GameManager.wave, relics_text])


func start_wave() -> void:
	if GameManager.state == GameManager.GameState.GAME_OVER:
		return
	if battlefield.has_method("start_wave"):
		battlefield.start_wave()
