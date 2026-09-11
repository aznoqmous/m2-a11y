@tool
extends Node2D
class_name GameRenderer

const FEED_BACK_PARTICLES = preload("res://scenes/vfx/feed_back_particles.tscn")

@export var main: Main
@export var trail_indicators_container: Node2D
@export var reference_indicatior_node: Node2D
@export var player_indicatior_node: Node2D
@export var reference_scale_indicator_node: Node2D
@export var player_scale_indicator_node: Node2D
@export var reference_trail: Line2D
@export var player_trail: Line2D
@export var mesh_instance_2d: MeshInstance2D
@export var sub_viewport: SubViewport

func _ready():
	if not main:
		push_error("No main set in GameRenderer !")
		return;
	main.ready.connect(func():
		sub_viewport.size = main.mesh_size * 2.0
		mesh_instance_2d.mesh.set("size", main.mesh_size * 2.0)
	)

func _process(delta: float) -> void:
	if not main: return;
	update_visuals(delta)
	reference_indicatior_node.rotate(delta)
	player_indicatior_node.rotate(delta)
	
func emit_score_feedback():
	var fbp = FEED_BACK_PARTICLES.instantiate()
	main.player_node.add_child(fbp)
	#fbp.position = main.player_node.position

func update_visuals(delta):
	player_indicatior_node.position = main.player_node.position
	player_indicatior_node.position.y = main.player_node.position.y
	reference_indicatior_node.position = main.reference_node.position
	player_scale_indicator_node.scale = player_scale_indicator_node.scale.move_toward(Vector2.ONE * (main.player_scale_target + 0.5), delta)
	reference_scale_indicator_node.scale = reference_scale_indicator_node.scale.move_toward(Vector2.ONE * (main.reference_scale_target + 0.5), delta)
	reference_trail.width = move_toward(reference_trail.width, main.reference_scale_target * 20.0 + 10.0, delta * 10.0)
	player_trail.width = move_toward(player_trail.width, main.player_scale_target * 20.0 + 10.0, delta * 10.0)
	var hdiff = pow((1.0 - abs(main.player_target - main.reference_target) / main.mesh_size.y), 2.0) 
	var progress = main.progress_bar.value
	mesh_instance_2d.material.set("shader_parameter/trail_power", progress * 0.5)
	mesh_instance_2d.material.set("shader_parameter/borealis_power", clamp(hdiff * 0.5, 0.2, 1.0))
	
