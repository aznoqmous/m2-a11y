@tool
extends Node2D

@export var mesh_instance_2d: MeshInstance2D
@export var blit_material: ShaderMaterial
@export var texture_rect: TextureRect
var drawable_texture: DrawableTexture2D
var drawable_texture_b: DrawableTexture2D
var mesh_size : Vector2

func _ready() -> void:
	drawable_texture = DrawableTexture2D.new()
	drawable_texture_b = DrawableTexture2D.new()
	mesh_instance_2d.texture = drawable_texture
	mesh_size = get_viewport_rect().size / 2.0
	drawable_texture.setup(mesh_size.x, mesh_size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color.WHITE)
	drawable_texture_b.setup(mesh_size.x, mesh_size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color.WHITE)
	mesh_instance_2d.mesh.set("size", mesh_size)
	texture_rect.texture = drawable_texture
	pass # Replace with function body.
	
func draw_to_texture():
	var mouse_position = get_global_mouse_position() + mesh_size / 2.0
	var rect = Rect2(mouse_position.x, mesh_size.y - mouse_position.y, 10, 10)
	drawable_texture.blit_rect(rect, preload("res://sprites/brush.png"), Color.BLACK)
	var trect = Rect2(0, 0, mesh_size.x, mesh_size.y)
	#drawable_texture.blit_rect(trect, ImageTexture.create_from_image(drawable_texture.get_image()), Color.WHITE)
	drawable_texture.draw(texture_rect, Vector2.ZERO)
	

func _process(delta: float) -> void:
	#mesh_instance_2d.material.set("shader_parameter/draw_position", get_global_mouse_position())
	#mesh_instance_2d.material.set("shader_parameter/size", mesh_instance_2d.mesh.get("size"))
	draw_to_texture()
	pass
