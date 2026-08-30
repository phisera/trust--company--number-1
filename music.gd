extends Node

const TITLE := preload("res://assets/music/title_music.mp3")
const GAME := preload("res://assets/music/game_music.mp3")
const VOLUME := -10.0

var _player: AudioStreamPlayer
var _current: AudioStream

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.finished.connect(func(): _player.play())
	add_child(_player)

func play_title() -> void: _switch(TITLE)
func play_game() -> void: _switch(GAME)

func _switch(stream: AudioStream, fade := 0.8) -> void:
	if _current == stream:
		return
	_current = stream
	var t := create_tween()
	if _player.playing:
		t.tween_property(_player, "volume_db", -40.0, fade)
		t.tween_callback(func():
			_player.stream = stream
			_player.play())
		t.tween_property(_player, "volume_db", VOLUME, fade)
	else:
		_player.stream = stream
		_player.volume_db = -40.0
		_player.play()
		t.tween_property(_player, "volume_db", VOLUME, fade)
		
func stop(fade := 0.8) -> void:
	if _current == null: return
	_current = null
	var t := create_tween()
	t.tween_property(_player, "volume_db", -40.0, fade)
	t.tween_callback(_player.stop)
