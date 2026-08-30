extends Node2D

const PROFIT_GOOD := 100
const FEE_PER_COMPANY := 100
const WASTE := 100
const SAFEHOUSE_NAME := "company #1"
const RED := "#c0392b"
const sfx_win := preload("res://assets/sound effects/good_response.ogg")
const sfx_lose := preload("res://assets/sound effects/bad_response.ogg")

@export_file("*.tscn") var next_level_path := ""
@export var start_fortune := 500
@export var statement_font: Font
@export var statement_font_size := 40
@export var money_label: RichTextLabel
@export var money_font: Font
@export var money_font_size := 40
@export var tutorial_mode := false

var _sfx: AudioStreamPlayer
var fortune := 0
var quarter := 0
var history: Array[String] = []
var _paper: PanelContainer
var _text: RichTextLabel
var _nav_row: HBoxContainer
var _view := 0

func _ready() -> void:
	fortune = start_fortune
	_sfx = AudioStreamPlayer.new()
	add_child(_sfx)
	$"next quarter".pressed.connect(end_quarter)
	$"view previous statement".pressed.connect(open_statement_browser)
	$"back".pressed.connect(_on_back_pressed)
	if money_label:
		if money_font:
			money_label.add_theme_font_override("normal_font", money_font)
		money_label.add_theme_font_size_override("normal_font_size", money_font_size)
	await get_tree().process_frame
	_build_paper()
	_update_money()
	if tutorial_mode:
		DialogueManager.show_dialogue_balloon(load("res://tutorial.dialogue"), "start")

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
	Tutorial.notify_next_quarter()
	quarter += 1
	var earned := 0
	var doc := "   COMPANY STATEMENT — Q%d\n\n" % quarter
	for room in rooms():
		var bad: bool = room.name != SAFEHOUSE_NAME and thieves_in(room.name) > 0
		var income := 0 if bad else PROFIT_GOOD
		if bad:
			doc += "[color=%s]%s[/color]" % [RED, _line(room.label_name(), 0)]
		else:
			doc += _line(room.label_name(), income)
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
	doc += _line("FORTUNE", fortune, false)
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
	_sfx.volume_db = -20.0
	_sfx.stream = sfx_win
	_sfx.play()
	Tutorial.notify_level_won()
	if tutorial_mode:
		await Tutorial.outro_done
	else:
		await get_tree().create_timer(1.5).timeout
	var popups := get_node_or_null("popups")
	if popups:
		popups.show_win(next_level_path)
	else:
		push_warning("No popups node in this scene")
		if next_level_path != "":
			get_tree().change_scene_to_file(next_level_path)

func _lose() -> void:
	_sfx.volume_db = 0.0
	_sfx.stream = sfx_lose
	_sfx.play()
	var popups := get_node_or_null("popups")
	if popups:
		popups.show_game_over()
	else:
		push_warning("No popups node in this scene")
		get_tree().reload_current_scene()

func _line(item: String, amount: int, signed := true) -> String:
	var amt: String
	if amount > 0 and signed: amt = "+$%d" % amount
	elif amount >= 0: amt = "$%d" % amount
	else: amt = "-$%d" % -amount
	return "  %s %s\n" % [item.rpad(18, "."), amt.lpad(7, " ")]

func _build_paper() -> void:
	if _paper:
		return
	_paper = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color.BLACK
	style.set_border_width_all(6)
	style.set_content_margin_all(40)
	_paper.add_theme_stylebox_override("panel", style)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	_paper.add_child(col)
	var top := HBoxContainer.new()
	col.add_child(top)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	var close := Button.new()
	close.name = "CloseStatement"
	close.text = "X"
	close.custom_minimum_size = Vector2(56, 48)
	close.pressed.connect(func():
		_paper.hide()
		Tutorial.notify_statement_closed())
	top.add_child(close)
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
	_nav_row.add_theme_constant_override("separation", 32)
	col.add_child(_nav_row)
	for pair in [["<", -1], [">", 1]]:
		var b := Button.new()
		b.text = pair[0]
		b.custom_minimum_size = Vector2(64, 52)
		b.pressed.connect(_nav.bind(pair[1]))
		_nav_row.add_child(b)
	_paper.hide()
	var layer := CanvasLayer.new()
	layer.layer = 5
	layer.add_child(_paper)
	add_child(layer)

func _nav(dir: int) -> void:
	_show_at(_view + dir, true)

func open_statement_browser() -> void:
	_show_at(history.size() - 1, true)
	Tutorial.notify_browser_opened()

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

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://level_selection.tscn")
