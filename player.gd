extends Area2D

var name = ""
var areaType = "player"
var ball
var caught = false
var chargeShot = false
var charge = 1
const minCharge = 1
const maxCharge = 2
var chargeUpSpeed = 2
var ballRotationAngle = PI
var shotAngle
var collecting = false
var collectTimer = 0
var collectSpeed = 0.2
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
	set_pos(movement(pos, delta))
	
	if caught:
		var ballPos = pos
		if collecting:
			ballPos = collectBall(ballPos, delta)
		if Input.is_action_pressed(action):
			pressCharge()
		elif chargeShot and not Input.is_action_pressed(action):
			releaseCharge()
			return
		if chargeShot:
			ballPos = chargingShot(ballPos, delta)
		ball.set_pos(ballPos)
	
	update()
	

func movement(pos, delta):
	if (pos.y > upperLimit and Input.is_action_pressed(up)):
		pos.y += -speed*delta
	if (pos.y < lowerLimit and Input.is_action_pressed(down)):
		pos.y += speed*delta
	if (pos.x > leftLimit and Input.is_action_pressed(left)):
		pos.x += -speed*delta
	if (pos.x < rightLimit and Input.is_action_pressed(right)):
		pos.x += speed*delta
	return pos

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
	collecting = true
	ballRelativeCaughtPos = ball.get_pos() - get_pos()

func launchBall():
	var dirx = 1.0
	if name == "p2":
		dirx = -1.0
	var dir = shotAngle
	caught = false
	ball.launch(dir, charge, name)
	
func collectBall(ballPos, delta):
	collectTimer += delta
	var perc = collectTimer / collectSpeed
	var newStartPos = ballRelativeCaughtPos + ballPos 
	ballPos = newStartPos + ((ballPos - newStartPos) * perc)
	if collectTimer >= collectSpeed:
		cancelCollect()
	return ballPos
	
func cancelCollect():
	collecting = false
	collectTimer = 0
	
func pressCharge():
	cancelCollect()
	chargeShot = true

func releaseCharge():
	launchBall()
	charge = minCharge
	chargeShot = false
	
func chargingShot(ballPos, delta):
	if charge < maxCharge:
		charge += delta * chargeUpSpeed
	ballRotationAngle += charge * delta
	if ballRotationAngle > PI*2:
		ballRotationAngle -= PI*2
	ballPos.x += (cos(ballRotationAngle)*playerOffset)
	ballPos.y += (sin(ballRotationAngle)*playerOffset)
	shotAngle = (ball.get_pos() - get_pos()).normalized()
	if name == "p1":
		shotAngle.x = abs(shotAngle.x)
	elif name == "p2":
		shotAngle.x = -abs(shotAngle.x)
	return ballPos

func _draw():
	if caught and chargeShot:
		var startPos = ball.get_pos() - get_pos()
		draw_line(startPos,shotAngle * 200,Color(255,255,255), 5)