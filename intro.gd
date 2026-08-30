extends Node2D

@export var slides: Array[Texture2D] = []
@export var voices: Array[AudioStream] = []
@export var auto_advance := 0.0
@export_file("*.tscn") var next_scene := "res://levels/level_1.tscn"

var _i := -1
var _img: TextureRect
var _audio: AudioStreamPlayer
var _timer: SceneTreeTimer

func _ready() -> void:
	_img = TextureRect.new()
	_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_img)
	_audio = AudioStreamPlayer.new()
	add_child(_audio)
	_next()

func _unhandled_input(e: InputEvent) -> void:
	var clicked: bool = (e is InputEventMouseButton and e.pressed) \
		or e.is_action_pressed("ui_accept")
	if clicked:
		_next()
	elif e.is_action_pressed("ui_cancel"):
		_finish()

func _next() -> void:
	_i += 1
	if _i >= slides.size():
		_finish()
		return
	_img.texture = slides[_i]
	_img.modulate.a = 0.0
	create_tween().tween_property(_img, "modulate:a", 1.0, 0.5)
	_audio.stop()
	if _i < voices.size() and voices[_i]:
		_audio.stream = voices[_i]
		_audio.play()
	if auto_advance > 0.0:
		var my_i := _i
		_timer = get_tree().create_timer(auto_advance)
		_timer.timeout.connect(func():
			if _i == my_i and is_inside_tree(): _next())

func _finish() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file(next_scene)
