extends Node

@export

var player_bus: int

var player_fx_chorus: AudioEffect
var player_fx_compressor: AudioEffect
var player_fx_distortion: AudioEffect

@onready var audio_completion: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player_scale: float
var target_scale: float
var audio_fx_intensity: float
var last_selected_track: int

@export var completion_feedback_queue: Array[AudioStreamPlayer2D]
@export var base_track_part_queue: Array[AudioStreamPlayer2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#base_track_part_queue
	
	
	player_bus = AudioServer.get_bus_index("Player_Note")
	if(player_bus == null):
		print("No player bus to be found")

	
	player_fx_chorus = AudioServer.get_bus_effect(player_bus, 0)
	player_fx_compressor = AudioServer.get_bus_effect(player_bus, 1)
	player_fx_distortion = AudioServer.get_bus_effect(player_bus, 2)
	if(player_fx_distortion == null):
		print("No player disto to be found")


func _value_snapping() -> void:
	audio_fx_intensity = clamp(abs(target_scale - player_scale), 0.0, 1.0)
	 #print(audio_fx_intensity)


func _fx_application() -> void:
	player_fx_chorus.set_wet(0+audio_fx_intensity)
	player_fx_chorus.set_dry(1-audio_fx_intensity)
	player_fx_compressor.set_threshold(-audio_fx_intensity*30)
	player_fx_distortion.set_drive(audio_fx_intensity/2)
	#print(player_fx_distortion.get_drive())
	#print(master_fx_chorus.get_dry())

func _track_buildup() -> void:
	last_selected_track = randf_range(0, base_track_part_queue.size())
	print(last_selected_track)
	print(base_track_part_queue.size())
	if(!base_track_part_queue.is_empty()):
		base_track_part_queue[last_selected_track].play()
		#base_track_part_queue[last_selected_track].queue_free()
		base_track_part_queue.remove_at(last_selected_track)
	pass
