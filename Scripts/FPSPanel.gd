extends Panel

onready var fps = $GridContainer/FPS
onready var x_position = $GridContainer/XPosition
onready var y_position = $GridContainer/YPosition
onready var z_position = $GridContainer/ZPosition
onready var x_rotation = $GridContainer/XRotation
onready var y_rotation = $GridContainer/YRotation
onready var z_rotation = $GridContainer/ZRotation
var vehicle = null
var position = Vector3.ZERO
var rotation = Vector3.ZERO

func _process(_delta):
	fps.text = str(Engine.get_frames_per_second())
	if vehicle != null:
		position = vehicle.translation
		rotation = vehicle.rotation_degrees
	else: vehicle = set_vehicle()
	x_position.text = "%.5f" % position.x
	y_position.text = "%.5f" % position.y
	z_position.text = "%.5f" % position.z
	x_rotation.text = "%.5f" % rotation.x
	y_rotation.text = "%.5f" % rotation.y
	z_rotation.text = "%.5f" % rotation.z

func set_vehicle():
	vehicle = get_node("../../Vehicles").get_vehicle()
