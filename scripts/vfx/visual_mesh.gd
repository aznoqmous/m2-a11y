@tool
extends Node2D

@export var blit_material: ShaderMaterial
@export var subviewport_mesh_instance_2d: MeshInstance2D
var mesh_size : Vector2

func _ready() -> void:
	mesh_size = get_viewport_rect().size / 2.0
