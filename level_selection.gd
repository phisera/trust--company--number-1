extends Node

func _ready() -> void:
	for i in range(1, 11):
		var b := find_child("level_%d_button" % i, true, false)
		if b:
			var path := "res://level_%d.tscn" % i
			b.pressed.connect(func(): get_tree().change_scene_to_file(path))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://title.tscn")
