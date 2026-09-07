@tool extends Node2D

var serial: GdSerial
var is_connected: bool = false

func _ready():
	connect_port()

func connect_port():
	serial = GdSerial.new()
	
	var ports = serial.list_ports()
	print("Available ports: ", ports) # affiche les ports disponible
	
	
	for port in ports:
		# Configuration et connexion unique
		serial.set_port(ports[ports.size()-1].port_name)  # Ajustez selon votre système
		serial.set_baud_rate(115200)
		
		# Ouvre la connexion une seule fois et la maintient ouverte
		if serial.open():
			is_connected = true
			print("Connecté")
			break
		else:
			print("Échec de la connexion")

func _process(delta: float) -> void:
	if is_connected:
		monitor_serial()

var value : float
func monitor_serial():
	# Vérifie si des données sont disponibles avant d'essayer de lire
	var bytes_count = serial.bytes_available()
	if bytes_count > 0:
		var data = serial.readline()
		if not data or not str_to_var(data): return;
		value = str_to_var(data)
		if data != "":
			print("Monitor: ", data)
			# Traite vos données ici
	
	serial.clear_buffer()

func _exit_tree():
	# Nettoie les ressources à la fermeture
	if is_connected:
		serial.close()
