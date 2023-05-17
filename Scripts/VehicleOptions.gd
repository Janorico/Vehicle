extends Spatial

export(NodePath) var view_button: NodePath
export(NodePath) var handbrake_button: NodePath

func _ready():
	get_node(view_button).select(Global.last_used_view)

func _set_view(view: int):
	var vehicle = get_vehicle()
	if vehicle != null:
		vehicle.set_view(view)

func _no_beam():
	var vehicle = get_vehicle()
	if vehicle != null:
		vehicle.no_beam()

func _low_beam():
	var vehicle = get_vehicle()
	if vehicle != null:
		vehicle.low_beam()

func _high_beam():
	var vehicle = get_vehicle()
	if vehicle != null:
		vehicle.high_beam()

func get_vehicle():
	if Net.is_offline:
		if get_child_count() > 0:
			return get_child(0).get_child(0)
	else:
		var child = get_node_or_null(str(Net.net_id))
		if child != null:
			return child.get_child(0)
	return null

func _handbreak_button_toggled(button_pressed):
	var vehicle = get_vehicle()
	if vehicle != null:
		vehicle.handbrake = button_pressed

func handbrake_toggled(handbrake):
	get_node(handbrake_button).pressed = handbrake

func _exit_game():
	get_tree().quit(0)
