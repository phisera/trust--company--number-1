extends Node

signal next_quarter_pressed
signal statement_closed
signal browser_opened
signal level_won
signal outro_done

var _tween: Tween
var _target: CanvasItem

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
	stop_highlight()
	var n := get_tree().current_scene.find_child(node_name, true, false)
	if n is CanvasItem:
		_target = n
		_tween = create_tween().set_loops()
		_tween.tween_property(n, "modulate", Color(1.7, 1.5, 0.7), 0.35)
		_tween.tween_property(n, "modulate", Color.WHITE, 0.35)

func stop_highlight() -> void:
	if _tween: _tween.kill()
	if _target: _target.modulate = Color.WHITE
	_target = null
