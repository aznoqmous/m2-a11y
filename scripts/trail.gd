extends Line2D


var queue : Array
@export var MAX_length : int

func _ready() -> void:
	$"../Trail Timer".timeout.connect(_process)
	$"../Trail Timer".start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var pos = get_global_mouse_position()
	
	queue.push_front(pos)
	
	if queue.size() > MAX_length:
		queue.pop_back()
		
	clear_points()
	
	for point in queue:
		add_point(point)
	
