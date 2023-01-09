extends Spatial

onready var things = $Things
var emitted_tiles = 0

export(PackedScene) var emit_scene = preload("res://Scenes/Silo/SiloThing.tscn")

func _physics_process(_delta):
	if Input.is_action_just_released("clear_silo_things") and Net.is_offline:
		print_stack()
		print("Removing all emitted tiles...")
		for child in things.get_children():
			things.remove_child(child)

func _timeout():
	emit(Net.net_id, emitted_tiles)
	emitted_tiles += 1
	if not Net.is_offline:
		rpc("emit", Net.net_id, emitted_tiles)

remote func emit(id, index):
	if emit_scene != null:
		var emitting_tile = emit_scene.instance()
		things.add_child(emitting_tile)
		if not Net.is_offline:
			emitting_tile.initialize(id)
			emitting_tile.name = str("ID", id, "_INDEX", index)

func start_emitting(body):
	if emit_scene != null and body is Vehicle and (body.is_master or Net.is_offline):
		print_stack()
		print("Sart emitting...")
		$EmitTimer.start()

func stop_emitting(body):
	if body is Vehicle and (body.is_master or Net.is_offline):
		print_stack()
		print("Stop emitting...")
		$EmitTimer.stop()

func set_emit_time(value: float):
	$EmitTimer.wait_time = value
