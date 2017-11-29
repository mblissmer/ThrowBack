extends Area2D

var name = ""
var areaType = "player"
var ball
var playerDirMultiplier = 1
var canMove = true
var hasBall = false
var chargingShot = false
var ballRotationAngle
var ballRelativeCaughtPos = Vector2(0,0)
var movementInputs = {}
var actionInputs = {}
var aimInputs = {}
var limits = {}
var movementDirection = Vector2(0,0)
var speed = 300
var computerControlled = false
var mustReturnTimer
var controllerNum
var yAimClamp = 0.6
var aimDiffs = []
var cpu
var powered
var timers
var dash
var collect
var particles
var shield


func _ready():
	powered = {
		isPowered = false,
		turnDirection = 0,
		aimTangent = Vector2(0,0),
		turnSpeed = 15,
		oldTangent = 0,
		aim = Vector2(0,0),
		shotEnabled = false,
		meter = get_node("PowerMeter")
	}
	timers = {
		canMove = get_node("Timers/CanMoveTimer"),
		dash = get_node("Timers/dashTimer"),
		rebound = get_node("Timers/ReboundTimer"),
		mustReturn = get_node("Timers/MustReturnTimer")
	}
	dash = {
		isDashing = false,
		distance = 400,
		speed = 10,
		target = Vector2(0,0),
	}
	collect = {
		isCollecting = false,
		timer = 0,
		speed = 0.2,
	}
	particles = {
		glow = get_node("Glow")
	}
	shield = {
		object = get_node("Shield"),
		canUse = true,
		locked = false
	}
	shield.object.hide()
	
	set_process(true)

func setKeys(u, d, l, r, a, j):
	movementInputs = {
		up = u,
		down = d,
		left = l,
		right = r
	}
	actionInputs = {
		shoot = a, 
		dash = j, 
		shootReleased = true, 
		dashReleased = true
	}
	
func setLimits(u, d, l, r):
	limits["playerOffset"] = get_node("Sprite").get_texture().get_size().x * get_scale().x / 1.75
	limits["upperLimit"] = u + limits["playerOffset"]
	limits["lowerLimit"] = d - limits["playerOffset"]
	limits["leftLimit"] = l + limits["playerOffset"]
	limits["rightLimit"] = r - limits["playerOffset"]
	
func setup(n, col, comp):
	name = n
	get_node("Sprite").set_modulate(col)
	particles.glow.set_color_phase_color(0, col)
	col.a = 0
	particles.glow.set_color_phase_color(1,col)
	col.a = 1
	get_node("Trail").set_color(col)
	if comp:
		computerControlled = true
		cpu = {
			holdBallTimer = get_node("Timers/ComputerHoldBallTimer"),
			movementSpeed = variables.aiSpeeds[variables.difficulty],
			returnDelayMax = variables.aiReturnSpeeds[variables.difficulty]
		}
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
		if dash.isDashing:
			pos = dash(pos, delta)
		elif canMove:
			pos = movement(pos, delta)
		shield()
	if hasBall:
		setBallPosition(pos, delta)
	set_pos(pos)

	
func resetButtons():
	if not Input.is_action_pressed(actionInputs["shoot"]) and not actionInputs.shootReleased:
		actionInputs.shootReleased = true
		if not powered.isPowered:
			shield.canUse = true
	if not Input.is_action_pressed(actionInputs["dash"]) and not actionInputs.dashReleased:
		actionInputs.dashReleased = true
		
func computerMovement(pos,delta):
	if not hasBall and ball != null:
		var targetY = clamp(ball.get_pos().y,limits["upperLimit"],limits["lowerLimit"])
		var targetPos = Vector2(pos.x, targetY)
		var motion = targetPos - pos
		pos += motion * delta * cpu.movementSpeed
	movementDirection = Vector2(rand_range(-1,1),rand_range(-1,1))
	return pos
	
func getDirection():
	movementDirection = Vector2(0,0)
	var joy = Vector2(Input.get_joy_axis(controllerNum,0), Input.get_joy_axis(controllerNum,1))
	if abs(joy.x) > variables.joyDZ or abs(joy.y) > variables.joyDZ:
		movementDirection = joy
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
	var motion = dash.target - pos
	pos += motion * delta * dash.speed
	if abs(pos.distance_to(dash.target)) < 1 and timers.dash.get_time_left() == 0:
		timers.dash.start()
	return pos

func movement(pos, delta):
	pos += (movementDirection * speed * delta)
	pos.x = clamp(pos.x, limits["leftLimit"], limits["rightLimit"])
	pos.y = clamp(pos.y, limits["upperLimit"], limits["lowerLimit"])
	if Input.is_action_pressed(actionInputs["dash"]):
		dash.isDashing = true
		if movementDirection == Vector2(0,0):
			movementDirection.x += 1
		dash.target = pos + (movementDirection * dash.distance)
		dash.target.x = clamp(dash.target.x, limits["leftLimit"], limits["rightLimit"])
		dash.target.y = clamp(dash.target.y, limits["upperLimit"], limits["lowerLimit"])
	return pos

