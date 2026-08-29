extends Node


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_2.tscn")
	
func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_3.tscn")
	
func _on_level_4_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_4.tscn")

func _on_level_5_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_5.tscn")
	
func _on_level_6_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_6.tscn")
	
func _on_level_7_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_7.tscn")
	
func _on_level_8_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_8.tscn")
	
func _on_level_9_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_9.tscn")
	
func _on_level_10_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_10.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://title.tscn")
