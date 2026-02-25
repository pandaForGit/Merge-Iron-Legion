extends Node2D

# Grid anchored at the bottom. Row 0 = bottom row (closest to shop).
# New rows are appended and appear visually ABOVE existing rows (toward enemy).

var COLS: int = 8
var ROWS: int = 2
var MAX_ROWS: int = 8
var CELL_SIZE: int = 64
var GRID_BOTTOM_Y: float = 660.0

var grid_data: Array = []  # grid_data[row][col], row 0 = bottom
var building_nodes: Dictionary = {}  # Vector2i(col, row) -> Node

var hover_cell := Vector2i(-1, -1)
var _expansion_count: int = 0

var _is_dragging: bool = false
var _drag_from: Vector2i = Vector2i(-1, -1)
var _drag_type: int = -1
var _drag_level: int = 0
var _drag_mouse_pos: Vector2 = Vector2.ZERO

const COLOR_GRASS := Color(0.22, 0.38, 0.22, 0.85)
const COLOR_GRASS_ALT := Color(0.20, 0.35, 0.20, 0.85)
const COLOR_HOVER_OK := Color(0.35, 0.55, 0.35, 0.95)
const COLOR_HOVER_BAD := Color(0.55, 0.25, 0.25, 0.90)
const COLOR_GRID_LINE := Color(0.15, 0.25, 0.15, 0.6)
const COLOR_OCCUPIED_BORDER := Color(0.9, 0.85, 0.6, 0.5)
const COLOR_MERGE_OK := Color(0.3, 0.75, 0.3, 0.95)
const COLOR_MERGE_HINT := Color(0.25, 0.6, 0.25, 0.7)
const COLOR_DRAG_SOURCE := Color(0.15, 0.25, 0.15, 0.4)
const COLOR_REMOVE_HOVER := Color(0.7, 0.2, 0.2, 0.9)


func _ready() -> void:
	COLS = Cfg.grid_cols()
	ROWS = Cfg.grid_initial_rows()
	MAX_ROWS = Cfg.grid_max_rows()
	CELL_SIZE = Cfg.grid_cell_size()
	GRID_BOTTOM_Y = Cfg.grid_bottom_y()
	_init_grid()


func _process(_delta: float) -> void:
	if building_nodes.size() > 0 or hover_cell != Vector2i(-1, -1):
		queue_redraw()


func _init_grid() -> void:
	grid_data.clear()
	for row in ROWS:
		var row_data: Array = []
		for col in COLS:
			row_data.append(-1)
		grid_data.append(row_data)


# --- Coordinate conversion (row 0 = bottom) ---

func _get_grid_offset_x() -> float:
	return (Cfg.grid_viewport_width() - COLS * CELL_SIZE) / 2.0

func _cell_world_rect(col: int, row: int) -> Rect2:
	var ox: float = _get_grid_offset_x()
	var wx: float = ox + col * CELL_SIZE
	var wy: float = GRID_BOTTOM_Y - (row + 1) * CELL_SIZE
	return Rect2(Vector2(wx, wy), Vector2(CELL_SIZE, CELL_SIZE))

func grid_to_world_center(grid_pos: Vector2i) -> Vector2:
	var r := _cell_world_rect(grid_pos.x, grid_pos.y)
	return r.position + r.size / 2.0

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var ox: float = _get_grid_offset_x()
	var col := int(floor((world_pos.x - ox) / CELL_SIZE))
	var row := int(floor((GRID_BOTTOM_Y - world_pos.y) / CELL_SIZE))
	if col >= 0 and col < COLS and row >= 0 and row < ROWS:
		return Vector2i(col, row)
	return Vector2i(-1, -1)

func get_grid_top_y() -> float:
	return GRID_BOTTOM_Y - ROWS * CELL_SIZE