func shield():
	if not shield.locked:
		if Input.is_action_pressed(actionInputs["shoot"]) and shield.canUse:
			shield.object.show()
		elif shield.object.is_visible():
			shield.object.hide()

func setBallPosition(pos, delta):
	var ballPos = pos
	if powered.isPowered:
		poweredShot(ballPos, delta)
		return
	if collect.isCollecting:
		ballPos = collectBall(ballPos, delta)
	if Input.is_action_pressed(actionInputs["shoot"]) and actionInputs.shootReleased:
			actionInputs.shootReleased = false
			shoot()
			return
	ball.set_pos(ballPos)
	
func catchingBall(newball): #alert from ball that we have caught it
	timers.rebound.start()
	timers.mustReturn.start()
	ball = newball
	ball.chargeChange(powered.isPowered)
	hasBall = true
	canMove = false
	collect.isCollecting = true
	ballRelativeCaughtPos = ball.get_pos() - get_pos()
	powered.turnDirection = sign(ballRelativeCaughtPos.y + 0.001) * playerDirMultiplier
	powered.aimTangent = ballRelativeCaughtPos.tangent().normalized() * -powered.turnDirection
	powered.oldTangent = sign(powered.aimTangent.x)
	ballRotationAngle = atan2(ballRelativeCaughtPos.y, ballRelativeCaughtPos.x)
	if computerControlled and !powered.isPowered:
		cpu.holdBallTimer.set_wait_time(rand_range(0,cpu.returnDelayMax))
		cpu.holdBallTimer.start()

func getAndCleanAim():
	var aim = movementDirection
	if aim == Vector2(0,0):
		aim = Vector2(playerDirMultiplier,0)
	aim *= 50
	aim = aim.normalized()
	if abs(aim.y) > yAimClamp:
		if sign(aim.x) == 0: aim.x +=0.001
		aim.x += (abs(aim.y) - yAimClamp) * sign(aim.x)
	aim.y = clamp(aim.y, -yAimClamp, yAimClamp)
	aim.x = abs(aim.x) * playerDirMultiplier
	return aim

func shoot():
	shield.canUse = false
	timers.mustReturn.stop()
	hasBall = false
	var aim = getAndCleanAim()
	var tl = timers.rebound.get_time_left()
	var ballspeed = 1 + (tl/10)
	timers.canMove.start()
	if tl == 0:
		ballspeed = 0
	ball.launch(aim, ballspeed, name, powered.isPowered)
	var pmscale = powered.meter.get_scale().x
	if pmscale < 1:
		pmscale += tl /5
		powered.meter.set_scale(Vector2(pmscale,pmscale))
		if pmscale >= 1:
			poweredUp(true)
	

func poweredUp(power):
	particles.glow.set_emitting(power)
	powered.isPowered = power
	shield.locked = power
	if power:
		shield.object.show()
	else:
		shield.object.hide()
	
func collectBall(ballPos, delta):
	collect.timer += delta
	var perc = collect.timer / collect.speed
	var newStartPos = ballRelativeCaughtPos + ballPos 
	ballPos = newStartPos + ((ballPos - newStartPos) * perc)
	if collect.timer >= collect.speed:
		cancelCollect()
	return ballPos
	
func cancelCollect():
	collect.isCollecting = false
	collect.timer = 0

func poweredShot(ballPos, delta):
	powered.aimTangent = (ball.get_pos()-get_pos()).tangent().normalized() * -powered.turnDirection
	ballRotationAngle += delta * powered.turnDirection * powered.turnSpeed
	ballPos.x += (cos(ballRotationAngle)*limits["playerOffset"])
	ballPos.y += (sin(ballRotationAngle)*limits["playerOffset"])
	ball.set_pos(ballPos)
	if sign(powered.aimTangent.x) != powered.oldTangent:
		powered.oldTangent = sign(powered.aimTangent.x)
		if -sign(ball.get_pos().x - get_pos().x) == playerDirMultiplier:
			powered.aim = getAndCleanAim()
			powered.shotEnabled = true
	if powered.shotEnabled:
		aimDiffs.push_front(powered.aimTangent.distance_to(powered.aim))
		if aimDiffs.size() > 3:
			aimDiffs.resize(3)
		if aimDiffs.size() == 3:
			if aimDiffs[0] > aimDiffs[1] < aimDiffs[2]:
				ball.launch(powered.aim, 0, name, powered.isPowered)
				timers.canMove.start()
				powered.aim = Vector2(0,0)
				powered.shotEnabled = false
				timers.mustReturn.stop()
				hasBall = false
				aimDiffs.clear()

func newRoundReset():
	poweredUp(false)
	powered.meter.set_scale(Vector2(0,0))
	shield.canUse = true
	resetDash()

func resetDash():
	dash.isDashing = false
	dash.target = Vector2(0,0)

func _on_dashTimer_timeout():
	resetDash()

func _on_CanMoveTimer_timeout():
	canMove = true

func _on_MustReturnTimer_timeout():
	shoot()

func _on_ComputerHoldBallTimer_timeout():
	shoot()
	