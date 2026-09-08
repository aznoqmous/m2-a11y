extends Node

@export

var master_bus: int

var master_fx_chorus: AudioEffect
var master_fx_compressor: AudioEffect
var master_fx_distortion: AudioEffect

var fx_count : int 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	if(master_bus == null):
		print("No master bus to be found")
	print(master_bus)
	
	fx_count = AudioServer.get_bus_effect_count(0)
	print(fx_count)
	
	master_fx_chorus = AudioServer.get_bus_effect(master_bus, 0)
	master_fx_compressor = AudioServer.get_bus_effect(master_bus, 1)
	master_fx_distortion = AudioServer.get_bus_effect(master_bus, 2)
	
func _note_validity() -> void:
	master_fx_chorus.set_dry(1)
	print(master_fx_chorus.get_dry())
	pass
