# balloon.gd — custom Dialogue Manager balloon: wide box at the bottom,
# character portraits, and a voice clip per line (from [#vNN] tags).
#
# BUILD THE SCENE (save as balloon.tscn):
#   Balloon (CanvasLayer)  <- attach this script
#   └── Box (Panel or TextureRect — YOUR dialogue box art)
#       anchors: left 0, right 1, bottom 1 (preset "Bottom Wide"),
#       offset_top around -280 so it is a strip along the bottom
#       ├── Portrait (TextureRect)   left side, e.g. 220x220
#       ├── NameLabel (Label)        above/next to portrait
#       ├── DialogueLabel            (DM's node type: add child -> DialogueLabel)
#       │     anchors to fill the remaining width, autowrap on
#       ├── Responses (VBoxContainer) bottom-right area
#       └── Voice (AudioStreamPlayer)
#
# HOOK IT UP: Project Settings -> Dialogue -> Balloon Path -> balloon.tscn
# Then start dialogue from anywhere with:
#   DialogueManager.show_dialogue_balloon(load("res://dialogue/tutorial.dialogue"), "start")
#
# VOICE CLIPS: res://voice/v01.ogg, v02.ogg, ... matching the [#vNN] tags.
# PORTRAITS: assign in the Inspector (Grandpapi / You), keyed by character name.

extends CanvasLayer

@export var portrait_grandpapi: Texture2D
@export var portrait_you: Texture2D

const VOICE_DIR := "res://voice/"

var resource: DialogueResource
var temporary_game_states: Array = []
var is_waiting_for_input := false
var dialogue_line: DialogueLine:
	set(value):
		if not value:
			queue_free()
			return
		dialogue_line = value
		apply_dialogue_line()
	get:
		return dialogue_line

@onready var box: Control = $box
@onready var name_label: Label = $box/name_label
@onready var rich_label := $box/dialogue_label
@onready var responses: VBoxContainer = $box/responses
@onready var portrait: TextureRect = $box/portrait
@onready var voice: AudioStreamPlayer2D = $box/voice

func _ready() -> void:
	box.hide()
	DialogueManager.mutated.connect(_on_mutated)

func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)

func apply_dialogue_line() -> void:
	is_waiting_for_input = false
	box.show()

	name_label.text = dialogue_line.character
	match dialogue_line.character:
		"Grandpapi": portrait.texture = portrait_grandpapi
		"You": portrait.texture = portrait_you
		_: portrait.texture = null

	_play_voice()

	rich_label.dialogue_line = dialogue_line
	responses.hide()
	for child in responses.get_children():
		child.queue_free()

	rich_label.type_out()
	await rich_label.finished_typing

	if dialogue_line.responses.size() > 0:
		_show_responses()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true

func _play_voice() -> void:
	voice.stop()
	print("tags: ", dialogue_line.tags)
	for tag in dialogue_line.tags:
		var path := VOICE_DIR + tag + ".ogg"
		print("looking for: ", path, "  exists: ", ResourceLoader.exists(path))
		if ResourceLoader.exists(path):
			voice.stream = load(path)
			voice.play()
			return

func _show_responses() -> void:
	responses.show()
	for response in dialogue_line.responses:
		var b := Button.new()
		b.text = response.text
		b.pressed.connect(func(): next(response.next_id))
		responses.add_child(b)
	responses.get_child(0).grab_focus()

func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)

func _on_mutated(_mutation: Dictionary) -> void:
	# a "do Tutorial.wait_*()" is running: hide the box while the player acts
	is_waiting_for_input = false
	box.hide()

func _input(event: InputEvent) -> void:
	if not box.visible: return
	var clicked: bool = event.is_action_pressed("ui_accept") \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not clicked: return
	if rich_label.is_typing:
		rich_label.skip_typing()
		get_viewport().set_input_as_handled()
	elif is_waiting_for_input and dialogue_line.responses.size() == 0:
		get_viewport().set_input_as_handled()
		next(dialogue_line.next_id)
