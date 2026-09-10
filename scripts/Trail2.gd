@tool
extends Line2D

@export var max_trail_count : int = 40
@export var timer: Timer
@export var editor_offset: float = 0.5
func _ready() -> void:
	timer.timeout.connect(updateTrail)
	timer.start()

	
func updateTrail():
	if points.size() == max_trail_count:
		remove_point(0)
	
	#if Engine.is_editor_hint():
		#get_parent().global_position = Vector2.UP * sin((Time.get_ticks_msec() / 1000.0 * 0.1 + editor_offset) * TAU) * 100.0 + Vector2(800, 300)
	add_point(get_parent().global_position)
	
	#add_point(get_parent().position)

func _process(delta: float) -> void:
	
	for i in points.size():
		set_point_position(i, points[i] + Vector2.LEFT * delta * 100.0)
		
		
