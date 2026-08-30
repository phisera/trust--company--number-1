extends Node

@export var level_select_scene: PackedScene
@export var title_font: Font
@export var button_font: Font
@export var title_size := 64
@export var button_size := 32

const WIN_TITLE := "LEVEL PASSED!"
const WIN_SUB := "goo goo ga ga"
const LOSE_TITLE := "GAME OVER, BABY"
const LOSE_SUB := "the inheritance is gone"

var _popup: PanelContainer
var _layer: CanvasLayer

func show_win(next_path: String = "") -> void:
	var buttons: Array = []
	if next_path != "":
		buttons.append(["next level", func(): get_tree().change_scene_to_file(next_path)])
	buttons.append(["level select", _go_level_select])
	_show(WIN_TITLE, WIN_SUB, Color(0.18, 0.5, 0.25), buttons)

func show_game_over() -> void:
	_show(LOSE_TITLE, LOSE_SUB, Color(0.75, 0.22, 0.17), [
		["retry", func(): get_tree().reload_current_scene()],
		["level select", _go_level_select],
	])

func _go_level_select() -> void:
	if level_select_scene:
		get_tree().change_scene_to_packed(level_select_scene)

func _show(title_text: String, sub_text: String, accent: Color, buttons: Array) -> void:
	if _popup:
		_layer.queue_free()
	_popup = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color.BLACK
	style.set_border_width_all(6)
	style.set_corner_radius_all(24)
	style.set_content_margin_all(52)
	_popup.add_theme_stylebox_override("panel", style)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 24)
	_popup.add_child(col)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if title_font:
		title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", title_size)
	title.add_theme_color_override("font_color", accent)
	col.add_child(title)

	var sub := Label.new()
	sub.text = sub_text
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if button_font:
		sub.add_theme_font_override("font", button_font)
	sub.add_theme_font_size_override("font_size", button_size - 4)
	sub.add_theme_color_override("font_color", Color(0.4, 0.37, 0.35))
	col.add_child(sub)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 32)
	col.add_child(row)
	for pair in buttons:
		if pair.size() > 2 and pair[2]:
			var tb := TextureButton.new()
			tb.texture_normal = pair[2]
			tb.ignore_texture_size = true
			tb.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			tb.custom_minimum_size = Vector2(110, 110)
			tb.pressed.connect(pair[1])
			row.add_child(tb)
		else:
			var b := Button.new()
			b.text = pair[0]
			if button_font:
				b.add_theme_font_override("font", button_font)
			b.add_theme_font_size_override("font_size", button_size)
			b.custom_minimum_size = Vector2(240, 72)
			b.pressed.connect(pair[1])
			row.add_child(b)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)

	_layer = CanvasLayer.new()
	_layer.layer = 20
	_layer.add_child(dim)
	_layer.add_child(_popup)
	add_child(_layer)

	await get_tree().process_frame
	_popup.position = (_popup.get_viewport_rect().size - _popup.size) / 2.0
