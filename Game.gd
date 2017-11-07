extends Node2D

var scoreboard
var p1
var p2
var ball
var overlay
var quarterScreenX
var halfScreenY

func _ready():
	p1 = get_node("redPlayer")
	p2 = get_node("bluePlayer")
	ball = get_node("ball")
	scoreboard = get_node("InGameUI")
	quarterScreenX = get_viewport().get_rect().size.x / 4
	print (quarterScreenX)
	halfScreenY = 600
	setupPlayersAndBall()
	setupGoals()
	setupDisplay()
	backToOnes("")
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
func score(player, value):
	backToOnes(player)
	if player == "p1":
		scoreboard.p1Scores(value)
	elif player == "p2":
		scoreboard.p2Scores(value)

func backToOnes(player):
	p1.set_pos(Vector2(quarterScreenX, halfScreenY))
	p2.set_pos(Vector2(quarterScreenX * 3, halfScreenY))
	ball.set_pos(Vector2(quarterScreenX * 2, halfScreenY))
	print (Vector2(quarterScreenX*2, halfScreenY))
	ball.launch(Vector2(0,0),1,player)

func setupPlayersAndBall():
	# set player and ball movement limits
	var vertOffset = get_node("field/topEdge").get_texture().get_size().y / 2
	var horizOffset = get_node("field/rightGoal/yellowGoal/Sprite").get_texture().get_size().x / 2
	var upperLimit = get_node("field/topEdge").get_global_pos().y + vertOffset
	var lowerLimit = get_node("field/bottomEdge").get_global_pos().y - vertOffset 
	var leftLimit = get_node("field/leftGoal/yellowGoal/Sprite").get_global_pos().x + horizOffset
	var rightLimit = get_node("field/rightGoal/yellowGoal/Sprite").get_global_pos().x- horizOffset
	var centerLimit = get_node("field/divider").get_global_pos().x
	
	p1.setLimits(upperLimit, lowerLimit, leftLimit, centerLimit)
	p2.setLimits(upperLimit, lowerLimit, centerLimit, rightLimit)
	ball.setLimits(upperLimit, lowerLimit)
	
	# set keys for both players
	p1.setKeys("p1_up", "p1_down", "p1_left","p1_right","p1_action")
	p2.setKeys("p2_up", "p2_down", "p2_left","p2_right","p2_action")
	
	# misc setup
	p1.setup("p1")
	p2.setup("p2")

func setupGoals():
	var p1RedGoal = get_node("field/leftGoal/redGoal")
	var p1YellowGoal = get_node("field/leftGoal/yellowGoal")
	var p2RedGoal = get_node("field/rightGoal/redGoal")
	var p2YellowGoal = get_node("field/rightGoal/yellowGoal")
	p1RedGoal.setup(3,"p1","red")
	p2RedGoal.setup(3,"p2","red")
	p1YellowGoal.setup(1,"p1","yellow")
	p2YellowGoal.setup(1,"p2","yellow")
	
func setupDisplay():
	var monSize = OS.get_screen_size()
	var originalSize = Vector2(1280,1024)
	if monSize.x < originalSize.x or monSize.y < originalSize.y:
		OS.set_window_size(Vector2(960,768))
		OS.set_window_position(Vector2(10,10))
