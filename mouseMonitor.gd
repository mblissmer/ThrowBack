extends Node2D

var monitorMouse = false
var oldMousePos = Vector2(0,0)

func _ready():
	set_process(true)
	
func _process(delta):
	if monitorMouse:
		var mousePos = get_global_mouse_pos()
		if oldMousePos.distance_to(mousePos) > 5:
			toggleMouse(true)
		oldMousePos = mousePos

func activate(truefalse):
	monitorMouse = truefalse
	oldMousePos = get_global_mouse_pos()
	get_parent().usingMouse = truefalse
	toggleMouse(truefalse)
	
func toggleMouse(active):
	if active:
		Input.set_mouse_mode(0) #show
	else: 
		Input.set_mouse_mode(1) #hide