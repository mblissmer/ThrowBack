extends Area2D

var name = ""
var areaType = "player"
var ball
var playerDirMultiplier = 1
var canMove = true
var canMoveTimer
var hasBall = false
var releasedActionButton = true
var releasedDashButton = true
var chargingShot = false
var ballRotationAngle
var collecting = false
var collectTimer = 0
var collectSpeed = 0.2
var ballRelativeCaughtPos = Vector2(0,0)
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
var computerMovmementSpeed = 10
var computerControlled = false
var computerHoldBallTimer
var glow
var powerMeter
var powered = false
var poweredTurnDirection
var poweredAimTangent
var poweredTurnSpeed = 10
var poweredOldTangent = 0
var poweredAim = Vector2(0,0)
var poweredShotEnabled = false
var mustReturnTimer
var controllerNum
var yAimClamp = 0.6


func _ready():
	computerHoldBallTimer = get_node("Timers/ComputerHoldBallTimer")
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
		playerDirMultiplier = -1


func _process(delta):
	var pos = get_pos()
	if computerControlled:
		pos = computerMovement(pos, delta)
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
#	update()

	
func resetButtons():
	if not Input.is_action_pressed(actionInputs["shoot"]) and not releasedActionButton:
		releasedActionButton = true
	if not Input.is_action_pressed(actionInputs["dash"]) and not releasedDashButton:
		releasedDashButton = true
		
func computerMovement(pos,delta):
	if not hasBall and ball != null:
		var targetY = clamp(ball.get_pos().y,limits["lowerLimit"],limits["upperLimit"])
		
#		var targetX = rand_range(limits["leftLimit"] + 100,limits["rightLimit"]-100)
		var targetPos = Vector2(pos.x, targetY)
		var motion = targetPos - pos
		pos += motion * delta * computerMovmementSpeed
	movementDirection = Vector2(rand_range(-1,1),rand_range(-1,1))
	return pos
	
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
	if powered:
		poweredShot(ballPos, delta)
		return
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
			shoot()
			return
	ball.set_pos(ballPos)
	
func catchingBall(newball): #alert from ball that we have caught it
	reboundTimer.start()
	mustReturnTimer.start()
	ball = newball
	hasBall = true
	canMove = false
	collecting = true
	ballRelativeCaughtPos = ball.get_pos() - get_pos()
	poweredTurnDirection = sign(ballRelativeCaughtPos.y + 0.001) * playerDirMultiplier
	poweredAimTangent = ballRelativeCaughtPos.tangent().normalized() * -poweredTurnDirection
	poweredOldTangent = sign(poweredAimTangent.x)
	ballRotationAngle = atan2(ballRelativeCaughtPos.y, ballRelativeCaughtPos.x)
	if computerControlled and !powered:
		computerHoldBallTimer.set_wait_time(rand_range(0,1.5))
		computerHoldBallTimer.start()

func getAndCleanAim():
	var aim = movementDirection
	if aim == Vector2(0,0):
		aim = Vector2(playerDirMultiplier,0)
	if abs(aim.y) > yAimClamp:
		if sign(aim.x) == 0: aim.x +=0.001
		aim.x += (abs(aim.y) - yAimClamp) * sign(aim.x)
	aim.y = clamp(aim.y, -yAimClamp, yAimClamp)
	aim.x = abs(aim.x) * playerDirMultiplier
	aim = aim.normalized()
	return aim

func shoot():
	mustReturnTimer.stop()
	hasBall = false
	var aim = getAndCleanAim()
	var tl = reboundTimer.get_time_left()
	var ballspeed = 1 + (tl/10)
	ball.launch(aim, ballspeed, name, powered)
	canMoveTimer.start()
	if tl == 0:
		ballspeed = 0
	var pmscale = powerMeter.get_scale().x
	if pmscale < 1:
		pmscale += tl /5
		powerMeter.set_scale(Vector2(pmscale,pmscale))
		if pmscale >= 1:
			poweredUp()
	

func poweredUp():
	glow.set_emitting(true)
	powered = true
	
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

func poweredShot(ballPos, delta):
	poweredAimTangent = (ball.get_pos()-get_pos()).tangent().normalized() * -poweredTurnDirection
	ballRotationAngle += delta * poweredTurnDirection * poweredTurnSpeed
	ballPos.x += (cos(ballRotationAngle)*limits["playerOffset"])
	ballPos.y += (sin(ballRotationAngle)*limits["playerOffset"])
	ball.set_pos(ballPos)
	if sign(poweredAimTangent.x) != poweredOldTangent:
		poweredOldTangent = sign(poweredAimTangent.x)
		if -sign(ball.get_pos().x - get_pos().x) == playerDirMultiplier:
			poweredAim = getAndCleanAim()
			poweredShotEnabled = true
	if poweredShotEnabled:
		var aimDiffX = abs(poweredAimTangent.x-poweredAim.x)
		var aimDiffY = abs(poweredAimTangent.y-poweredAim.y)
		if  aimDiffX < 0.1 and aimDiffY < 0.1:
			ball.launch(poweredAim, 0, name, powered)
			canMoveTimer.start()
			poweredAim = Vector2(0,0)
			poweredShotEnabled = false
			mustReturnTimer.stop()
			hasBall = false

func _on_dashTimer_timeout():
	dashing = false
	dashTarget = Vector2(0,0)

func _on_CanMoveTimer_timeout():
	canMove = true

func _on_MustReturnTimer_timeout():
	shoot()

func _on_ComputerHoldBallTimer_timeout():
	shoot()