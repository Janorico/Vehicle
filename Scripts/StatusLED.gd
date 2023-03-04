tool
class_name StatusLED extends Control

export var enabled: bool = false
export var enabled_texture: Texture = preload("res://Assets/2D/EnabledLED.png")
export var disabled_texture: Texture = preload("res://Assets/2D/DisabledLED.png")

func _init():
	rect_min_size = Vector2(14, 14)
	rect_size = Vector2(14, 14)

func _process(_delta):
	update()

func _draw():
	if enabled: draw_texture(enabled_texture, Vector2(0, 0))
	else: draw_texture(disabled_texture, Vector2(0, 0))
