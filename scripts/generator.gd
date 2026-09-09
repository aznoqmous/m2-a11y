extends Node2D
class_name AudioGenerator

@export var _asp: AudioStreamPlayer2D
@onready var AudioEffetManager: Node = $"./AudioEffetManager"
@export var audio_stream: AudioStream

func _ready():
	_asp.stream = audio_stream
	play()

func set_pitch(value):
	_asp.pitch_scale = 1.0 + clamp(1.0 - value, 0.0, 1.0)
func set_volume(value_db):
	_asp.volume_db = clamp(value_db, -99, 0)
	
func play(): _asp.play()
func stop(): _asp.stop()
