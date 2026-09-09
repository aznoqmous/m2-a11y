@tool
extends Line2D

@export var max_trail_count : int = 40
@export var timer: Timer

func _ready() -> void:
	timer.timeout.connect(updateTrail)
	timer.start()

func updateTrail():
	if points.size() == max_trail_count:
		remove_point(0)
	
	add_point(get_parent().position)

func _process(delta: float) -> void:
	for i in points.size():
		set_point_position(i, points[i] + Vector2.LEFT * delta * 100.0)
		
