class_name GameManager extends Node2D

@export var skip_tuto: bool
@export var all_text: Array[String]

@onready var displayed_label: RichTextLabel = %DisplayedLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var player_node: TrailNode = %PlayerNode
@onready var reference_node: TrailNode = %ReferenceNode
@export var main: Main


var steps: Array[Callable] = []
var on_process: Array[Callable]
var on_temp_process: Array[Callable]
var on_temp_draw: Array[Callable]
var delta_t: float

var text_step: int = 0
var curr_step: int = 0
var counter: int = 0
var detection_gauge: float = 0.0

var has_player_get_amplitude: bool = false
var old_amplitude_value: float
var has_player_targeted_tuto_amplitude: bool = false
var first_tuto_amplitude_target: float = 0.5
var second_tuto_amplitude_target: float = 1.25
var third_tuto_amplitude_target: float = 2.0
var has_player_get_height: bool = false
var old_height_value: float
var has_player_targeted_tuto_height: bool = false
var first_tuto_height_target: float = 0.7
var second_tuto_height_target: float = 0.2
var third_tuto_height_target: float = 0.5


func _ready() -> void:
	steps= [
		display_introduction,
		wait_player_amplitude_movement,
		wait_player_target_amplitude_reference,
		wait_player_height_movement,
		wait_player_target_height_reference,
		launch_game,
	]
	if not skip_tuto:
		run_game()
	else:
		skip_tutorial()


func _process(delta: float) -> void:
	delta_t = delta
	for callable: Callable in on_process:
		callable.call()
	for callable: Callable in on_temp_process:
		callable.call()
	queue_redraw()


func _draw() -> void:
	for callable: Callable in on_temp_draw:
		callable.call()



## SYSTEM FUNCTIONS ##

func run_game() -> void:
	for callable:Callable in steps:
		await callable.call()
		curr_step += 1


func add_on_process(callable: Callable) -> void:
	on_process.append(callable)


func add_on_temp_process(callable: Callable) -> void:
	on_temp_process.append(callable)


func add_on_temp_draw(callable: Callable) -> void:
	on_temp_draw.append(callable)


func clean_temp_process() -> void:
	on_temp_process.clear()


func clean_temp_draw() -> void:
	on_temp_draw.clear()


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func wait_until(condition: Callable) -> void:
	while not condition.call():
		if Input.is_key_pressed(KEY_ENTER): return
		await get_tree().process_frame


func display_text(curr_text: String) -> void:
	displayed_label.visible_characters = 0
	displayed_label.text = curr_text
	while displayed_label.visible_characters < displayed_label.text.length():
		displayed_label.visible_characters += 1
		await wait(0.03)
		if Input.is_key_pressed(KEY_ENTER):
			displayed_label.visible_characters = displayed_label.text.length()
			text_step += 1
			return
	text_step += 1
	await wait(1.0)



## CHUNKS FUNCTIONS ##

func display_introduction() -> void:
	await display_text(all_text[text_step])
	await wait(2.0)


func wait_player_amplitude_movement() -> void:
	player_node.is_display_amplitude = true
	await display_text(all_text[text_step])
	progress_bar.visible = true
	add_on_process(main.handle_player_amplitude.bind(delta_t))
	add_on_temp_process(detect_amplitude_for_tutorial)
	old_amplitude_value = main.player_scale_target
	await wait_until(has_player_get_amplitude_f)


func wait_player_target_amplitude_reference() -> void:
	await display_text(all_text[text_step])
	reference_node.is_display_amplitude = true
	await wait(0.5)
	add_on_temp_process(detect_tuto_amplitude)
	await wait_until(has_player_targeted_tuto_amplitude_f)


func wait_player_height_movement() -> void:
	await display_text(all_text[text_step])
	player_node.is_display_height = true
	add_on_process(main.handle_player_height.bind(delta_t))
	add_on_temp_process(detect_height_for_tutorial)
	old_height_value = player_node.position.y
	await wait_until(has_player_get_height_f)


