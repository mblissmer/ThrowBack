
extends Node2D

var ballSpeed = 80
var upperLimit
var lowerLimit
var leftLimit
var rightLimit
var centerLimit
var centerOffset
var playerSize
var playerSpeed = 400


func _ready():
	
	# set player movement limits
	playerSize = get_node("redPlayer").get_texture().get_size().x
	var playerOffset = playerSize / 2
	var vertOffset = get_node("field/topEdge").get_texture().get_size().y / 2
	var horizOffset = get_node("rightGoal/yellowGoal").get_texture().get_size().x / 2
	upperLimit = get_node("field/topEdge").get_global_pos().y + vertOffset + playerOffset
	lowerLimit = get_node("field/bottomEdge").get_global_pos().y - vertOffset - playerOffset 
	leftLimit = get_node("leftGoal/yellowGoal").get_global_pos().x + playerOffset + horizOffset
	rightLimit = get_node("rightGoal/yellowGoal").get_global_pos().x - playerOffset - horizOffset
	centerLimit = get_node("field/divider").get_global_pos().x
	centerOffset = playerOffset + get_node("field/divider").get_texture().get_size().x / 2
	
	# fix screen size if monitor is too small (hello laptop...)
	var monSize = OS.get_screen_size()
	var originalSize = Vector2(1280,1024)
	if monSize.x < originalSize.x or monSize.y < originalSize.y:
		OS.set_window_size(Vector2(960,768))
		OS.set_window_position(Vector2(10,10))
		
	# enable the _process function
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
#	# Get ball position and pad rectangles
#	var ball_pos = get_node("ball").get_pos()
#	var left_rect = Rect2(get_node("left").get_pos() - pad_size*0.5, pad_size)
#	var right_rect = Rect2(get_node("right").get_pos() - pad_size*0.5, pad_size)
#	
#	# Integrate new ball postion
#	ball_pos += direction*ball_speed*delta
#	
#	# Flip when touching roof or floor
#	if ((ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0)):
#		direction.y = -direction.y
#	
#	# Flip, change direction and increase speed when touching pads
#	if ((left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0)):
#		direction.x = -direction.x
#		ball_speed *= 1.1
#		direction.y = randf()*2.0 - 1
#		direction = direction.normalized()
#	
#	# Check gameover
#	if (ball_pos.x < 0 or ball_pos.x > screen_size.x):
#		ball_pos = screen_size*0.5
#		ball_speed = INITIAL_BALL_SPEED
#		direction = Vector2(-1, 0)
#	
#	get_node("ball").set_pos(ball_pos)
#	
	# Move player one
	var left_pos = get_node("redPlayer").get_pos()
	
	if (left_pos.y > upperLimit and Input.is_action_pressed("ui_up")):
		left_pos.y += -playerSpeed*delta
	if (left_pos.y < lowerLimit and Input.is_action_pressed("ui_down")):
		left_pos.y += playerSpeed*delta
	if (left_pos.x > leftLimit and Input.is_action_pressed("ui_left")):
		left_pos.x += -playerSpeed*delta
	if (left_pos.x < centerLimit -centerOffset and Input.is_action_pressed("ui_right")):
		left_pos.x += playerSpeed*delta
	
	get_node("redPlayer").set_pos(left_pos)

