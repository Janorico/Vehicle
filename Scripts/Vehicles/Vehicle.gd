class_name Vehicle extends VehicleBody

enum CameraType {
	WINDSCREEN = 0,
	LEFT = 1,
	RIGHT = 2,
	CENTER = 3
}

enum InputType {
	KEYBOARD = 0,
	MOUSE = 1,
	SERIAL_PORT = 2
}

# TODO: Smoke
#export(int, 20, 50) var min_smoke := 20
#export(float) var smoke_multiplicator := 1.0
#export(int, 50, 80) var max_smoke := 80
# Camera options
export(CameraType) var camera := CameraType.WINDSCREEN
# Steer options
export(float) var steer_speed := 1.5
export(float) var steer_limit := 0.4
# Engine force and brake options
export(int) var engine_force_value := 40
export(float) var brake_value := 1.0
# Light options
export(float, 0.0, 16.0) var front_light_energy := 16.0
export(float, 0.0, 16.0) var back_light_energy := 6.0
export(float, 0.0, 16.0) var backward_light_energy := 10.0
export(float, 20.0, 100.0) var front_light_range_low_beam := 40.0
export(float, 20.0, 100.0) var front_light_range_high_beam := 100.0
# Control (Keyboard/Mouse/Serial port)
var input_type = InputType.KEYBOARD
var handbrake := false
var light := false
var backward_light_on := false
var steer_target := 0.0
const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var port = SERCOMM.new()
# Values to reset on pressing 'R'.
onready var start_translation = get_translation()
onready var start_rotation = get_rotation_degrees()
# Multiplayer data
var is_master = false
var player_id = null

func _ready():
	if Net.is_offline:
		camera = Global.last_used_view
		update_camera()

func initialize(id):
	is_master = id == Net.net_id
	player_id = id
	if is_master:
		camera = Global.last_used_view
		update_camera()
	else:
		$RightMirror.queue_free()
		$RightMirrorPlaceHolder.queue_free()
		$LeftMirror.queue_free()
		$LeftMirrorPlaceHolder.queue_free()

func set_player_name(player_name: String):
	$NameLabel3D.show()
	$NameLabel3D.text = player_name

func _physics_process(delta):
	if is_master or Net.is_offline:
		if input_type == InputType.KEYBOARD:
			steer_target = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
			steering = move_toward(steering, steer_target * steer_limit, steer_speed * delta)
			# Accelerate
			if Input.is_action_pressed("accelerate"): accelerate(engine_force_value)
			else: engine_force = 0
			# Accelerate back
			if Input.is_action_pressed("accelerate_back"): accelerate_back(engine_force_value)
			# Brake
			if Input.is_action_just_released("handbreak"):
				handbrake = not handbrake
				get_node("../..").handbrake_toggled(handbrake)
			if Input.is_action_pressed("brake") or handbrake: brake = brake_value
			else: brake = 0.0
		elif input_type == InputType.MOUSE:
			if Input.is_action_pressed("mouse_accelerate"): accelerate(engine_force_value)
			else: engine_force = 0
			if Input.is_action_pressed("mouse_accelerate_back"): accelerate_back(engine_force_value)
			if Input.is_action_pressed("mouse_brake"): brake = brake_value
			else: brake = 0
		elif input_type == InputType.SERIAL_PORT:
			var input = ""
			if port.get_available() > 0:
				for _i in range(port.get_available()):
					var part = String(port.read())
					input = String.join([input, part])
			input = input.split(";")
			if input.size() == 4:
				# Steering
				var steering_input = float(input[0])
				if steering_input >= -1 and steering_input <= 1:
					steering = steering_input * steer_limit
				# Engine force
				var engine_force_input = float(input[1])
				var backward_input = int(input[2])
				if engine_force_input > 0.0 and engine_force_input <= 1.0:
					accelerate(engine_force_value * engine_force_input)
					if backward_input == 1:
						engine_force = -engine_force
				else:
					engine_force = 0
				# Brake
				var brake_input = int(input[3])
				if brake_input == 1:
					brake = brake_value
				else:
					brake = 0.0
		else:
			steer_target = 0
			engine_force = 0
			brake = 0
		if Input.is_action_just_released("reset"):
			translation = start_translation
			rotation_degrees = start_rotation
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			sleeping = false
		if engine_force < 0.0 and backward_light_on == false and light == true:
			update_backward_light_energy(true)
			backward_light_on = true
		if engine_force > 0.0 and backward_light_on == true:
			update_backward_light_energy(false)
			backward_light_on = false
		# TODO: Smoke too
		#$Smoke.amount = clamp(engine_force * smoke_multiplicator, min_smoke, max_smoke)
		if not Net.is_offline:
			rpc("update_all", translation, rotation_degrees, steering, engine_force, brake)
		$LeftMirror/Viewport/Camera.global_transform = $LeftMirrorPlaceHolder.global_transform
		$RightMirror/Viewport/Camera.global_transform = $RightMirrorPlaceHolder.global_transform
		$LeftMirror/Viewport/Camera.translation += (linear_velocity / 80)
		$RightMirror/Viewport/Camera.translation += (linear_velocity / 80)

