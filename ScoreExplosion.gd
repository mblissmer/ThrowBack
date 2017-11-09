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
	var spritePath = ""
	var dir = 0
	var goalColor = Color(1,1,1,1)
	if color == "yellow":
		goalColor = Color(0,1,1,1)
	elif color == "red":
		goalColor = Color(1,0,0,1)
	if player == "p1":
		spritePath = "res://sprites/redPlayer.png"
		dir = 180
	elif player == "p2":
		spritePath = "res://sprites/bluePlayer.png"
		dir = 0
	set_pos(pos)
	set_rotd(dir)
	var sprite = load(spritePath)
	playerParticles.set_texture(sprite)
	goalParticles.set_color(goalColor)
	playerParticles.set_emitting(true)
	ballParticles.set_emitting(true)
	goalParticles.set_emitting(true)
	
