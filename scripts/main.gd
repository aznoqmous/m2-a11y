extends Node2D

@onready var serial: Node2D = $Serial

@export_category("Colors")
@export var player_color: Color
@export var reference_color: Color

@export_category("Game")
@export var target_notes : Array[float]
@export var time_to_reach := 10.0
@export var hand_distance := 30.0
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
@export var feedback_particles: GPUParticles2D
@export var reference_node: Node2D
@export var player_node: Node2D
@export var state_fill_rect: TextureRect
@export var blit_material: ShaderMaterial
@export var progress_bar: ProgressBar

@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D

var drawable_texture: DrawableTexture2D
var mesh_size : Vector2
func _ready() -> void:
	drawable_texture = DrawableTexture2D.new()
	mesh_instance_2d.texture = drawable_texture
	mesh_size = get_viewport_rect().size / 2.0
	drawable_texture.setup(mesh_size.x, mesh_size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color.WHITE)
	mesh_instance_2d.mesh.set("size", mesh_size)
	
	player_node.position.y = 0.0
	reference_node.position.y = 0.0
	set_target_note(target_notes[target_note_index], 0.5)
	
	
func draw_to_texture():
	var mouse_position = get_global_mouse_position() + mesh_size / 2.0
	var rect = Rect2(mouse_position.x, mesh_size.y - mouse_position.y, 10, 10)
	drawable_texture.blit_rect(rect, preload("res://sprites/brush.png"), Color.BLACK, 0, blit_material)

func set_target_note(pitch_value: float, volume_value:float):
	current_time_to_reach = Time.get_ticks_msec() / 1000.0
	reference_target = pitch_value * mesh_size.y * 2.0 - mesh_size.y
	reference_scale_target = volume_value
	state = 0


func _process(delta: float) -> void:
	if serial.is_connected:
		player_target = clamp(serial.value_a, 0, hand_distance) / hand_distance * mesh_size.y * 2.0 - mesh_size.y
		player_scale_target = move_toward(player_scale_target, 1.0 - clamp(serial.value_b, 0, hand_distance) / hand_distance, delta * 2.0)
	else:
		player_target = get_global_mouse_position().y
		player_scale_target = get_global_mouse_position().x / mesh_size.x
	
	AudioEffectManager.player_scale = player_scale_target
	AudioEffectManager.target_scale = reference_scale_target

	var player_target_dist = abs(player_target - player_node.position.y) / 100.0
	player_current_speed = move_toward(player_current_speed, sign(player_target - player_node.position.y) * player_speed * player_target_dist, delta * player_rotation_speed)
	player_node.position.y += player_current_speed
	#player_particles.scale = player_particles.scale.move_toward(get_global_mouse_position().x / mesh_size.x * Vector2.ONE, delta)
	
	#reference_particles.scale = reference_particles.scale.move_toward(reference_scale_target * Vector2.ONE, delta)
	var reference_target_dist = abs(reference_target - reference_node.position.y) / 100.0
	reference_current_speed = move_toward(reference_current_speed, sign(reference_target - reference_node.position.y) * reference_speed * reference_target_dist, delta * reference_rotation_speed)
	reference_node.position.y += reference_current_speed 
	

	if abs(player_target - reference_target) < pitch_validation_distance * 500.0 and abs(player_scale_target - reference_scale_target) < volume_validation_distance:
		state += delta
		print("Volume and pitch are matching")
	
	AudioEffectManager._value_snapping()
	AudioEffectManager._fx_application()
	
	state_fill_rect.scale = Vector2(state, 1.0)
	set_progress_bar_value(state)
	
	if state >= 1.0 or Time.get_ticks_msec() / 1000.0 - current_time_to_reach > time_to_reach:
		if state >= 1.0:
			feedback_particles.emitting = true
		
		AudioEffectManager.audio_completion.play()
		target_note_index += 1
		set_target_note(target_notes[target_note_index % target_notes.size()], randf())
	
	player_audio_generator.set_pitch((player_node.position.y + mesh_size.y ) / mesh_size.y / 2.0  )
	player_audio_generator.set_volume(player_scale_target * 16.0 - 16.0)
	
	reference_audio_generator.set_pitch((reference_node.position.y + mesh_size.y ) / mesh_size.y / 2.0  )
	reference_audio_generator.set_volume(reference_scale_target * 16.0 - 16.0)
	
	#audio_generator.set_pitch(reference_target)
	#audio_generator.set_volume(reference_scale_target)
	
	draw_to_texture()
	queue_redraw()

func set_progress_bar_value(value):
	progress_bar.value = clamp(value, 0.04, 1.0)

func _draw() -> void:
	draw_circle(player_node.position, 10.0 + player_scale_target * 30.0, player_color, false, 3, true)
	draw_circle(reference_node.position, 10.0 + reference_scale_target * 30.0, reference_color, false, 3, true)
	pass
