extends TextureButton

@export var title_font: Font
@export var body_font: Font
@export var title_size := 48
@export var body_size := 30

const TITLE := "How to play"
const BODY := """1. Each quarter, a company with an embezzler in it loses money.

2. Move employees between companies.

3. Deduce who's guilty by process of elimination.

4. Herd every embezzler into Company #1, under grandpa's watchful eyes.

5. Go to the next quarter to check if your answer is correct.

6. Run out of money and it's game over, baby."""

var _popup: PanelContainer

func _ready() -> void:
	pressed.connect(_toggle)
	var bm := BitMap.new()
	bm.create_from_image_alpha(texture_normal.get_image())
	texture_click_mask = bm

	_popup = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color.BLACK
	style.set_border_width_all(6)
	style.set_corner_radius_all(24)
	style.set_content_margin_all(44)
	_popup.add_theme_stylebox_override("panel", style)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	_popup.add_child(col)

	var title := Label.new()
	title.text = TITLE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if title_font:
		title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", title_size)
	title.add_theme_color_override("font_color", Color.BLACK)
	col.add_child(title)

	var body := Label.new()
	body.text = BODY
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(760, 0)
	if body_font:
		body.add_theme_font_override("font", body_font)
	body.add_theme_font_size_override("font_size", body_size)
	body.add_theme_color_override("font_color", Color(0.15, 0.13, 0.12))
	col.add_child(body)

	var hint := Label.new()
	hint.text = "(click anywhere to close)"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if body_font:
		hint.add_theme_font_override("font", body_font)
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color(0.5, 0.47, 0.45))
	col.add_child(hint)

	_popup.hide()
	_popup.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed: _popup.hide())
	var layer := CanvasLayer.new()
	layer.layer = 10
	layer.add_child(_popup)
	add_child(layer)

func _toggle() -> void:
	if _popup.visible:
		_popup.hide()
		return
	_popup.show()
	await get_tree().process_frame
	_popup.position = (get_viewport_rect().size - _popup.size) / 2.0
