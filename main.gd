@tool
extends Node2D

@onready var serial: Node2D = $Serial

@export var reference_particles: GPUParticles2D
@export var player_particles: GPUParticles2D
@export var reference_node: Node2D
@export var player_node: Node2D
@export var state_fill_rect: TextureRect

@export var player_color: Color
@export var reference_color: Color

@export var target_notes : Array[float]
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

@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
@export var blit_material: ShaderMaterial

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
	reference_target = pitch_value * mesh_size.y * 2.0 - mesh_size.y
	reference_scale_target = volume_value
	state = 0


func _process(delta: float) -> void:
	if serial.is_connected:
		player_target = serial.value_a / 40.0 * mesh_size.y - mesh_size.y / 2.0
		reference_target = serial.value_b / 40.0 * mesh_size.y - mesh_size.y / 2.0
	else:
		player_target = get_global_mouse_position().y
		player_scale_target = get_global_mouse_position().x / mesh_size.x
	
	
	var player_target_dist = abs(player_target - player_node.position.y) / 100.0
	player_current_speed = move_toward(player_current_speed, sign(player_target - player_node.position.y) * player_speed * player_target_dist, delta * player_rotation_speed)
	player_node.position.y += player_current_speed
	#player_particles.scale = player_particles.scale.move_toward(get_global_mouse_position().x / mesh_size.x * Vector2.ONE, delta)
	
	#reference_particles.scale = reference_particles.scale.move_toward(reference_scale_target * Vector2.ONE, delta)
	var reference_target_dist = abs(reference_target - reference_node.position.y) / 100.0
	reference_current_speed = move_toward(reference_current_speed, sign(reference_target - reference_node.position.y) * reference_speed * reference_target_dist, delta * reference_rotation_speed)
	reference_node.position.y += reference_current_speed 
	
	state = move_toward(state, 1.0 if abs(player_target - reference_target) < 50 and abs(player_scale_target - reference_scale_target) < 0.1 else 0.0, delta)
	state_fill_rect.scale = Vector2(state, 1.0)
	if state == 1.0:
		target_note_index += 1
		set_target_note(target_notes[target_note_index % target_notes.size()], randf())
	
	draw_to_texture()
	queue_redraw()

func _draw() -> void:
	draw_circle(player_node.position, 10.0 + player_scale_target * 30.0, player_color, false, 3, true)
	draw_circle(reference_node.position, 10.0 + reference_scale_target * 30.0, reference_color, false, 3, true)
	pass
