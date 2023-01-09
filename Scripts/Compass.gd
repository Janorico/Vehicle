extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var vehicle = get_node("../../../Vehicles").get_vehicle()
	if vehicle != null:
		set_rotation(vehicle.get_rotation().y)

func _update_pivoit_offset():
	set_pivot_offset(Vector2(rect_size.x / 2, rect_size.y / 2))