func accelerate(value: float):
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed = linear_velocity.length()
	if speed < 5 and speed != 0:
		engine_force = clamp(value * 5 / speed, 0, 100)
	else:
		engine_force = value

func _input(event):
	if input_type == InputType.MOUSE and event is InputEventMouseMotion:
		steer_target += Global.inverse(event.relative.x * 0.001)
		steering = clamp(steer_target, -steer_limit, steer_limit)

func accelerate_back(value: float):
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed = linear_velocity.length()
	if speed < 5 and speed != 0:
		engine_force = -clamp(value * 5 / speed, 0, 100)
	else:
		engine_force = -value

remote func update_all(pos, rot, s, ef, b):
	translation = pos
	rotation_degrees = rot
	steering = s
	engine_force = ef
	brake = b

#remote func update_position(pos):
#	translation = pos

#remote func update_rotation(rot):
#	rotation_degrees = rot

func get_ports():
	return port.list_ports()

func control_with_serial_port(port_name):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if port_name != null:
		set_physics_process(false)
		port.close()
		port.open(port_name, 2000000, 1000)
		input_type = InputType.SERIAL_PORT
		set_physics_process(true)

func control_with_keyboard():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	port.close()
	input_type = InputType.KEYBOARD
	steer_target = 0

func control_with_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	port.close()
	input_type = InputType.MOUSE
	steer_target = 0

# Button functions
func switch_view():
	camera = (camera + 1) % 4
	update_camera()
	Global.last_used_view = camera
	Global.save_last_states()

func update_camera():
	if camera == CameraType.LEFT:
		$LeftCamera.make_current()
	if camera == CameraType.RIGHT:
		$RightCamera.make_current()
	if camera == CameraType.CENTER:
		$CenterCamera.make_current()
	if camera == CameraType.WINDSCREEN:
		$WindscreenCamera.make_current()

func no_beam():
	update_light_energy(false)
	light = false

func low_beam():
	update_light_energy(true)
	update_light_range(front_light_range_low_beam)
	light = true

func high_beam():
	update_light_energy(true)
	update_light_range(front_light_range_high_beam)
	light = true

func update_backward_light_energy(on: bool):
	var energy := 0.0
	if on: energy = backward_light_energy
	change_backward_light_energy(energy)
	if not Net.is_offline:
		rpc("change_backward_light_energy", energy)

func update_light_energy(on: bool):
	var front_energy := 0.0
	var back_energy := 0.0
	if on:
		front_energy = front_light_energy
		back_energy = back_light_energy
	# Applying changes
	change_light_energy(front_energy, back_energy)
	if not Net.is_offline:
		rpc("change_light_energy", front_energy, back_energy)

func update_light_range(front_range: float):
	change_light_range(front_range)
	if not Net.is_offline:
		rpc("change_light_range", front_range)

remote func change_backward_light_energy(energy: float):
	$BackwardLight.light_energy = energy

remote func change_light_energy(front_energy: float, back_energy: float):
	$LeftFrontLight.light_energy = front_energy
	$RightFrontLight.light_energy = front_energy
	$LeftBackLight.light_energy = back_energy
	$RightBackLight.light_energy = back_energy

remote func change_light_range(front_range: float):
	$LeftFrontLight.spot_range = front_range
	$RightFrontLight.spot_range = front_range

func _crash(_body):
	play_crash_sound()
	if not Net.is_offline and is_master:
		rpc("play_crash_sound")

remote func play_crash_sound():
	$CrashSound.play()
