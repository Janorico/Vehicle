extends VBoxContainer

enum SpeedUnit {
	METERS_PER_SECOND = 0,
	KILOMETERS_PER_HOUR = 1,
	MILES_PER_HOUR = 2
}

export(SpeedUnit) var speed_unit := SpeedUnit.KILOMETERS_PER_HOUR
var speed = 0
var power = 0

func _process(_delta):
	var vehicle = get_vehicle()
	if vehicle != null:
		# Speed
		speed = vehicle.local_velocity.z
		match speed_unit:
			SpeedUnit.METERS_PER_SECOND: $Items/Speedometer.content_text = "%.1f m/s" % speed
			SpeedUnit.KILOMETERS_PER_HOUR:
				speed *= 3.6
				$Items/Speedometer.content_text = "%.0f km/h" % speed
			SpeedUnit.MILES_PER_HOUR:
				speed *= 2.23694
				$Items/Speedometer.content_text = "%.0f mph" % speed
		$Items/Speedometer.value = speed
		# Power
		power = vehicle.get_power()
		$Items/Power.value = power
		$Items/Power.content_text = "%.2f" % power
		# Braking
		if vehicle is Vehicle:
			$LEDs/BrakeLED.enabled = vehicle.brake > 0.0

func get_vehicle(): return get_node("../../../Vehicles").get_vehicle()

func _change_speed_unit():
	speed_unit = ((speed_unit + 1) % SpeedUnit.size())
	match speed_unit:
		SpeedUnit.METERS_PER_SECOND: $Items/Speedometer.maximum = 60
		SpeedUnit.KILOMETERS_PER_HOUR: $Items/Speedometer.maximum = 200.0
		SpeedUnit.MILES_PER_HOUR: $Items/Speedometer.maximum = 120

func _refresh():
	var vehicle = get_vehicle()
	if vehicle != null:
		$Items/Power.minimum = vehicle.power_min
		$Items/Power.maximum = vehicle.power_max
