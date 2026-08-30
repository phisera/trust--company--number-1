extends AnimatedSprite2D

enum WorkAnim { TYPE, SLEEP, POINT }

@export var work_anim := WorkAnim.TYPE
@export var is_thief := false
@export var enabled := true

const snore_sound := preload("res://assets/sound effects/snoring.ogg")
const typing_sound := preload("res://assets/sound effects/typing_noises.ogg")
const drop_sound := preload("res://assets/sound effects/drop.ogg")

var _sfx: AudioStreamPlayer2D
var company := ""
var seat: Node2D = null
var _dragging := false
var _prev_seat: Node2D = null
var _home := Vector2.ZERO
var _oneshot: AudioStreamPlayer2D

func _work_name() -> String:
	match work_anim:
		WorkAnim.SLEEP: return "sleep"
		WorkAnim.POINT: return "point"
		_: return "type"

func _ready() -> void:
	if not enabled:
		queue_free()
		return
	_sfx = AudioStreamPlayer2D.new()
	_sfx.volume_db = -12.0
	_sfx.finished.connect(func(): if _sfx.stream: _sfx.play())
	add_child(_sfx)
	_oneshot = AudioStreamPlayer2D.new()
	_oneshot.volume_db = -6.0
	add_child(_oneshot)
	animation_changed.connect(_update_sound)
	_update_sound()
	add_to_group("employees")
	company = _room_under(global_position)
	var s := _nearest_free_seat(company)
	if s:
		_sit(s)
	else:
		play(_work_name())

func _grab_offset() -> Vector2:
	var tex := sprite_frames.get_frame_texture("dangle", 0)
	return Vector2(0, tex.get_size().y * 0.5 * scale.y - 6.0)

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
			global_position = get_global_mouse_position() + _grab_offset()
			get_viewport().set_input_as_handled()
		elif _dragging and not event.pressed:
			_dragging = false
			z_index = 0
			_drop()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() + _grab_offset()

func _update_sound() -> void:
	var s: AudioStream = null
	if animation == "sleep": s = snore_sound
	elif animation == "type": s = typing_sound
	if _sfx.stream == s and _sfx.playing:
		return
	_sfx.stop()
	_sfx.stream = s
	if s:
		_sfx.pitch_scale = randf_range(0.85, 1.15)
		_sfx.play()

func _drop() -> void:
	_oneshot.stream = drop_sound
	_oneshot.pitch_scale = randf_range(0.9, 1.1)
	_oneshot.play()
	var room := _room_under(global_position)
	var s: Node2D = null
	if room != "" and not _room_full(room):
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
	play(_work_name())
	var f: bool = s.get_meta("flip", false)
	flip_h = (not f) if work_anim == WorkAnim.SLEEP else f
	var off := Vector2.ZERO
	if work_anim == WorkAnim.POINT:
		off = Vector2(35, 0)
	elif work_anim == WorkAnim.SLEEP:
		off = Vector2(-12, 0)
	if flip_h:
		off.x = -off.x
	var t := create_tween().set_parallel()
	t.tween_property(self, "global_position", s.global_position + off, 0.15)
	t.tween_property(self, "scale", Vector2.ONE * s.get_meta("size", 1.0), 0.15)

func _mouse_on_me() -> bool:
	if sprite_frames == null: return false
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

func _room_full(room_name: String) -> bool:
	var count := 0
	for e in get_tree().get_nodes_in_group("employees"):
		if e != self and e.company == room_name:
			count += 1
	if count >= 6:
		return true
	for r: Node2D in get_tree().get_nodes_in_group("rooms"):
		if r.name == room_name and r.has_method("is_full"):
			return r.is_full()
	return false
