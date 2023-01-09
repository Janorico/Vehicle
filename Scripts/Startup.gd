extends Control

export(String) var agreed_file_path := "user://license.agreed"
# Vehicles
export(NodePath) var car_button: NodePath
export(NodePath) var quad_bike_button: NodePath
export(NodePath) var truck_button: NodePath
export(NodePath) var tractor_button: NodePath
export(NodePath) var minibus_button: NodePath
export(NodePath) var large_dump_truck_button: NodePath
# Worlds
export(NodePath) var sketchup_world_button: NodePath
export(NodePath) var gridmap_world_button: NodePath
export(NodePath) var real_world_button: NodePath
#
export(NodePath) var day_night_cycle_button: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	# OS.min_window_size = Vector2(800, 900)
	var file = File.new()
	if file.file_exists(agreed_file_path):
		file.open(agreed_file_path, File.READ)
		if file.get_as_text() != "agreed":
			$LicenseInformationDialog.popup_centered()
		file.close()
	else:
		$LicenseInformationDialog.popup_centered()
	$HostNetworkGameDialog/GridContainer/NameLineEdit.text = Global.last_typed_name
	$HostNetworkGameDialog/GridContainer/MaximumPlayersSpinBox.value = Global.last_max_players
	$JoinNetworkGameDialog/GridContainer/NameLineEdit.text = Global.last_typed_name
	$JoinNetworkGameDialog/GridContainer/IPLineEdit.text = Global.last_typed_server_ip

func _license_agreed():
	var file = File.new()
	if !file.file_exists(agreed_file_path):
		file.open(agreed_file_path, File.WRITE_READ)
		file.store_string("agreed")
		file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _exit():
	get_tree().quit(0)

func _start_offline_game():
	var wait_page = load_wait_page()
	change_scene(wait_page)
	wait_page.offline(get_selected_info(""), get_day_night_cycle(), get_selected_world())

func change_scene(new_scene: Node):
	get_parent().add_child(new_scene)
	queue_free()

func get_day_night_cycle():
	return get_node(day_night_cycle_button).is_pressed()

func get_selected_world():
	if get_node(sketchup_world_button).is_pressed():
		return Global.Worlds.SKETCHUP_WORLD
	elif get_node(gridmap_world_button).is_pressed():
		return Global.Worlds.GRIDMAP_WORLD
	elif get_node(real_world_button).is_pressed():
		return Global.Worlds.REAL_WORLD

func get_selected_vehicle():
	if get_node(car_button).is_pressed():
		return Global.Vehicles.CAR
	elif get_node(quad_bike_button).is_pressed():
		return Global.Vehicles.QUAD_BIKE
	elif get_node(truck_button).is_pressed():
		return Global.Vehicles.TRUCK
	elif get_node(tractor_button).is_pressed():
		return Global.Vehicles.TRACTOR
	elif get_node(minibus_button).is_pressed():
		return Global.Vehicles.MINIBUS
	elif get_node(large_dump_truck_button).is_pressed():
		return Global.Vehicles.LARGE_DUMP_TRUCK

func get_selected_info(name: String): return {
	"vehicle" : get_selected_vehicle(),
	"name" : name
}

func load_wait_page():
	return load("res://Scenes/WaitPage.tscn").instance()

func _join_network_game():
	var ip = $JoinNetworkGameDialog/GridContainer/IPLineEdit.text
	var name = $JoinNetworkGameDialog/GridContainer/NameLineEdit.text
	if ip.is_valid_ip_address():
		if name != "":
			Global.last_typed_name = name
			Global.last_typed_server_ip = ip
			Global.save_last_states()
			var wait_page = load_wait_page()
			change_scene(wait_page)
			wait_page.join(ip, get_selected_info(name))
		else:
			$InvalidNameDialog.popup_centered()
	else:
		$InvalidIPAddressDialog.popup_centered()

func _host_network_game():
	var name = $HostNetworkGameDialog/GridContainer/NameLineEdit.text
	if name != "":
		var max_players = $HostNetworkGameDialog/GridContainer/MaximumPlayersSpinBox.value
		Global.last_typed_name = name
		Global.last_max_players = max_players
		Global.save_last_states()
		var wait_page = load_wait_page()
		change_scene(wait_page)
		wait_page.host(max_players,
			get_selected_info(name), get_day_night_cycle(), get_selected_world())
	else:
		$InvalidNameDialog.popup_centered()
