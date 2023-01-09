extends HBoxContainer

enum SpeedUnit {
	METERS_PER_SECOND = 0,
	KILOMETERS_PER_HOUR = 1,
	MILES_PER_HOUR = 2
}

export(SpeedUnit) var speed_unit := SpeedUnit.KILOMETERS_PER_HOUR
var speed = 0

func _process(_delta):
	var vehicle = get_node("../../../Vehicles").get_vehicle()
	if vehicle != null:
		# Speed
		speed = vehicle.linear_velocity.length()
		match speed_unit:
			SpeedUnit.METERS_PER_SECOND: $Speedometer.content_text = "%.1f m/s" % speed
			SpeedUnit.KILOMETERS_PER_HOUR:
				speed *= 3.6
				$Speedometer.content_text = "%.0f km/h" % speed
			SpeedUnit.MILES_PER_HOUR:
				speed *= 2.23694
				$Speedometer.content_text = "%.0f mph" % speed
		$Speedometer.value = speed

func _change_speed_unit():
	speed_unit = ((speed_unit + 1) % SpeedUnit.size())
	match speed_unit:
		SpeedUnit.METERS_PER_SECOND: $Speedometer.maximum = 60
		SpeedUnit.KILOMETERS_PER_HOUR: $Speedometer.maximum = 200.0
		SpeedUnit.MILES_PER_HOUR: $Speedometer.maximum = 120
