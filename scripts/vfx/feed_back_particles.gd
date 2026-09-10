@tool
extends GPUParticles2D

func _ready() -> void:
	emitting = true
	finished.connect(func(): queue_free())