func wait_player_target_height_reference() -> void:
	await display_text(all_text[text_step])
	add_on_process(main.handle_reference_track.bind(delta_t))
	main.set_target_note(first_tuto_height_target)
	reference_node.is_display_height = true
	add_on_temp_process(detect_tuto_height)
	await wait_until(has_player_targeted_tuto_height_f)


func launch_game() -> void:
	displayed_label.text = ""
	add_on_process(main.handle_main_game.bind(delta_t))


func skip_tutorial() -> void:
	displayed_label.text = ""
	add_on_process(main.handle_player_amplitude.bind(delta_t))
	add_on_process(main.handle_player_height.bind(delta_t))
	add_on_process(main.handle_reference_track.bind(delta_t))
	add_on_process(main.handle_main_game.bind(delta_t))
	player_node.visible = true
	reference_node.visible = true
	progress_bar.visible = true
	has_player_get_amplitude = false
	has_player_targeted_tuto_amplitude = true
	has_player_get_height = true
	has_player_targeted_tuto_height = true

## CONDITIONS FUNCTIONS##

func has_player_get_amplitude_f() -> bool:
	return has_player_get_amplitude


func has_player_targeted_tuto_amplitude_f() -> bool:
	return has_player_targeted_tuto_amplitude


func has_player_get_height_f() -> bool:
	return has_player_get_height


func has_player_targeted_tuto_height_f() -> bool:
	return has_player_targeted_tuto_height



## PROCESS FUNCTIONS ##

func detect_amplitude_for_tutorial() -> void:
	var player_scale_target: float = main.player_scale_target
	var diff: float = abs(player_scale_target - old_amplitude_value)
	if diff > 0.0:
		detection_gauge += diff * 0.1
		old_amplitude_value = player_scale_target
	main.set_progress_bar_value(detection_gauge)
	if detection_gauge >= 1.0:
		detection_gauge = 0.0
		main.set_progress_bar_value(0.0)
		has_player_get_amplitude = true
		clean_temp_process()


func detect_tuto_amplitude() -> void:
	var targ: float = first_tuto_amplitude_target if counter == 0 else (second_tuto_amplitude_target if counter == 1 else third_tuto_amplitude_target)
	var player_scale_target: float = main.player_scale_target
	main.set_target_note(0.5, targ)
	if abs(main.player_scale_target - targ) < 0.1:
		detection_gauge += delta_t
	else:
		detection_gauge -= delta_t
	detection_gauge = clampf(detection_gauge, 0.0, 1.0)
	main.set_progress_bar_value(detection_gauge)
	if detection_gauge >= 1.0:
		detection_gauge = 0.0
		main.set_progress_bar_value(0.0)
		counter += 1
		main.display_completion_feedbacks()
		if counter >= 3:
			has_player_targeted_tuto_amplitude = true
			counter = 0
			clean_temp_process()
			clean_temp_draw()


func detect_height_for_tutorial() -> void:
	var diff: float = abs(player_node.position.y - old_height_value)
	if diff > 0.0:
		detection_gauge += diff * 0.001
		old_height_value = player_node.position.y
	main.set_progress_bar_value(detection_gauge)
	if detection_gauge >= 1.0:
		detection_gauge = 0.0
		main.set_progress_bar_value(0.0)
		has_player_get_height = true
		clean_temp_process()


func detect_tuto_height() -> void:
	if abs(player_node.position.y - main.reference_target) < 30.0:
		detection_gauge += delta_t
	else:
		detection_gauge -= delta_t
	detection_gauge = clampf(detection_gauge, 0.0, 1.0)
	main.set_progress_bar_value(detection_gauge)
	if detection_gauge >= 1.0:
		detection_gauge = 0.0
		main.set_progress_bar_value(0.0)
		counter += 1
		main.display_completion_feedbacks()
		if counter < 3:
			var targ: float = second_tuto_height_target if counter == 1 else third_tuto_height_target
			main.set_target_note(targ)
		elif counter >= 3:
			has_player_targeted_tuto_height = true
			counter = 0
			clean_temp_process()
