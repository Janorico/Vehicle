extends Node

signal connected_to_server
signal connection_failed
signal player_connected(id)
signal player_disconnected(id)

const RPC_PORT = 31400
# Max players, used in initialize_server()
var max_players = 20
# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = {}
var is_offline = false
var net_id = null
var is_host = false

func initialize_server(info: Dictionary):
	is_host = true
	my_info = info
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(RPC_PORT, max_players)
	get_tree().network_peer = peer

func initialize_client(server_ip, info: Dictionary):
	my_info = info
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, RPC_PORT)
	get_tree().network_peer = peer

# Connect all functions
func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func _on_network_peer_connected(id):
	# Called on both clients and server when a peer connects.
	if Net.is_host:
		Global.rpc_id(id, "setup", Global.day_night_cycle, Global.world)
	# Send my info to it.
	rpc_id(id, "register_player", my_info)

func _on_network_peer_disconnected(id):
	print_stack()
	print("Unregistering player ", id, "...")
	player_info.erase(id) # Erase player from info.
	emit_signal("player_disconnected", id)

func _on_connected_to_server():
	# Only called on clients, not server. Will go unused; not useful here.
	emit_signal("connected_to_server")

func _on_connection_failed():
	emit_signal("connection_failed")

func _on_server_disconnected():
	# Server kicked us; show error and abort.
	var wait_page = load("res://Scenes/WaitPage.tscn").instance()
	wait_page.server_disconnected()
	var parent = get_parent()
	parent.remove_child(parent.get_child(parent.get_child_count() - 1))
	parent.add_child(wait_page)

remote func register_player(info: Dictionary):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	print_stack()
	print("	Registering player ", id, "...")
	# Store the info
	player_info[id] = info
	# Notify all, that a new player has connected
	emit_signal("player_connected", id)
