extends Node2D

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://intro.tscn")

func _on_level_selection_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_selection.tscn")
