extends Node


func _on_skip_cutscene_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_1.tscn")
