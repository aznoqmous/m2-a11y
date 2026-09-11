@tool
extends Node2D
class_name Main

@onready var serial: Node2D = $Serial

@export_category("Colors")
@export var player_color: Color
@export var reference_color: Color

@export_category("Game")
@export var target_notes : Array[float]
@export var time_to_reach := 10.0
@export var min_hand_distance := 5.0
@export var max_hand_distance := 30.0
@export var pitch_validation_distance := 0.05
@export var volume_validation_distance := 0.2
var current_time_to_reach := 0.0
var target_note_index := 0

var state = 0.5
var player_target : float
var player_scale_target : float
var reference_target : float
var reference_scale_target : float
@export var player_speed : float = 1.0
@export var reference_speed : float = 1.0
@export var player_rotation_speed : float = 1.0
@export var reference_rotation_speed : float = 1.0
var player_current_speed : float
var reference_current_speed : float

@export_category("Nodes")
@export var player_audio_generator: AudioGenerator
@export var reference_audio_generator: AudioGenerator
@export var reference_particles: GPUParticles2D
@export var player_particles: GPUParticles2D
@export var reference_node: Node2D
@export var player_node: Node2D
@export var blit_material: ShaderMaterial
@export var progress_bar: ProgressBar

@export var game_renderer: GameRenderer
@export var mesh_instance_2d: MeshInstance2D

@onready var game_manager: GameManager = %GameManager
var mesh_size : Vector2

func _ready() -> void:
	mesh_size = (Vector2(1152, 648) if Engine.is_editor_hint() else get_viewport().get_visible_rect().size ) / 2.0
	mesh_instance_2d.mesh.set("size", mesh_size * 2.0)
	
	player_node.position.y = 0.0
	reference_node.position.y = 0.0
	set_target_note(target_notes[target_note_index], 0.5)


func _process(_delta: float) -> void:
	print(get_serial_value(serial.value_a), " ", get_serial_value(serial.value_b))
	if Engine.is_editor_hint(): return;
	AudioEffectManager.player_scale = player_scale_target
	AudioEffectManager.target_scale = reference_scale_target
	
	AudioEffectManager._value_snapping()
	AudioEffectManager._fx_application()
	
	player_audio_generator.set_pitch((player_node.position.y + mesh_size.y ) / mesh_size.y / 2.0  )
	player_audio_generator.set_volume(player_scale_target * 16.0 - 16.0)
	
	reference_audio_generator.set_pitch((reference_node.position.y + mesh_size.y ) / mesh_size.y / 2.0  )
	reference_audio_generator.set_volume(reference_scale_target * 16.0 - 16.0)
	
	#audio_generator.set_pitch(reference_target)
	#audio_generator.set_volume(reference_scale_target)


##########################################################

func get_serial_value(value):
	var diff = max_hand_distance - min_hand_distance
	return (clamp(value, min_hand_distance, max_hand_distance) - min_hand_distance) / diff

func handle_player_amplitude(delta: float) -> void:
	if serial.is_connected:
		player_scale_target = move_toward(player_scale_target, 1.0 - get_serial_value(serial.value_b), delta * 2.0)
	else:
		player_scale_target = clamp(get_global_mouse_position().x / mesh_size.x, 0, 1)


func handle_player_height(delta: float) -> void:
	if serial.is_connected:
		player_target = get_serial_value(serial.value_a) * mesh_size.y * 2.0 - mesh_size.y
	else:
		player_target = get_global_mouse_position().y
	
	var player_target_dist = abs(player_target - player_node.position.y) / 100.0
	player_current_speed = move_toward(player_current_speed, sign(player_target - player_node.position.y) * player_speed * player_target_dist, delta * player_rotation_speed)
	player_node.position.y += player_current_speed


func handle_reference_track(delta: float) -> void:
	var reference_target_dist = abs(reference_target - reference_node.position.y) / 100.0
	reference_current_speed = move_toward(reference_current_speed, sign(reference_target - reference_node.position.y) * reference_speed * reference_target_dist, delta * reference_rotation_speed)
	reference_node.position.y += reference_current_speed


func handle_main_game(delta: float) -> void:
	if abs(player_node.position.y - reference_target) < pitch_validation_distance * 500.0 and abs(player_scale_target - reference_scale_target) < volume_validation_distance:
		state += delta
	set_progress_bar_value(state)
	if state >= 1.0 or Time.get_ticks_msec() / 1000.0 - current_time_to_reach > time_to_reach:
		if state >= 1.0:
			game_renderer.emit_score_feedback()
			display_completion_feedbacks(true)
		target_note_index += 1
		set_target_note(target_notes[target_note_index % target_notes.size()], randf())

func display_completion_feedbacks(buildup:=false):
		game_renderer.emit_score_feedback()
		AudioEffectManager.audio_completion.play()
		if buildup: AudioEffectManager._track_buildup()

##########################################################

func set_target_note(pitch_value: float, volume_value: float = 1.0):
	current_time_to_reach = Time.get_ticks_msec() / 1000.0
	reference_target = pitch_value * mesh_size.y * 2.0 - mesh_size.y
	reference_scale_target = volume_value
	state = 0


func set_progress_bar_value(value):
	progress_bar.value = clamp(value, 0.04, 1.0)
