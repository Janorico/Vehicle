extends RigidBody

var is_master = false

func initialize(id):
	is_master = id == Net.net_id

func _physics_process(_delta):
	if is_master and not Net.is_offline:
		rpc("update", translation, rotation_degrees, linear_velocity, angular_velocity)

remote func update(pos, rot, lv, av):
	translation = pos
	rotation_degrees = rot
	linear_velocity= lv
	angular_velocity = av
