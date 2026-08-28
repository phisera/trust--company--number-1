extends AnimatedSprite2D

var company := ""
@export var is_thief := false
var seat: Node2D = null
var _dragging := false
var _prev_seat: Node2D = null
var _home := Vector2.ZERO

func _ready() -> void:
	add_to_group("employees")
	company = _room_under(global_position)
	var s := _nearest_free_seat(company)
	if s:
		_sit(s)
	else:
		play("type")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _mouse_on_me():
			_dragging = true
			_home = global_position
			_prev_seat = seat
			seat = null
			z_index = 100
			flip_h = false
			play("dangle")
			scale = Vector2.ONE
			get_viewport().set_input_as_handled()
		elif _dragging and not event.pressed:
			_dragging = false
			z_index = 0
			_drop()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position()

func _drop() -> void:
	var room := _room_under(global_position)
	var s: Node2D = null
	if room != "" and not _room_node(room).is_full():
		s = _nearest_free_seat(room)
	if s == null:
		seat = _prev_seat
		global_position = _home
		if seat: _sit(seat)
		return
	if room != company:
		company = room
		print(name, " is now in ", company)
	_sit(s)

func _sit(s: Node2D) -> void:
	seat = s
	flip_h = s.get_meta("flip", false)
	play("type")
	var t := create_tween().set_parallel()
	t.tween_property(self, "global_position", s.global_position, 0.15)
	t.tween_property(self, "scale", Vector2.ONE * s.get_meta("size", 1.0), 0.15)

func _mouse_on_me() -> bool:
	var tex := sprite_frames.get_frame_texture(animation, frame)
	var size := tex.get_size() * scale.abs()
	return Rect2(global_position - size / 2.0, size).has_point(get_global_mouse_position())

func _room_under(pos: Vector2) -> String:
	for room in get_tree().get_nodes_in_group("rooms"):
		if room.get_rect().has_point(room.to_local(pos)):
			return room.name
	return ""

func _nearest_free_seat(room_name: String) -> Node2D:
	if room_name == "": return null
	var best: Node2D = null
	var best_d := INF
	for s in get_tree().get_nodes_in_group("seats"):
		if _room_under(s.global_position) != room_name: continue
		if _seat_taken(s): continue
		var dist: float = s.global_position.distance_to(global_position)
		if dist < best_d:
			best_d = dist
			best = s
	return best

func _seat_taken(s: Node2D) -> bool:
	for e in get_tree().get_nodes_in_group("employees"):
		if e != self and e.seat == s:
			return true
	return false
	
func _room_node(room_name: String) -> Node2D:
	for r: Node2D in get_tree().get_nodes_in_group("rooms"):
		if r.name == room_name:
			return r
	return null
	
