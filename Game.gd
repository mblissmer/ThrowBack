extends Node2D

var scoreboard
var p1
var p2
var ball
var mainMenu
var quarterScreenX
var halfScreenY
var goalExplosion

func _ready():
	ball = preload("res://ball.tscn").instance()
	p1 = preload("res://player.tscn").instance()
	p2 = preload("res://player.tscn").instance()
	scoreboard = preload("res://InGameUI.tscn").instance()
	mainMenu = preload("res://MainMenu.tscn").instance()
	goalExplosion = preload("res://ScoreExplosion.tscn")
	add_child(mainMenu)
	
	quarterScreenX = get_viewport().get_rect().size.x / 4
	halfScreenY = 600
	setupDisplay()

func createGame():
	add_child(ball)
	add_child(p1)
	add_child(p2)
	add_child(scoreboard)
	setupPlayersAndBall()
	setupGoals()
	backToOnes("")
	
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
	p1.setup("p1", "res://sprites/redPlayer.png")
	p2.setup("p2", "res://sprites/bluePlayer.png")

func setupGoals():
	var p1RedGoal = get_node("field/rightGoal/redGoal")
	var p1YellowGoal = get_node("field/rightGoal/yellowGoal")
	var p2RedGoal = get_node("field/leftGoal/redGoal")
	var p2YellowGoal = get_node("field/leftGoal/yellowGoal")
	p2RedGoal.setup(3,"p2","red")
	p1RedGoal.setup(3,"p1","red")
	p2YellowGoal.setup(1,"p2","yellow")
	p1YellowGoal.setup(1,"p1","yellow")
	
func setupDisplay():
	var monSize = OS.get_screen_size()
	var originalSize = Vector2(1280,1024)
	if monSize.x < originalSize.x or monSize.y < originalSize.y:
		OS.set_window_size(Vector2(960,768))
		OS.set_window_position(Vector2(10,10))
	
func score(player, value, goalColor, pos):
	var winner = ""
	if player == "p1":
		winner = scoreboard.p1Scores(value)
	elif player == "p2":
		winner = scoreboard.p2Scores(value)
	if winner == "":
		backToOnes(player)
	var newExplosion = goalExplosion.instance()
	add_child(newExplosion)
	newExplosion.setup(player, pos, goalColor)
	

func backToOnes(player):
	p1.set_pos(Vector2(quarterScreenX, halfScreenY))
	p2.set_pos(Vector2(quarterScreenX * 3, halfScreenY))
	ball.set_pos(Vector2(quarterScreenX * 2, halfScreenY))
	ball.launch(Vector2(0,0),1,player)
	scoreboard.newMatch()
	get_tree().set_pause(true)


