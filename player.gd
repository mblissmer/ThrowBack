extends Area2D

var name = ""
var areaType = "player"
var ball
var canMove = true
var canMoveTimer
var hasBall = false
var releasedActionButton = true
var releasedDashButton = true
var chargingShot = false
#var charge = 1
#const minCharge = 4
#const maxCharge = 8
#var chargeUpSpeed = 4
#var ballRotationAngle = PI
#var shotAngle
var collecting = false
var collectTimer = 0
var collectSpeed = 0.2
var ballRelativeCaughtPos
var movementInputs = {}
var actionInputs = {}
var aimInputs = {}
var limits = {}
var movementDirection = Vector2(0,0)
var dashing = false
var dashDistance = 400
var dashSpeed = 10
var dashTarget = Vector2(0,0)
var dashTimer
var reboundTimer
var speed = 300
var computerControlled = false
var computerHoldBallTimer = 0
var computerHoldBallLimit = 1
var computerHoldBallAngleVariance = 0.5
var glow
var powerMeter
var powered = false
var mustReturnTimer
var controllerNum
var yAimClamp = 0.6


func _ready():
	canMoveTimer = get_node("Timers/CanMoveTimer")
	dashTimer = get_node("Timers/dashTimer")
	reboundTimer = get_node("Timers/ReboundTimer")
	mustReturnTimer = get_node("Timers/MustReturnTimer")
	glow = get_node("Glow")
	powerMeter = get_node("PowerMeter")
	limits["playerOffset"] = get_node("Sprite").get_texture().get_size().x * get_scale().x / 1.75
	set_process(true)

func setKeys(u, d, l, r, a, j):
	movementInputs = {"up":u,"down":d,"left":l,"right":r}
	actionInputs = {"shoot":a, "dash":j}
	
func setLimits(u, d, l, r):
	limits["upperLimit"] = u + limits["playerOffset"]
	limits["lowerLimit"] = d - limits["playerOffset"]
	limits["leftLimit"] = l + limits["playerOffset"]
	limits["rightLimit"] = r - limits["playerOffset"]
	
func setup(n, col, cpu):
	name = n
	var newcol = Color(col)
	get_node("Sprite").set_modulate(newcol)
	var glow = get_node("Glow")
	glow.set_color_phase_color(0, newcol)
	newcol.a = 0
	glow.set_color_phase_color(1,newcol)
	newcol.a = 0.2
	get_node("Trail").set_color(newcol)
	computerControlled = cpu
	if n == "p1":
		controllerNum = 0
	elif n == "p2":
		controllerNum = 1


func _process(delta):
	var pos = get_pos()
	if computerControlled:
		pass
		#whole separate thing
	else:
		resetButtons()
		getDirection()
		if dashing:
			pos = dash(pos, delta)
		elif canMove:
			pos = movement(pos, delta)
	if hasBall:
		setBallPosition(pos, delta)
	set_pos(pos)

	
func resetButtons():
	if not Input.is_action_pressed(actionInputs["shoot"]) and not releasedActionButton:
		releasedActionButton = true
	if not Input.is_action_pressed(actionInputs["dash"]) and not releasedDashButton:
		releasedDashButton = true
		
#func computerMovement(pos,delta):
#	if not caughtBall and ball != null:
#		var targetY = ball.get_pos().y
#		var targetPos = Vector2(pos.x, targetY)
#		var motion = targetPos - pos
#		pos += motion * delta * 4
#	return pos
	
func getDirection():
	movementDirection = Vector2(0,0)
	var joy = Vector2(Input.get_joy_axis(controllerNum,0), Input.get_joy_axis(controllerNum,1))
	if abs(joy.x) > variables.joyDZ or abs(joy.y) > variables.joyDZ:
		movementDirection = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0,1))
	else:
		if (Input.is_action_pressed(movementInputs["up"])):
			movementDirection.y -= 1
		if (Input.is_action_pressed(movementInputs["down"])):
			movementDirection.y += 1
		if (Input.is_action_pressed(movementInputs["left"])):
			movementDirection.x -= 1
		if (Input.is_action_pressed(movementInputs["right"])):
			movementDirection.x += 1

func dash(pos,delta):
	var motion = dashTarget - pos
	pos += motion * delta * dashSpeed
	if abs(pos.distance_to(dashTarget)) < 1 and dashTimer.get_time_left() == 0:
		dashTimer.start()
	return pos

