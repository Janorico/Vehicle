extends WorldEnvironment

export(float) var background_energy: float setget set_bg_energy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_bg_energy(energy):
	get_environment().set_bg_energy(energy)
