extends Node

signal setted_up

enum Vehicles {
	CAR = 0,
	QUAD_BIKE = 1,
	TRUCK = 2,
	TRACTOR = 3,
	MINIBUS = 4,
	LARGE_DUMP_TRUCK = 5
}

enum Worlds {
	SKETCHUP_WORLD = 0,
	GRIDMAP_WORLD = 1,
	REAL_WORLD = 2
}

# Last states
var last_states_path := "user://last_states.json"
var window_state := "fullscreen"
var last_typed_name := ""
var last_typed_server_ip := ""
var last_max_players := 20
var last_used_view = Vehicle.CameraType.WINDSCREEN
# Setup
var setted_up_bool := false
var day_night_cycle := true
var world = Worlds.SKETCHUP_WORLD

remote func setup(dnc: bool, w):
	day_night_cycle = dnc
	world = w
	setted_up_bool = true
	emit_signal("setted_up")

func _ready():
	load_last_states()
	# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "save_last_states")

func _physics_process(_delta):
	if Input.is_action_just_released("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		save_last_states()
	if Input.is_action_just_released("toggle_mouse_mode"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_released("exit"):
		get_tree().quit(0)

func inverse(original):
	if original > 0:
		return -original
	if original == 0:
		return 0
	if original < 0:
		return abs(original)

func load_last_states():
	var file = File.new()
	if file.file_exists(last_states_path) == true:
		file.open(last_states_path, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		window_state = data["window_state"]
		last_typed_name = data["last_typed_name"]
		last_typed_server_ip = data["last_typed_server_ip"]
		last_max_players = data["last_max_players"]
		last_used_view = data["last_used_view"]
	set_window_state()

func set_window_state():
	if window_state == "maximized":
		OS.window_maximized = true
	elif window_state == "fullscreen":
		OS.window_fullscreen = true
	else:
		var state = parse_json(window_state)
		OS.window_size = Vector2(state["size_x"], state["size_y"])
		OS.window_position = Vector2(state["position_x"], state["position_y"])

func get_window_state():
	if OS.window_maximized:
		window_state = "maximized"
	elif OS.window_fullscreen:
		window_state = "fullscreen"
	else:
		var size = OS.window_size
		var position = OS.window_position
		window_state = to_json({
			"size_x" : size.x,
			"size_y" : size.y,
			"position_x" : position.x,
			"position_y" : position.y
		})

func save_last_states():
	get_window_state()
	var file = File.new()
	file.open(last_states_path, File.WRITE)
	var json_data = {
		"window_state" : window_state,
		"last_typed_name" : last_typed_name,
		"last_typed_server_ip" : last_typed_server_ip,
		"last_max_players" : last_max_players,
		"last_used_view" : last_used_view
	}
	file.store_line(to_json(json_data))
	file.close()

func get_vehicle_path(vehicle):
	match vehicle:
		Vehicles.CAR: return "res://Scenes/Vehicles/Car.tscn"
		Vehicles.QUAD_BIKE: return "res://Scenes/Vehicles/QuadBike.tscn"
		Vehicles.TRUCK: return "res://Scenes/Vehicles/Truck.tscn"
		Vehicles.TRACTOR: return "res://Scenes/Vehicles/Tractor.tscn"
		Vehicles.MINIBUS: return "res://Scenes/Vehicles/Minibus.tscn"
		Vehicles.LARGE_DUMP_TRUCK: return "res://Scenes/Vehicles/LargeDumpTruck.tscn"

func get_world_path():
	match world:
		Worlds.SKETCHUP_WORLD: return "res://Scenes/Worlds/SketchUpWorld/SketchUpWorld.tscn"
		Worlds.GRIDMAP_WORLD: return "res://Scenes/Worlds/GridMapWorld/GridMapWorld.tscn"
		Worlds.REAL_WORLD: return "res://Scenes/Worlds/RealWorld/RealWorld.tscn"

func get_map_path():
	match world:
		Worlds.SKETCHUP_WORLD: return "res://Assets/Navigation/SketchUpWorld.png"
		Worlds.GRIDMAP_WORLD: return "res://Assets/Navigation/GridMapWorld.png"
		Worlds.REAL_WORLD: return "res://Assets/Navigation/RealWorld.png"
	return "res://Assets/Navigation/Map.png"

func get_map_divider():
	match world:
		Worlds.SKETCHUP_WORLD: return 48.0
		Worlds.GRIDMAP_WORLD: return 1.6
		Worlds.REAL_WORLD: return 4.0
	return 48.0

func get_vehicle_start_y_translation():
	match world:
		Worlds.SKETCHUP_WORLD: return 0.0
		Worlds.GRIDMAP_WORLD: return 0.0
		Worlds.REAL_WORLD: return 27.25
	return 27.5

func get_vehicle_start_y_rotation():
	match world:
		Worlds.SKETCHUP_WORLD: return 90.0
		Worlds.GRIDMAP_WORLD: return 0.0
		Worlds.REAL_WORLD: return 0.0
	return 90.0
