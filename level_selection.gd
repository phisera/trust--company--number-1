extends Node

const coin_sound := preload("res://assets/sound effects/coin.ogg")

var _sfx: AudioStreamPlayer

func _ready() -> void:
	Music.play_title()
	_sfx = AudioStreamPlayer.new()
	add_child(_sfx)
	for i in range(1, 21):
		var b := find_child("level_%d_button" % i, true, false)
		if b:
			var path := "res://levels/level_%d.tscn" % i
			b.pressed.connect(_go.bind(path))

func _go(path: String) -> void:
	_sfx.stream = coin_sound
	_sfx.pitch_scale = randf_range(0.95, 1.1)
	_sfx.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(path)

func _on_back_pressed() -> void:
	_go("res://title.tscn")
