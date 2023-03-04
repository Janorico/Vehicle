extends Label

export(float, 0, 24) var hours: float = 12 setget set_hours

func set_hours(value: float):
	hours = value
	text = "%02d:%02d" % [hours, (int(floor(hours * 60.0)) % 60)]
