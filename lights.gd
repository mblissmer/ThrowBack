extends Light2D


var timer = 0
var speed = 0.5
var scaleMult = 4
var otherScale

func _ready():
	otherScale = get_scale().y
	set_process(true)

func _process(delta):
	timer += delta * speed
	if timer > PI*2:
		timer -= PI*2
	var newSize = (abs(sin(timer))/scaleMult) + 1
	set_scale(Vector2(newSize,otherScale))

