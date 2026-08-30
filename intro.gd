extends Node2D

@export_file("*.tscn") var next_scene := "res://levels/level_1.tscn"

@onready var video: VideoStreamPlayer = $intro

func _ready() -> void:
	video.finished.connect(_finish)
	video.expand = true
	video.play()
	while video.get_video_texture() == null or video.get_video_texture().get_size().y == 0:
		await get_tree().process_frame
	var vs := Vector2(video.get_video_texture().get_size())
	var ss := get_viewport_rect().size
	var s := maxf(ss.x / vs.x, ss.y / vs.y)
	video.size = vs * s
	video.position = (ss - video.size) / 2.0

func _input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel") \
	or (e is InputEventMouseButton and e.pressed) \
	or e.is_action_pressed("ui_accept"):
		_finish()

func _finish() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file(next_scene)
