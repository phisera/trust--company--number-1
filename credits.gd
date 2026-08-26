extends Button

@export var credits_font: Font
@export var font_size := 28

const CREDITS := """CREDITS

art assets ......... chloe
code ............... soph
development ........ soph
game page art ...... chloe
intern ............. chloe
intro animation .... chloe
intern manager ..... soph
level design ....... soph
music .............. chloe
prototyping ........ soph
research ........... chloe
sound design ....... soph
sound effects ...... soph
sprites ............ chloe
sprite animation ... chloe
story .............. soph
testing ............ soph
voiceover .......... chloe"""

var _popup: PanelContainer

func _ready() -> void:
	pressed.connect(_toggle)

	var label := Label.new()
	label.text = CREDITS
	if credits_font:
		label.add_theme_font_override("font", credits_font)
	label.add_theme_font_size_override("font_size", font_size)

	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 40)
	margin.add_child(label)

	_popup = PanelContainer.new()
	_popup.add_child(margin)
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
