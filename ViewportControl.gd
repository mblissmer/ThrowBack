extends Control

onready var viewport = get_viewport()
var resNum = 0

func _ready():
	if OS.get_name() == "HTML5":
		defaultView()
	else:
		var monSize = OS.get_screen_size()
		if monSize == Vector2(1920,1080):
			resNum = 0
			OS.set_window_fullscreen(true)
		elif monSize == Vector2(1600,900):
			resNum = 1
			OS.set_window_size(monSize)
			OS.set_window_fullscreen(true)
		elif monSize == Vector2(1280,720):
			resNum = 2
			OS.set_window_size(monSize)
			OS.set_window_fullscreen(true)
		else:
			defaultView()

func defaultView():
	resNum = 3
	OS.set_window_size(Vector2(1024,576))
	OS.set_window_position(Vector2(10,10))