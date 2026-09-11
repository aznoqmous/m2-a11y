@tool
extends Node2D
class_name TrailNode

@export var is_display_height : bool = true
@export var is_display_amplitude : bool = true


@export_category("Nodes")
@export var line: Line2D
@export var indicator_node: Node2D

func _process(delta: float) -> void:
	line.visible = is_display_height
	indicator_node.visible = is_display_amplitude
