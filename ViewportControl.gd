extends Control

onready var viewport = get_viewport()

func _ready():
	if OS.get_name() == "HTML5":
		defaultView()
	else:
		var monSize = OS.get_screen_size()
		if monSize == Vector2(1920,1080):
			OS.set_window_fullscreen(true)
		elif monSize == Vector2(1600,900):
			OS.set_window_size(monSize)
			OS.set_window_fullscreen(true)
		elif monSize == Vector2(1280,720):
			OS.set_window_size(monSize)
			OS.set_window_fullscreen(true)
		else:
			defaultView()

func defaultView():
	OS.set_window_size(Vector2(1024,576))
	OS.set_window_position(Vector2(10,10))