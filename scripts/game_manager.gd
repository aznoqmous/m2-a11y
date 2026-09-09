class_name GameManager extends Node

@export var all_text: Array[String]

@onready var displayed_label: RichTextLabel = %DisplayedLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var player_node: Node2D = %PlayerNode
@onready var reference_node: Node2D = %ReferenceNode


var steps: Array[Callable] = []
var on_process: Array[Callable]

var is_started: bool = false
var is_finished: bool = false
var text_step: int = 0
var curr_step: int = 0
var j1_detection_gauge: float = 0.0
var j2_detection_gauge: float = 0.0


func _ready() -> void:
	steps= [
		display_introduction,
		wait_J1_movement,
	]
	run_game()


func _process(_delta: float) -> void:
	for callable: Callable in on_process:
		callable.call()


func run_game() -> void:
	for callable:Callable in steps:
		await callable.call()
		curr_step += 1
	is_finished = true


func add_on_process(callable: Callable) -> void:
	on_process.append(callable)


func clean_process() -> void:
	on_process.clear()


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func wait_until(condition: Callable) -> void:
	while not condition.call():
		await get_tree().process_frame


func display_text(curr_text: String) -> void:
	displayed_label.visible_characters = 0
	displayed_label.text = curr_text
	while displayed_label.visible_characters < displayed_label.text.length():
		displayed_label.visible_characters += 1
		await wait(0.03)
	text_step += 1


func display_introduction() -> void:
	await display_text(all_text[text_step])
	await wait(3.0)


func wait_J1_movement() -> void:
	await display_text(all_text[text_step])
	await wait(1.0)
	player_node.visible = true
	progress_bar.visible = true
	
