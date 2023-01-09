extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var vehicle = get_node("../../../Vehicles").get_vehicle()
	if vehicle != null:
		set_rotation_degrees(map(
			vehicle.get_steering(),
			0.8,
			-0.8,
			-60,
			60
		))

func map(x: float, in_min: float, in_max: float, out_min: float, out_max: float):
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

func _update_pivoit_offset():
	set_pivot_offset(Vector2(rect_size.x / 2, rect_size.y / 2))
