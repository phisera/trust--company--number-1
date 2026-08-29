extends Node

signal next_quarter_pressed
signal statement_closed
signal browser_opened
signal level_won
signal outro_done

const DIM := Color(0, 0, 0, 0.5)
const PAD := 14.0

var _target: CanvasItem
var _layer: CanvasLayer
var _dims: Array[ColorRect] = []
var _frame: Panel

func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 30
	for i in 4:
		var r := ColorRect.new()
		r.color = DIM
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_dims.append(r)
		_layer.add_child(r)
	_frame = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.draw_center = false
	sb.border_color = Color(1.0, 0.85, 0.3)
	sb.set_border_width_all(6)
	sb.set_corner_radius_all(10)
	_frame.add_theme_stylebox_override("panel", sb)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_frame)
	_layer.visible = false
	add_child(_layer)

func notify_next_quarter() -> void: next_quarter_pressed.emit()
func notify_statement_closed() -> void: statement_closed.emit()
func notify_browser_opened() -> void: browser_opened.emit()
func notify_level_won() -> void: level_won.emit()
func notify_outro_done() -> void: outro_done.emit()

func wait_next_quarter() -> void:
	highlight("next quarter")
	await next_quarter_pressed
	stop_highlight()

func wait_statement_closed() -> void:
	highlight("CloseStatement")
	await statement_closed
	stop_highlight()

func wait_browser_opened() -> void:
	highlight("view previous statement")
	await browser_opened
	stop_highlight()

func wait_level_won() -> void:
	await level_won

func highlight(node_name: String) -> void:
	var n := get_tree().current_scene.find_child(node_name, true, false)
	if n is CanvasItem:
		_target = n
		_layer.visible = true

func stop_highlight() -> void:
	_target = null
	_layer.visible = false

func _process(_d: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var hole := _rect_of(_target).grow(PAD)
	var screen := get_viewport().get_visible_rect().size
	_dims[0].position = Vector2.ZERO
	_dims[0].size = Vector2(screen.x, hole.position.y)
	_dims[1].position = Vector2(0, hole.end.y)
	_dims[1].size = Vector2(screen.x, screen.y - hole.end.y)
	_dims[2].position = Vector2(0, hole.position.y)
	_dims[2].size = Vector2(hole.position.x, hole.size.y)
	_dims[3].position = Vector2(hole.end.x, hole.position.y)
	_dims[3].size = Vector2(screen.x - hole.end.x, hole.size.y)
	_frame.position = hole.position
	_frame.size = hole.size

func _rect_of(n: CanvasItem) -> Rect2:
	if n is Control:
		return Rect2(n.global_position, n.size * n.get_global_transform().get_scale())
	if n is Sprite2D:
		var r: Rect2 = n.get_rect()
		var t := n.get_global_transform()
		return Rect2(t * r.position, r.size * t.get_scale())
	return Rect2(n.get_global_transform().get_origin() - Vector2(60, 60), Vector2(120, 120))
