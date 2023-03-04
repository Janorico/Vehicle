extends Control

export(String) var agreed_file_path := "user://license.agreed"
# Vehicles
export(NodePath) var car_button: NodePath
export(NodePath) var quad_bike_button: NodePath
export(NodePath) var truck_button: NodePath
export(NodePath) var tractor_button: NodePath
export(NodePath) var minibus_button: NodePath
export(NodePath) var large_dump_truck_button: NodePath
export(NodePath) var car_legacy_button: NodePath
export(NodePath) var helicopter_button: NodePath
export(NodePath) var dump_truck_button: NodePath
# Worlds
export(NodePath) var sketchup_world_button: NodePath
export(NodePath) var gridmap_world_button: NodePath
export(NodePath) var real_world_button: NodePath
#
export(NodePath) var day_night_cycle_button: NodePath

var update_data: Dictionary

func _ready():
	check_license()
	$HostNetworkGameDialog/GridContainer/NameLineEdit.text = Global.last_typed_name
	$HostNetworkGameDialog/GridContainer/PortSpinBox.value = Global.last_port
	$HostNetworkGameDialog/GridContainer/MaximumPlayersSpinBox.value = Global.last_max_players
	$JoinNetworkGameDialog/GridContainer/NameLineEdit.text = Global.last_typed_name
	$JoinNetworkGameDialog/GridContainer/PortSpinBox.value = Global.last_port
	$JoinNetworkGameDialog/GridContainer/IPLineEdit.text = Global.last_typed_server_ip
	check_for_updates()

func check_for_updates():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.name = "UpdateCheckHTTPRequest"
	http_request.connect("request_completed", self, "_update_check_completed")
	http_request.request("https://github.com/Janorico/Versions/raw/main/Vehicle.json")

func _update_check_completed(result: int, _response_code: int, _headers: PoolStringArray, body: PoolByteArray):
	if result == HTTPRequest.RESULT_SUCCESS:
		update_data = parse_json(body.get_string_from_utf8())
		if int(update_data["newest_version_key"]) > 11000:
			$UpdateDialog.popup_centered()
	else:
		$UpdateUnsuccessDialog.dialog_text += str(result)
		$UpdateUnsuccessDialog.popup_centered()

func _update():
	var http_request = HTTPRequest.new()
	.add_child(http_request)
	http_request.name = "UpdateDownloaderHTTPRequest"
	match OS.get_name():
		"Windows":
			$DownloadingUpdateRect.show()
			$DownloadingUpdateRect/AnimationPlayer.play("Inderterminate")
			http_request.connect("request_completed", self, "_windows_installer_download_completed")
			http_request.request(update_data["newest_version_windows_setup"])

func _windows_installer_download_completed(result: int, _response_code: int, _headers: PoolStringArray, body: PoolByteArray):
	if result == HTTPRequest.RESULT_SUCCESS:
		var parent_path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
		var file = File.new()
		var path = parent_path + "/Vehicle-" + update_data["newest_version_display_name"] + ".exe"
		file.open(path, File.WRITE)
		file.store_buffer(body)
		# warning-ignore:return_value_discarded
		file.close()
		OS.shell_open(path)
		get_tree().quit(0)
	else:
		$UpdateUnsuccessDialog.dialog_text += str(result)
		$UpdateUnsuccessDialog.popup_centered()

func check_license():
	var file = File.new()
	if file.file_exists(agreed_file_path):
		file.open(agreed_file_path, File.READ)
		if file.get_as_text() != "agreed":
			$LicenseInformationDialog.popup_centered()
		file.close()
	else:
		$LicenseInformationDialog.popup_centered()

func _license_agreed():
	var file = File.new()
	if !file.file_exists(agreed_file_path):
		file.open(agreed_file_path, File.WRITE_READ)
		file.store_string("agreed")
		file.close()

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
	elif get_node(car_legacy_button).is_pressed():
		return Global.Vehicles.CAR_LEGACY
	elif get_node(helicopter_button).is_pressed():
		return Global.Vehicles.HELICOPTER
	elif get_node(dump_truck_button).is_pressed():
		return Global.Vehicles.DUMP_TRUCK

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
			var port = $JoinNetworkGameDialog/GridContainer/PortSpinBox.value
			Global.last_typed_name = name
			Global.last_port = port
			Global.last_typed_server_ip = ip
			Global.save_last_states()
			var wait_page = load_wait_page()
			change_scene(wait_page)
			wait_page.join(get_selected_info(name), port, ip)
		else:
			$InvalidNameDialog.popup_centered()
	else:
		$InvalidIPAddressDialog.popup_centered()

func _host_network_game():
	var name = $HostNetworkGameDialog/GridContainer/NameLineEdit.text
	if name != "":
		var port = $HostNetworkGameDialog/GridContainer/PortSpinBox.value
		var max_players = $HostNetworkGameDialog/GridContainer/MaximumPlayersSpinBox.value
		Global.last_typed_name = name
		Global.last_port = port
		Global.last_max_players = max_players
		Global.save_last_states()
		var wait_page = load_wait_page()
		change_scene(wait_page)
		wait_page.host(get_selected_info(name), port, max_players, get_day_night_cycle(), get_selected_world())
	else:
		$InvalidNameDialog.popup_centered()
