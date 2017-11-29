extends Control

onready var viewport = get_viewport()

func _ready():
	var monSize = OS.get_screen_size()
	print("Size: " + str(monSize))
	print("DPI: " + str(OS.get_screen_dpi()))
	if monSize == Vector2(1920,1080):
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_size(Vector2(1024,576))
		OS.set_window_position(Vector2(10,10))
