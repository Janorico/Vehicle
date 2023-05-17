class_name Vehicle extends VehicleBase

var handbrake := false
var braking := false
var backward_light_on := false
const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var port = SERCOMM.new()


func _ready():
	if OS.is_debug_build() and capturing:
		$Smoke.emitting = false
		$LeftMirror.queue_free()
		$RightMirror.queue_free()
		$RightMirrorPlaceHolder.queue_free()
		$LeftMirrorPlaceHolder.queue_free()


func initialize(id):
	.initialize(id)
	if not is_master:
		$RightMirror.queue_free()
		$RightMirrorPlaceHolder.queue_free()
		$LeftMirror.queue_free()
		$LeftMirrorPlaceHolder.queue_free()


func _physics_process(delta):
	if (is_master or Net.is_offline) and enabled:
		if input_type == InputType.KEYBOARD:
			# Steering
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
			braking = Input.is_action_pressed("brake") or handbrake
		elif input_type == InputType.MOUSE:
			steering = clamp(steer_target, -steer_limit, steer_limit)
			if Input.is_action_pressed("mouse_accelerate"): accelerate(engine_force_value)
			else: engine_force = 0
			if Input.is_action_pressed("mouse_accelerate_back"): accelerate_back(engine_force_value)
			braking = Input.is_action_pressed("mouse_brake")
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
				braking =  brake_input == 1
		else:
			steer_target = 0
			engine_force = 0
			brake = 0
		# Braking
		if braking: brake = brake_value
		else: brake = 0.0
		# Backward light
		if engine_force < 0.0 and backward_light_on == false and light == true:
			update_backward_light_energy(true)
			backward_light_on = true
		if engine_force > 0.0 and backward_light_on == true:
			update_backward_light_energy(false)
			backward_light_on = false

func control_with_mouse():
	.control_with_mouse()
	port.close()

func control_with_keyboard():
	.control_with_keyboard()
	port.close()

func control_with_serial_port(port_name):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if port_name != null:
		set_physics_process(false)
		port.close()
		port.open(port_name, 2000000, 1000)
		input_type = InputType.SERIAL_PORT
		set_physics_process(true)


func get_ports():
	return port.list_ports()


func set_engine_force_value(value):
	.set_engine_force_value(value)
	power_max = engine_force_value * 2.5
	power_min = -power_max


func get_power(): return engine_force

func accelerate(value: float):
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed = linear_velocity.length()
	if speed < 5 and speed != 0:
		engine_force = clamp(value * 5 / speed, 0, power_max)
	else:
		engine_force = value


func accelerate_back(value: float):
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed = linear_velocity.length()
	if speed < 5 and speed != 0:
		engine_force = -clamp(value * 5 / speed, 0, power_max)
	else:
		engine_force = -value
