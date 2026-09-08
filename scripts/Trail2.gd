extends Line2D

@export var MAX_TRAIl_COUNT : int = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../../Trail Timer".timeout.connect(updateTrail)
	$"../../Trail Timer".start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateTrail():

	if points.size() == MAX_TRAIl_COUNT:
		remove_point(0)
	#var pos = get_global_mouse_position()
	
	add_point($"..".position)
	
