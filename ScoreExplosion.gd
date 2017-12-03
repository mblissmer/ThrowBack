extends Node2D

var playerParticles
var ballParticles
var goalParticles

func _ready():
	playerParticles = get_node("PlayerParticles")
	ballParticles = get_node("BallParticles")
	goalParticles = get_node("GoalParticles")
	set_process(true)

func _process(delta):
	if !playerParticles.is_emitting() and !ballParticles.is_emitting() and !goalParticles.is_emitting():
		queue_free()

func setup(player, pos, color):
	var playerColor = Color(1,1,1,1)
	var dir = 0
	var goalColor = Color(1,1,1,1)
	if color == "yellow":
		goalColor = variables.colors.goalYellow
	elif color == "red":
		goalColor = variables.colors.goalRed
	if player == "p1":
		playerColor = variables.colors.playerRed
		dir = 180
	elif player == "p2":
		playerColor = variables.colors.playerBlue
		dir = 0
	set_pos(pos)
	set_rotd(dir)
	playerParticles.set_color(playerColor)
	goalParticles.set_color(goalColor)
	playerParticles.set_emitting(true)
	ballParticles.set_emitting(true)
	goalParticles.set_emitting(true)
	
