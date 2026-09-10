@tool extends Node2D

var serial: GdSerial
var is_connected: bool = false
var value_a : float
var value_b : float

func _ready():
	connect_port()

func connect_port():
	serial = GdSerial.new()
	
	var ports = serial.list_ports()
	print("Available ports: ", ports) # affiche les ports disponible
	
	
	for port in ports:
		if ports[port].device_name == "Unknown Serial Device": continue;
		# Configuration et connexion unique
		serial.set_port(ports[port].port_name)  # Ajustez selon votre système
		serial.set_baud_rate(115200)
		
		# Ouvre la connexion une seule fois et la maintient ouverte
		if serial.open():
			is_connected = true
			print("Connection successful")
			break
		else:
			print("Connection failure")
	
	print("Serial connected" if is_connected else "Serial not connected")
	
func _process(delta: float) -> void:
	if is_connected:
		monitor_serial()

func monitor_serial():
	var bytes_count = serial.bytes_available()
	if bytes_count > 0:
		var data = serial.readline()
		if not data: return;
		var value = data.split("/")
		if not value.size() == 2: return;
		if not str_to_var(value[0]): return
		if not str_to_var(value[1]): return
		var va = str_to_var(value[0])
		var vb = str_to_var(value[1])
		if va != -1: value_a = va
		if vb != -1: value_b = vb

	
	serial.clear_buffer()

func _exit_tree():
	if is_connected:
		serial.close()