func movement(pos, delta):
	pos += (movementDirection * speed * delta)
	pos.x = clamp(pos.x, limits["leftLimit"], limits["rightLimit"])
	pos.y = clamp(pos.y, limits["upperLimit"], limits["lowerLimit"])
	if Input.is_action_pressed(actionInputs["dash"]):
		dashing = true
		if movementDirection == Vector2(0,0):
			movementDirection.x += 1
		dashTarget = pos + (movementDirection * dashDistance)
		dashTarget.x = clamp(dashTarget.x, limits["leftLimit"], limits["rightLimit"])
		dashTarget.y = clamp(dashTarget.y, limits["upperLimit"], limits["lowerLimit"])
	return pos

func setBallPosition(pos, delta):
	var ballPos = pos
	if collecting:
		ballPos = collectBall(ballPos, delta)
	if computerControlled:
#		if chargeShot:
#			computerHoldBallTimer += delta
#			if computerHoldBallTimer > computerHoldBallLimit and abs(shotAngle.y) < computerHoldBallAngleVariance:
#				releaseCharge()
#				computerHoldBallTimer = 0
#				return
#		else:
#			computerHoldBallLimit = rand_range(0,1.5)
#			pressCharge()
		pass
	elif Input.is_action_pressed(actionInputs["shoot"]) and releasedActionButton:
			releasedActionButton = false
#			if powered:
#				chargingShot = true
#			else:
			shoot()
			return
#			pressCharge()
#		elif chargeShot and not Input.is_action_pressed(actionInputs["shoot"]):
#			releaseCharge()
#			return
#	if chargeShot:
#		ballPos = chargingShot(ballPos, delta)
	ball.set_pos(ballPos)
	
func catchingBall(newball): #alert from ball that we have caught it
	reboundTimer.start()
	mustReturnTimer.start()
	ball = newball
	hasBall = true
	canMove = false
	collecting = true
	ballRelativeCaughtPos = ball.get_pos() - get_pos()

func shoot():
	mustReturnTimer.stop()
	hasBall = false
	var tl = reboundTimer.get_time_left()
	if abs(movementDirection.y) > yAimClamp:
		if sign(movementDirection.x) == 0: movementDirection.x +=0.001
		print(sign(movementDirection.x))
		movementDirection.x += (abs(movementDirection.y) - yAimClamp) * sign(movementDirection.x)
	movementDirection.y = clamp(movementDirection.y, -yAimClamp, yAimClamp)
	if (name == "p1" and movementDirection.x < 0) or (name == "p2" and movementDirection.x > 0):
		movementDirection.x *= -1
	movementDirection = movementDirection.normalized()
	var speed = 1 + (tl/10)
	if tl == 0:
		speed = 0
	var pmscale = powerMeter.get_scale().x
	if pmscale < 1:
		pmscale += tl/10
		powerMeter.set_scale(Vector2(pmscale,pmscale))
		if pmscale >= 1:
			poweredUp()
	ball.launch(movementDirection, speed, name, powered)
	canMoveTimer.start()

func poweredUp():
	glow.set_emitting(true)
	powered = true

#func launchBall():
#	var dir = shotAngle
#	caughtBall = false
#	ball.launch(shotAngle, charge/2, name)
	
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
	
#func pressCharge():
#	cancelCollect()
#	chargeShot = true
#
#func releaseCharge():
#	launchBall()
#	charge = minCharge
#	chargeShot = false
	
#func chargingShot(ballPos, delta):
#	if charge < maxCharge:
#		charge += delta * chargeUpSpeed
#	ballRotationAngle += charge * delta
#	if ballRotationAngle > PI*2:
#		ballRotationAngle -= PI*2
#	ballPos.x += (cos(ballRotationAngle)*limits["playerOffset"])
#	ballPos.y += (sin(ballRotationAngle)*limits["playerOffset"])
#	if name == "p1" and usingMouse:
#		shotAngle = (get_global_mouse_pos() - get_pos()).normalized()
#	elif computerControlled:
#		shotAngle = (ball.get_pos() - get_pos()).normalized()
#		shotAngle.x = -abs(shotAngle.x)
#	else: 
#		shotAngle = aimDirection
#	return ballPos

	
func _on_dashTimer_timeout():
	dashing = false
	dashTarget = Vector2(0,0)

func _on_CanMoveTimer_timeout():
	canMove = true


func _on_MustReturnTimer_timeout():
	shoot()