func is_valid_cell(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < COLS and grid_pos.y >= 0 and grid_pos.y < ROWS


func is_cell_empty(grid_pos: Vector2i) -> bool:
	if not is_valid_cell(grid_pos):
		return false
	return grid_data[grid_pos.y][grid_pos.x] == -1


# --- 行扩展 (向上扩展) ---

func get_expansion_cost() -> int:
	var base_cost: int = Cfg.row_expansion_cost_base()
	var mult: float = Cfg.row_expansion_cost_multiplier()
	return int(base_cost * pow(mult, _expansion_count))

func can_expand() -> bool:
	return ROWS < MAX_ROWS

func expand_grid() -> bool:
	if not can_expand():
		return false
	var cost: int = get_expansion_cost()
	if not GameManager.can_afford_amount(cost):
		return false

	GameManager.gold -= cost
	var new_row: Array = []
	for col in COLS:
		new_row.append(-1)
	grid_data.append(new_row)
	ROWS += 1
	_expansion_count += 1
	queue_redraw()
	return true


# --- 建筑放置 ---

func try_place_building(grid_pos: Vector2i) -> bool:
	if not is_cell_empty(grid_pos):
		return false
	var btype: int = GameManager.selected_building
	if not GameManager.purchase_building(btype):
		return false

	grid_data[grid_pos.y][grid_pos.x] = btype
	_spawn_building_node(grid_pos, btype)
	queue_redraw()
	return true


func _spawn_building_node(grid_pos: Vector2i, building_type: int) -> void:
	var building: Node = preload("res://scripts/building.gd").new()
	building.init_building(building_type, grid_pos)
	add_child(building)
	building_nodes[grid_pos] = building
	_recalc_adjacent_buffs(grid_pos)


# --- 移除建筑 ---

func remove_building(grid_pos: Vector2i) -> bool:
	if not is_valid_cell(grid_pos) or is_cell_empty(grid_pos):
		return false

	var btype: int = grid_data[grid_pos.y][grid_pos.x]
	var blevel: int = 1
	if building_nodes.has(grid_pos):
		blevel = building_nodes[grid_pos].level

	var refund: int = GameManager.get_remove_refund(btype, blevel)
	GameManager.gold += refund

	if building_nodes.has(grid_pos):
		building_nodes[grid_pos].queue_free()
		building_nodes.erase(grid_pos)

	grid_data[grid_pos.y][grid_pos.x] = -1
	_recalc_adjacent_buffs(grid_pos)
	queue_redraw()
	return true


# --- 建筑合并 ---

func _can_merge_at(target: Vector2i) -> bool:
	if not is_valid_cell(target) or target == _drag_from:
		return false
	if is_cell_empty(target):
		return false
	var target_type: int = grid_data[target.y][target.x]
	var target_level: int = building_nodes[target].level if building_nodes.has(target) else 0
	return target_type == _drag_type and target_level == _drag_level and target_level < GameManager.MAX_UNIT_LEVEL


func _merge_buildings(from: Vector2i, to: Vector2i) -> void:
	if GameManager.has_merge_discount() and building_nodes.has(from):
		var btype: int = grid_data[from.y][from.x]
		if GameManager.BUILDING_COSTS.has(btype):
			GameManager.gold += int(GameManager.BUILDING_COSTS[btype] * Cfg.merge_discount_ratio())

	if building_nodes.has(from):
		building_nodes[from].queue_free()
		building_nodes.erase(from)
	grid_data[from.y][from.x] = -1

	if building_nodes.has(to):
		building_nodes[to].level += 1
		building_nodes[to]._production_timer = 0.0

	_recalc_adjacent_buffs(from)
	_recalc_adjacent_buffs(to)
	queue_redraw()


func _get_merge_target_cells() -> Array:
	var targets: Array = []
	if not _is_dragging:
		return targets
	for row in ROWS:
		for col in COLS:
			var pos := Vector2i(col, row)
			if _can_merge_at(pos):
				targets.append(pos)
	return targets


# --- 相邻buff ---

func get_adjacent_count(grid_pos: Vector2i) -> int:
	var count := 0
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for dir in dirs:
		var check: Vector2i = grid_pos + dir
		if is_valid_cell(check) and grid_data[check.y][check.x] != -1:
			count += 1
	return count


func _recalc_adjacent_buffs(grid_pos: Vector2i) -> void:
	var positions_to_update: Array = [grid_pos]
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for dir in dirs:
		var check: Vector2i = grid_pos + dir
		if is_valid_cell(check) and grid_data[check.y][check.x] != -1:
			positions_to_update.append(check)

	for pos in positions_to_update:
		if building_nodes.has(pos):
			building_nodes[pos].adjacent_count = get_adjacent_count(pos)


# --- 坐标转换（屏幕→世界，适配Camera2D）---

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var canvas_transform := get_viewport().get_canvas_transform()
	return canvas_transform.affine_inverse() * screen_pos


# --- 输入处理 ---

func _input(event: InputEvent) -> void:
	if not _is_dragging:
		return

	if event is InputEventMouseMotion:
		var world_pos := _screen_to_world(event.position)
		_drag_mouse_pos = world_pos
		var new_hover := world_to_grid(world_pos)
		if new_hover != hover_cell:
			hover_cell = new_hover
		queue_redraw()

	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_end_building_drag()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if _is_dragging:
		return

	if event is InputEventMouseMotion:
		var world_pos := _screen_to_world(event.position)
		var new_hover := world_to_grid(world_pos)
		if new_hover != hover_cell:
			hover_cell = new_hover
			queue_redraw()

	elif event is InputEventMouseButton:
		var world_pos := _screen_to_world(event.position)
		var cell := world_to_grid(world_pos)

		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			if is_valid_cell(cell) and not is_cell_empty(cell):
				remove_building(cell)
				get_viewport().set_input_as_handled()
				return

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_valid_cell(cell):
				if GameManager.is_remove_mode:
					if not is_cell_empty(cell):
						remove_building(cell)
				elif is_cell_empty(cell):
					try_place_building(cell)
				else:
					_start_building_drag(cell, world_pos)
				get_viewport().set_input_as_handled()


func _start_building_drag(cell: Vector2i, mouse_pos: Vector2) -> void:
	_is_dragging = true
	_drag_from = cell
	_drag_type = grid_data[cell.y][cell.x]
	_drag_level = building_nodes[cell].level if building_nodes.has(cell) else 1
	_drag_mouse_pos = mouse_pos
	queue_redraw()


func _end_building_drag() -> void:
	var target := hover_cell
	if _can_merge_at(target):
		_merge_buildings(_drag_from, target)

	_is_dragging = false
	_drag_from = Vector2i(-1, -1)
	_drag_type = -1
	_drag_level = 0
	queue_redraw()


# --- 绘制 ---

func _draw() -> void:
	_draw_grid_cells()
	_draw_buildings()
	_draw_grid_border()
	if _is_dragging:
		_draw_drag_ghost()


func _draw_grid_cells() -> void:
	var merge_targets: Array = _get_merge_target_cells() if _is_dragging else []

	for row in ROWS:
		for col in COLS:
			var cell_rect := _cell_world_rect(col, row)
			var gpos := Vector2i(col, row)
			var base_color := COLOR_GRASS if (row + col) % 2 == 0 else COLOR_GRASS_ALT

			if GameManager.is_remove_mode and not is_cell_empty(gpos) and gpos == hover_cell:
				base_color = COLOR_REMOVE_HOVER
			elif _is_dragging:
				if gpos == _drag_from:
					base_color = COLOR_DRAG_SOURCE
				elif gpos in merge_targets:
					if gpos == hover_cell:
						base_color = COLOR_MERGE_OK
					else:
						base_color = COLOR_MERGE_HINT
				elif grid_data[row][col] != -1:
					base_color = GameManager.BUILDING_COLORS.get(grid_data[row][col], base_color).darkened(0.3)
			else:
				if grid_data[row][col] != -1:
					base_color = GameManager.BUILDING_COLORS.get(grid_data[row][col], base_color)
				elif gpos == hover_cell:
					if GameManager.can_afford(GameManager.selected_building):
						base_color = COLOR_HOVER_OK
					else:
						base_color = COLOR_HOVER_BAD

			draw_rect(cell_rect, base_color)
			draw_rect(cell_rect, COLOR_GRID_LINE, false, 1.0)


func _draw_buildings() -> void:
	for pos in building_nodes:
		if _is_dragging and pos == _drag_from:
			continue

		var bnode = building_nodes[pos]
		var center := grid_to_world_center(pos)
		var btype: int = grid_data[pos.y][pos.x]
		var bname: String = GameManager.BUILDING_NAMES.get(btype, "?")

		var font := ThemeDB.fallback_font

		var text_pos := center + Vector2(-CELL_SIZE * 0.35, -2)
		draw_string(font, text_pos, bname, HORIZONTAL_ALIGNMENT_CENTER, CELL_SIZE * 0.7, 14, Color.WHITE)

		var lv_text := "Lv" + str(bnode.level)
		var lv_pos := center + Vector2(-CELL_SIZE * 0.35, 14)
		var lv_color := Color(1, 0.85, 0.3) if bnode.level >= 2 else Color(1, 1, 0.7, 0.8)
		draw_string(font, lv_pos, lv_text, HORIZONTAL_ALIGNMENT_CENTER, CELL_SIZE * 0.7, 12, lv_color)

		if bnode.level >= GameManager.MAX_UNIT_LEVEL:
			var star_pos := center + Vector2(-CELL_SIZE * 0.35, 26)
			draw_string(font, star_pos, "★MAX", HORIZONTAL_ALIGNMENT_CENTER, CELL_SIZE * 0.7, 9, Color(1, 0.7, 0.2))

		if bnode.adjacent_count > 0:
			var cr := _cell_world_rect(pos.x, pos.y)
			var border_rect := Rect2(cr.position + Vector2(2, 2), cr.size - Vector2(4, 4))
			draw_rect(border_rect, COLOR_OCCUPIED_BORDER, false, 2.0)

		if bnode.has_method("get_production_progress"):
			var progress: float = bnode.get_production_progress()
			if progress > 0.0:
				var cr := _cell_world_rect(pos.x, pos.y)
				var bar_margin: float = 6.0
				var bar_h: float = 4.0
				var bar_x: float = cr.position.x + bar_margin
				var bar_y: float = cr.position.y + 3.0
				var bar_w: float = CELL_SIZE - bar_margin * 2

				draw_rect(Rect2(Vector2(bar_x, bar_y), Vector2(bar_w, bar_h)), Color(0.1, 0.1, 0.1, 0.6))
				var fill_color := Color(0.3, 0.85, 0.4, 0.9) if progress < 0.9 else Color(1.0, 0.9, 0.3, 0.95)
				draw_rect(Rect2(Vector2(bar_x, bar_y), Vector2(bar_w * progress, bar_h)), fill_color)
				draw_rect(Rect2(Vector2(bar_x, bar_y), Vector2(bar_w, bar_h)), Color(0.5, 0.6, 0.5, 0.3), false, 1.0)


func _draw_drag_ghost() -> void:
	var ghost_size := Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.7)
	var ghost_pos := _drag_mouse_pos - ghost_size / 2
	var bcolor: Color = GameManager.BUILDING_COLORS.get(_drag_type, Color.GRAY)
	draw_rect(Rect2(ghost_pos, ghost_size), bcolor.lightened(0.1) * Color(1, 1, 1, 0.75))
	draw_rect(Rect2(ghost_pos, ghost_size), Color.WHITE * Color(1, 1, 1, 0.5), false, 2.0)

	var font := ThemeDB.fallback_font
	var bname: String = GameManager.BUILDING_NAMES.get(_drag_type, "?")
	var center := _drag_mouse_pos
	draw_string(font, center + Vector2(-20, -2), bname, HORIZONTAL_ALIGNMENT_CENTER, 42, 13, Color.WHITE)
	draw_string(font, center + Vector2(-20, 12), "Lv" + str(_drag_level), HORIZONTAL_ALIGNMENT_CENTER, 42, 10, Color(1, 1, 0.6))

	var from_center := grid_to_world_center(_drag_from)
	draw_line(from_center, _drag_mouse_pos, Color(1, 1, 1, 0.2), 1.5)


func _draw_grid_border() -> void:
	var ox: float = _get_grid_offset_x()
	var top_y: float = GRID_BOTTOM_Y - ROWS * CELL_SIZE
	var border := Rect2(Vector2(ox, top_y), Vector2(COLS * CELL_SIZE, ROWS * CELL_SIZE))
	draw_rect(border, Color(0.5, 0.45, 0.3, 0.6), false, 2.0)
