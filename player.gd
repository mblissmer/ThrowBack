extends Area2D

var name = ""
var areaType = "player"
var ball
var caughtBall = false
var chargeShot = false
var charge = 1
const minCharge = 4
const maxCharge = 8
var chargeUpSpeed = 4
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
var dash
var movementDirection = Vector2(0,0)
var dashCooldown = 1.5
var dashTimer = 0
var dashing = false
var dashDistance = 400
var dashSpeed = 10
var dashTarget = Vector2(0,0)
var upperLimit
var lowerLimit
var leftLimit
var rightLimit
var playerOffset
var speed = 400
var particles
var goalAnnounce
var computerControlled = false
var computerHoldBallTimer = 0
var computerHoldBallLimit = 1
var computerHoldBallAngleVariance = 0.5

func _ready():
	goalAnnounce = get_node("GoalAnnounce")
	particles = get_node("Particles2D")
	playerOffset = get_node("Sprite").get_texture().get_size().x / 1.5
	set_process(true)

func setKeys(u, d, l, r, a, j):
	up = u
	down = d
	left = l
	right = r
	action = a
	dash = j
	
func setLimits(u, d, l, r):
	upperLimit = u + playerOffset
	lowerLimit = d - playerOffset
	leftLimit = l + playerOffset
	rightLimit = r - playerOffset
	
func setup(n, path, cpu):
	name = n
	var sprite = load(path)
	get_node("Sprite").set_texture(sprite)
	get_node("Particles2D").set_texture(sprite)
	computerControlled = cpu


func _process(delta):
	var pos = get_pos()
	if computerControlled:
		pos = computerMovement(pos, delta)
	else:
		getDirection()
		pos = movement(pos, delta)
	set_pos(pos)
	if caughtBall:
		setBallPosition(pos, delta)
	update()
	
func computerMovement(pos,delta):
	if not caughtBall and ball != null:
		var targetY = ball.get_pos().y
		var targetPos = Vector2(pos.x, targetY)
		var motion = targetPos - pos
		pos += motion * delta * 4
	return pos
	
func getDirection():
	movementDirection = Vector2(0,0)
	if (Input.is_action_pressed(up)):
		movementDirection.y -= 1
	if (Input.is_action_pressed(down)):
		movementDirection.y += 1
	if (Input.is_action_pressed(left)):
		movementDirection.x -= 1
	if (Input.is_action_pressed(right)):
		movementDirection.x += 1

func movement(pos, delta):
	if not dashing:
		pos += (movementDirection * speed * delta)
		pos.x = clamp(pos.x, leftLimit, rightLimit)
		pos.y = clamp(pos.y, upperLimit, lowerLimit)
		if Input.is_action_pressed(dash):
			dashing = true
			if movementDirection == Vector2(0,0):
				movementDirection.x += 1
			dashTarget = pos + (movementDirection * dashDistance)
			dashTarget.x = clamp(dashTarget.x, leftLimit, rightLimit)
			dashTarget.y = clamp(dashTarget.y, upperLimit, lowerLimit)
	else: 
		var motion = dashTarget - pos
		pos += motion * delta * dashSpeed
		dashTimer += delta
		if dashTimer > dashCooldown:
			dashing = false
			dashTimer = 0
			dashTarget = Vector2(0,0)
	return pos

func setBallPosition(pos, delta):
	var ballPos = pos
	if collecting:
		ballPos = collectBall(ballPos, delta)
	if computerControlled:
		if not chargeShot:
			computerHoldBallLimit = rand_range(0,1.5)
			pressCharge()
		if chargeShot:
			computerHoldBallTimer += delta
			if computerHoldBallTimer > computerHoldBallLimit and abs(shotAngle.y) < computerHoldBallAngleVariance:
				releaseCharge()
				computerHoldBallTimer = 0
				return
	else: 
		if Input.is_action_pressed(action):
			pressCharge()
		elif chargeShot and not Input.is_action_pressed(action):
			releaseCharge()
			return
	if chargeShot:
		ballPos = chargingShot(ballPos, delta)
	ball.set_pos(ballPos)
	
func catchingBall(newball):
	ball = newball
	caughtBall = true
	collecting = true
	ballRelativeCaughtPos = ball.get_pos() - get_pos()

func launchBall():
#	var dirx = 1.0
#	if name == "p2":
#		dirx = -1.0
	var dir = shotAngle
	caughtBall = false
	ball.launch(dir, charge/2, name)
	
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
	if caughtBall and chargeShot and not computerControlled:
		var startPos = ball.get_pos() - get_pos()
		draw_line(startPos,shotAngle * 200,Color(255,255,255), 5)
		
func goalPopup():
	goalAnnounce.showMe()