extends Node2D

func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/pointer.png"), Input.CURSOR_ARROW, Vector2(8, 8))

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://intro.tscn")

func _on_level_selection_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_selection.tscn")
