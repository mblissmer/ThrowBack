extends Area2D

var name = ""
var areaType = "player"
var ball
var caught = false
var chargeShot = false
var charge = 1
var ballRotationAngle = PI
const ballRotMinSpeed = 1
const ballRotMaxSpeed = 10
var ballRotCurSpeed = 1
var ballRotSpeedUpMult = 2
var shotAngle
var collectTimer = 0
var ballRelativeCaughtPos
var up
var down
var left
var right
var action
var upperLimit
var lowerLimit
var leftLimit
var rightLimit
var playerOffset
var speed = 400
var particles

func _ready():
	particles = get_node("Particles2D")
	ball = get_node("../ball")
	playerOffset = get_node("Sprite").get_texture().get_size().x / 1.5
	set_process(true)

func _process(delta):
	# Move player
	var pos = get_pos()
	
	if (pos.y > upperLimit and Input.is_action_pressed(up)):
		pos.y += -speed*delta
	if (pos.y < lowerLimit and Input.is_action_pressed(down)):
		pos.y += speed*delta
	if (pos.x > leftLimit and Input.is_action_pressed(left)):
		pos.x += -speed*delta
	if (pos.x < rightLimit and Input.is_action_pressed(right)):
		pos.x += speed*delta
	set_pos(pos)
	
	if caught:
		var ballPos = pos
		if not chargeShot and collectTimer < 0.5:
			collectTimer += delta
			var perc = collectTimer / 0.5
			var newStartPos = ballRelativeCaughtPos + pos 
			ballPos = newStartPos + ((pos - newStartPos) * perc)
		if Input.is_action_pressed(action):
			chargeShot = true
			charge += delta
		elif chargeShot and not Input.is_action_pressed(action):
			launchBall()
			charge = 1
			chargeShot = false
			ballRotCurSpeed = ballRotMinSpeed
			return
		if chargeShot:
			if ballRotCurSpeed < ballRotMaxSpeed:
				ballRotCurSpeed += delta * ballRotSpeedUpMult
			ballRotationAngle += ballRotCurSpeed * delta
			if ballRotationAngle > PI*2:
				ballRotationAngle -= PI*2
			ballPos.x += (cos(ballRotationAngle)*playerOffset)
			ballPos.y += (sin(ballRotationAngle)*playerOffset)
			shotAngle = (ball.get_pos() - get_pos()).normalized()
			if name == "p1":
				shotAngle.x = abs(shotAngle.x)
			elif name == "p2":
				shotAngle.x = -abs(shotAngle.x)
		ball.set_pos(ballPos)
		

	update()
		
func setKeys(u, d, l, r, a):
	up = u
	down = d
	left = l
	right = r
	action = a
	
func setLimits(u, d, l, r):
	upperLimit = u + playerOffset
	lowerLimit = d - playerOffset
	leftLimit = l + playerOffset
	rightLimit = r - playerOffset
	
func setup(n, path):
	name = n
	var sprite = load(path)
	get_node("Sprite").set_texture(sprite)
	get_node("Particles2D").set_texture(sprite)
	
func caughtBall():
	caught = true
	ballRelativeCaughtPos = ball.get_pos() - get_pos()

func launchBall():
	var dirx = 1.0
	if name == "p2":
		dirx = -1.0
	var dir = shotAngle
	caught = false
	ball.launch(dir, charge, name)
	
func _draw():
	if caught and chargeShot:
		var startPos = ball.get_pos() - get_pos()
		draw_line(startPos,shotAngle * 200,Color(255,255,255), 5)