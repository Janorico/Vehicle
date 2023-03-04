class_name DumpTruck extends Vehicle

var tipping := false

func _physics_process(_delta):
	if Net.is_offline or is_master:
		if Input.is_action_just_released("toggle_extra"):
			tipping = not tipping
			var animation_name
			if tipping:
				animation_name = "Tipping"
			else:
				animation_name = "UndoTipping"
			play_animation(animation_name)
			if not Net.is_offline:
				rpc("play_animation", animation_name)

remote func play_animation(name: String):
	$AnimationPlayer.play(name)
