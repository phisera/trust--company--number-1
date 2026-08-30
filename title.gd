extends Node2D

const coin_sound := preload("res://assets/sound effects/coin.ogg")
var _sfx: AudioStreamPlayer

func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/misc/pointer.png"), Input.CURSOR_ARROW, Vector2(8, 8))
	_sfx = AudioStreamPlayer.new()
	add_child(_sfx)

var _leaving := false

func _go(path: String) -> void:
	if _leaving: return
	_leaving = true
	_sfx.stream = coin_sound
	_sfx.pitch_scale = randf_range(0.95, 1.1)
	_sfx.play()
	await get_tree().create_timer(0.3).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(path)

func _on_start_button_pressed() -> void:
	_go("res://intro.tscn")

func _on_level_selection_button_pressed() -> void:
	_go("res://level_selection.tscn")
