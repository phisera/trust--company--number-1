extends Sprite2D

@export var label_font: Font
@export var font_size := 34
@export var label_offset := Vector2(0, -5)
@export var max_employees := 3

var _label: Label
var _max := 0

func _ready() -> void:
	await get_tree().process_frame
	for s: Node2D in get_tree().get_nodes_in_group("seats"):
		if get_rect().has_point(to_local(s.global_position)):
			_max += 1
	_label = Label.new()
	if label_font:
		_label.add_theme_font_override("font", label_font)
	_label.add_theme_font_size_override("font_size", font_size)
	add_child(_label)
	if max_employees > 0:
		_max = max_employees

func _process(_d: float) -> void:
	var used := 0
	for e: Node2D in get_tree().get_nodes_in_group("employees"):
		if e.company == name:
			used += 1
	_label.text = "%d/%d" % [used, _max]
	_label.modulate = Color.RED if used >= _max else Color.WHITE
	var r := get_rect()
	_label.position = Vector2(
		r.position.x + (r.size.x - _label.size.x) / 2.0,
		r.position.y - _label.size.y
	) + label_offset

func is_full() -> bool:
	var used := 0
	for e: Node2D in get_tree().get_nodes_in_group("employees"):
		if e.company == name:
			used += 1
	return used >= _max
