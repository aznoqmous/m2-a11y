extends Node2D


@onready var _asp: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
var playback # Will hold the AudioStreamGeneratorPlayback.
@onready var sample_hz = _asp.stream.mix_rate
var pulse_hz = 440.0 # The frequency of the sound wave.
var phase = 0.0
var pitch_control : float
var volume_control : float
@onready var AudioEffetManager: Node = $"../AudioEffetManager"


func _ready():
	_asp.play()
	playback = _asp.get_stream_playback()
	fill_buffer()

func fill_buffer():
	var increment = pulse_hz / sample_hz
	var frames_available = playback.get_frames_available()

	for i in range(frames_available):
		playback.push_frame(Vector2.ONE * sin(phase * TAU) * cos(phase * TAU))
		phase = fmod(phase + increment, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("ui_accept")):
		fill_buffer()
		AudioEffectManager._note_validity()
	if(Input.is_action_just_pressed("ui_up")):
		_asp.pitch_scale -= 0.1
		print(_asp.pitch_scale)
	if(Input.is_action_just_pressed("ui_down")):
		_asp.pitch_scale += 0.1
		print(_asp.pitch_scale)
	if(Input.is_action_just_pressed("ui_right")):
		_asp.volume_db += 0.5
		print(_asp.volume_db)
	if(Input.is_action_just_pressed("ui_left")):
		_asp.volume_db -= 0.5
		print(_asp.volume_db)
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		_asp.volume_db = 0
		print("Volume reset")
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		_asp.pitch_scale = 1
		print("Pitch reset")
	
	pitch_control = ((get_local_mouse_position().y / 300)*-1)+0.5
	if(pitch_control <=0):
		pitch_control = 0
	#print(pitch_control)
	_asp.pitch_scale = pitch_control
	volume_control = (get_local_mouse_position().x / 50)
	#print(volume_control)
	_asp.volume_db = volume_control
		
		
	pass
