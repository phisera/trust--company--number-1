extends Node2D

const PROFIT_GOOD := 100
const FEE_PER_COMPANY := 100
const WASTE := 100
const START_FORTUNE := 2000
const THIEF_COUNT := 1
const SAFEHOUSE_NAME := "1"
const RED := "#c0392b"

@export var next_level: PackedScene
@export var statement_font: Font
@export var statement_font_size := 40
@export var money_label: RichTextLabel
@export var money_font: Font
@export var money_font_size := 40

var fortune := START_FORTUNE
var quarter := 0
var history: Array[String] = []
var _paper: PanelContainer
var _text: RichTextLabel
var _nav_row: HBoxContainer
var _view := 0

func _ready() -> void:
	$"../next quarter".pressed.connect(end_quarter)
	$"../view previous statement".pressed.connect(open_statement_browser)
	if money_label:
		if money_font:
			money_label.add_theme_font_override("normal_font", money_font)
		money_label.add_theme_font_size_override("normal_font_size", money_font_size)
	await get_tree().process_frame
	var emps := employees().filter(func(e): return e.company != SAFEHOUSE_NAME)
	emps.shuffle()
	for i in mini(THIEF_COUNT, emps.size()):
		emps[i].is_thief = true
	_build_paper()
	_update_money()

func rooms() -> Array: return get_tree().get_nodes_in_group("rooms")
func employees() -> Array: return get_tree().get_nodes_in_group("employees")

func thieves_in(room_name: String) -> int:
	var n := 0
	for e in employees():
		if e.company == room_name and e.is_thief:
			n += 1
	return n

func innocents_in(room_name: String) -> int:
	var n := 0
	for e in employees():
		if e.company == room_name and not e.is_thief:
			n += 1
	return n

func end_quarter() -> void:
	quarter += 1
	var earned := 0
	var doc := "   COMPANY STATEMENT — Q%d\n\n" % quarter
	for room in rooms():
		var bad: bool = room.name != SAFEHOUSE_NAME and thieves_in(room.name) > 0
		var income := 0 if bad else PROFIT_GOOD
		if bad:
			doc += "[color=%s]%s[/color]" % [RED, _line(room.name, 0)]
		else:
			doc += _line(room.name, income)
		earned += income
	var fees: int = rooms().size() * FEE_PER_COMPANY
	doc += _line("fees", -fees)
	var waste := WASTE * innocents_in(SAFEHOUSE_NAME)
	if waste > 0:
		doc += "[color=%s]%s[/color]" % [RED, _line("wasted salary", -waste)]
	var total := earned - fees - waste
	doc += "\n"
	doc += _line("TOTAL", total)
	fortune += total
	doc += _line("FORTUNE", fortune)
	history.append(doc)
	_update_money()
	_show_at(history.size() - 1, false)
	if fortune <= 0:
		_lose()
	elif total == 0:
		_win()

func _update_money() -> void:
	if money_label:
		money_label.text = "$%d" % fortune

func _win() -> void:
	print("LEVEL WON")
	await get_tree().create_timer(2.0).timeout
	if next_level:
		get_tree().change_scene_to_packed(next_level)

func _lose() -> void:
	print("GAME OVER")

func _line(item: String, amount: int) -> String:
	var amt: String
	if amount > 0: amt = "+$%d" % amount
	elif amount < 0: amt = "-$%d" % -amount
	else: amt = "$0"
	return "  %s %s\n" % [item.rpad(18, "."), amt.lpad(7, " ")]

func _build_paper() -> void:
	_paper = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color.BLACK
	style.set_border_width_all(6)
	style.set_content_margin_all(48)
	_paper.add_theme_stylebox_override("panel", style)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	_paper.add_child(col)

	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	_text.scroll_active = false
	if statement_font:
		_text.add_theme_font_override("normal_font", statement_font)
	else:
		var mono := SystemFont.new()
		mono.font_names = ["Courier New", "Menlo", "monospace"]
		_text.add_theme_font_override("normal_font", mono)
	_text.add_theme_font_size_override("normal_font_size", statement_font_size)
	_text.add_theme_color_override("default_color", Color.BLACK)
	col.add_child(_text)

	_nav_row = HBoxContainer.new()
	_nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_nav_row.add_theme_constant_override("separation", 24)
	col.add_child(_nav_row)
	for pair in [["<", -1], ["x", 0], [">", 1]]:
		var b := Button.new()
		b.text = pair[0]
		b.custom_minimum_size = Vector2(64, 52)
		b.pressed.connect(_nav.bind(pair[1]))
		_nav_row.add_child(b)

	_paper.hide()
	_paper.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and not _nav_row.visible:
			_paper.hide())
	var layer := CanvasLayer.new()
	layer.layer = 5
	layer.add_child(_paper)
	add_child(layer)

func _nav(dir: int) -> void:
	if dir == 0:
		_paper.hide()
		return
	_show_at(_view + dir, true)

func open_statement_browser() -> void:
	_show_at(history.size() - 1, true)

func _show_at(idx: int, with_nav: bool) -> void:
	if history.is_empty():
		return
	_view = clampi(idx, 0, history.size() - 1)
	_text.text = history[_view]
	_nav_row.visible = with_nav

	var font: Font = _text.get_theme_font("normal_font")
	var widest := 0.0
	for l in _text.get_parsed_text().split("\n"):
		widest = maxf(widest, font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, statement_font_size).x)
	_text.custom_minimum_size.x = widest + 8

	_paper.reset_size()
	_paper.show()
	await get_tree().process_frame
	_paper.position = (get_viewport_rect().size - _paper.size) / 2.0
