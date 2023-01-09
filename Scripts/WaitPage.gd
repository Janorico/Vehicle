extends CenterContainer

func _init():
	# warning-ignore:return_value_discarded
	Net.connect("connected_to_server", self, "server_connected")
	# warning-ignore:return_value_discarded
	Net.connect("connection_failed", self, "connection_failed")

func server_disconnected():
	$VBoxContainer/Label.text = "SERVER_DISCONNECTED_KEY"
	$VBoxContainer/Button.show()

func server_connected():
	$VBoxContainer/Label.text = "CONNECTION_SUCCESS_KEY"
	if not Net.is_host:
		start_network_game()

func connection_failed():
	$VBoxContainer/Label.text = "CONNECTION_FAILED_KEY"
	$VBoxContainer/Button.show()

func host(max_players, info, day_night_cycle, world):
	Net.max_players = max_players
	Global.setup(day_night_cycle, world)
	Net.initialize_server(info)
	start_network_game()

func join(ip, info):
	$VBoxContainer/Label.text = "CONNECTING_TO_SERVER_KEY"
	Net.initialize_client(ip, info)

func offline(info, day_night_cycle, world):
	$VBoxContainer/Label.text = "STARTING_OFFLINE_GAME_KEY"
	Net.is_offline = true
	Net.my_info = info
	Global.setup(day_night_cycle, world)
	change_scene("res://Scenes/Main.tscn")

remote func start_network_game():
	Net.net_id = get_tree().get_network_unique_id()
	change_scene("res://Scenes/Main.tscn")

func change_scene(path: String):
	$VBoxContainer/Label.text = "LOADING_KEY"
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_parent().add_child(load(path).instance())
	queue_free()

func _play_again():
	change_scene("res://Scenes/Startup.tscn")
