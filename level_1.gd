extends Node2D

@onready var paper: CanvasLayer = $"company statement"

const INCOME_PER_EMP := 100
const STEAL := 300
const START_FORTUNE := 2000
const THIEF_COUNT := 1
const SAFEHOUSE_NAME := "1"

var fortune := START_FORTUNE
var quarter := 0
var history: Array[String] = []
var _paper: PanelContainer

func _ready() -> void:
	await get_tree().process_frame
	var emps := employees().filter(func(e): return e.company != SAFEHOUSE_NAME)
	emps.shuffle()
	for i in mini(THIEF_COUNT, emps.size()):
		emps[i].is_thief = true

func rooms() -> Array: return get_tree().get_nodes_in_group("rooms")
func employees() -> Array: return get_tree().get_nodes_in_group("employees")

func employees_in(room_name: String) -> Array:
	return employees().filter(func(e): return e.company == room_name)

func thieves_in(room_name: String) -> int:
	return employees_in(room_name).filter(func(e): return e.is_thief).size()

func _on_next_quarter_pressed() -> void:
	quarter += 1
	var doc := "      QUARTERLY STATEMENT — Q%d\n" % quarter
	var total := 0
	for room in rooms():
		var n: int = employees_in(room.name).size()
		var income := INCOME_PER_EMP * n
		var theft := 0 if room.name == SAFEHOUSE_NAME else STEAL * thieves_in(room.name)
		var final := -theft

		doc += "\n[ %s ]\n" % room.name
		doc += _line("income", income)
		doc += _line("salaries", -income)
		if theft > 0:
			doc += _line("fees", -theft)
		doc += _line("FINAL", final)
		total += final

	fortune += total
	doc += "\n" + _line("FORTUNE", fortune)
	history.append(doc)
	show_statement()

	if fortune <= 0:
		print("GAME OVER")
	elif _all_thieves_parked():
		print("YOU WIN")

func _all_thieves_parked() -> bool:
	for e in employees():
		if e.is_thief and e.company != SAFEHOUSE_NAME:
			return false
	return true

func _line(item: String, amount: int) -> String:
	var amt := ("+$%d" if amount >= 0 else "-$%d") % absi(amount)
	return "  %s %s\n" % [item.rpad(22, "."), amt.lpad(7, " ")]

func show_statement(offset := 0) -> void:
	var idx := history.size() - 1 + offset
	if idx < 0: return
	paper.get_node("Margin/Text").text = history[idx]
	paper.show()
	
func _input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and paper.visible:
		paper.hide()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://level_selection.tscn")
