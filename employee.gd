extends Sprite2D

var company: String = ""
var _dragging := false
var _home := Vector2.ZERO
var is_thief := false

func _ready() -> void:
	company = _room_under(global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _mouse_on_me():
			_dragging = true
			_home = global_position
			z_index = 100
			get_viewport().set_input_as_handled()
		elif _dragging and not event.pressed:
			_dragging = false
			z_index = 0
			var room := _room_under(global_position)
			if room == "":
				global_position = _home   
			elif room != company:
				company = room
				print(name, " is now in ", company)
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position()

func _mouse_on_me() -> bool:
	return get_rect().has_point(to_local(get_global_mouse_position()))

func _room_under(pos: Vector2) -> String:
	for room in get_tree().get_nodes_in_group("rooms"):
		if room.get_rect().has_point(room.to_local(pos)):
			return room.name
	return ""
