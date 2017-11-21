extends Control

onready var viewport = get_viewport()

func _ready():
	setSize()

func setSize():
	var monSize = OS.get_screen_size()
	if monSize == Vector2(1920,1080):
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_size(Vector2(1024,576))
		OS.set_window_position(Vector2(10,10))
	

#func window_resize():
#    var current_size = OS.get_window_size()
#
#    var scale_factor = minimum_size.y/current_size.y
#    var new_size = Vector2(current_size.x*scale_factor, minimum_size.y)
#
#    if new_size.y < minimum_size.y:
#        scale_factor = minimum_size.y/new_size.y
#        new_size = Vector2(new_size.x*scale_factor, minimum_size.y)
#    if new_size.x < minimum_size.x:
#        scale_factor = minimum_size.x/new_size.x
#        new_size = Vector2(minimum_size.x, new_size.y*scale_factor)
#
#    viewport.set_size_override(true, new_size)
#
#func fullscreen(res, full):
#	if full:
#		OS.set_window_size(res)
#		window_resize()
#		OS.set_window_fullscreen(full)
#	else:
#		OS.set_window_fullscreen(full)
#		OS.set_window_size(res)
#		window_resize()
