extends Node2D

var scoreboard
var p1
var p2
var ball
var quarterScreenX
var halfScreenY
var goalExplosion
var timer
var scoringPlayer = ""

func _ready():
	timer = get_node("BetweenMatches")
	p1 = preload("res://player.tscn").instance()
	p2 = preload("res://player.tscn").instance()
	ball = preload("res://ball.tscn")
	scoreboard = preload("res://InGameUI.tscn").instance()
	goalExplosion = preload("res://ScoreExplosion.tscn")
	quarterScreenX = get_viewport_rect().size.x / 4
	halfScreenY = 640
	createGame(variables.playerCount)

func createGame(playerCount):
	add_child(p1)
	add_child(p2)
	add_child(scoreboard)
	setupPlayers(playerCount)
	setupGoals()
	scoringPlayer = ""
	backToOnes(scoringPlayer)
	
func newBall():
	var newball = ball.instance()
	var vertOffset = get_node("field/topEdge").get_texture().get_size().y / 2
	var upperLimit = get_node("field/topEdge").get_global_pos().y + vertOffset
	var lowerLimit = get_node("field/bottomEdge").get_global_pos().y - vertOffset 
	newball.setLimits(upperLimit, lowerLimit)
	newball.set_pos(Vector2(quarterScreenX * 2, halfScreenY))
	add_child(newball)
	p1.ball = newball
	p2.ball = newball
	return newball
	
func clearBall():
	p1.ball = null
	p2.ball = null
	

func setupPlayers(playerCount):
	# set player and ball movement limits
	var vertOffset = get_node("field/topEdge").get_texture().get_size().y / 2
	var horizOffset = get_node("field/rightGoal/Sprite").get_texture().get_size().x / 2
	var leftLimit = get_node("field/leftGoal/Sprite").get_global_pos().x + horizOffset
	var rightLimit = get_node("field/rightGoal/Sprite").get_global_pos().x- horizOffset
	var centerLimit = get_node("field/divider").get_global_pos().x
	var upperLimit = get_node("field/topEdge").get_global_pos().y + vertOffset
	var lowerLimit = get_node("field/bottomEdge").get_global_pos().y - vertOffset 
	p1.setLimits(upperLimit, lowerLimit, leftLimit, centerLimit)
	p2.setLimits(upperLimit, lowerLimit, centerLimit, rightLimit)
	
	# set keys for both players
	p1.setKeys("p1_up", "p1_down", "p1_left","p1_right","p1_action","p1_dash")
	p2.setKeys("p2_up", "p2_down", "p2_left","p2_right","p2_action","p2_dash")
	
	# misc setup
	p1.setup("p1", Color8(255,0,129), false)
	if playerCount == 1:
		p2.setup("p2", Color8(66,198,255), true)
	else:
		p2.setup("p2", Color8(66,198,255), false)

func setupGoals():
	var p1RedGoal = get_node("field/rightGoal/redGoal")
	var p1YellowGoal = get_node("field/rightGoal/yellowGoal")
	var p2RedGoal = get_node("field/leftGoal/redGoal")
	var p2YellowGoal = get_node("field/leftGoal/yellowGoal")
	p2RedGoal.setup(3,"p2","red")
	p1RedGoal.setup(3,"p1","red")
	p2YellowGoal.setup(1,"p2","yellow")
	p1YellowGoal.setup(1,"p1","yellow")
	

	
func score(player, value, goalColor, pos):
	clearBall()
	scoringPlayer = player
	var winner = ""
	if scoringPlayer == "p1":
		winner = scoreboard.p1Scores(value)
	elif scoringPlayer == "p2":
		winner = scoreboard.p2Scores(value)
	var newExplosion = goalExplosion.instance()
	add_child(newExplosion)
	newExplosion.setup(scoringPlayer, pos, goalColor)
	if winner == "":
		timer.start()
	else: 
		p1.queue_free()
		p2.queue_free()
	
	

func backToOnes(player):
	p1.set_pos(Vector2(quarterScreenX, halfScreenY))
	p2.set_pos(Vector2(quarterScreenX * 3, halfScreenY))
	newBall().launch(Vector2(0,0),1,player,false)
	scoreboard.newRound()
	get_tree().set_pause(true)


func _on_Timer_timeout():
	backToOnes(scoringPlayer)
