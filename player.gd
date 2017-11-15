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
var movementInputs = {}
var actionInputs = {}
var aimInputs = {}
var movementDirection = Vector2(0,0)
var aimDirection = Vector2(0,0)
var dashing = false
var dashDistance = 400
var dashSpeed = 10
var dashTarget = Vector2(0,0)
var dashTimer
var limits = {}
var speed = 400
var goalAnnounce
var computerControlled = false
var computerHoldBallTimer = 0
var computerHoldBallLimit = 1
var computerHoldBallAngleVariance = 0.5
var mouseMonitor
var usingMouse = false
var glow


func _ready():
	mouseMonitor = get_node("mouseMonitor")
	dashTimer = get_node("dashTimer")
	goalAnnounce = get_node("GoalAnnounce")
	glow = get_node("Glow")
	limits["playerOffset"] = get_node("Sprite").get_texture().get_size().x * get_scale().x / 1.75
	set_process(true)

func setKeys(u, d, l, r, a, j, au, ad, al, ar):
	movementInputs = {"up":u,"down":d,"left":l,"right":r}
	actionInputs = {"shoot":a, "dash":j}
	aimInputs = {"up":au,"down":ad,"left":al,"right":ar}
	
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
	if name == "p1":
		mouseMonitor.activate(true)


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
	
func computerMovement(pos,delta):
	if not caughtBall and ball != null:
		var targetY = ball.get_pos().y
		var targetPos = Vector2(pos.x, targetY)
		var motion = targetPos - pos
		pos += motion * delta * 4
	return pos
	
func getDirection():
	movementDirection = Vector2(0,0)
	if (Input.is_action_pressed(movementInputs["up"])):
		movementDirection.y -= 1
	if (Input.is_action_pressed(movementInputs["down"])):
		movementDirection.y += 1
	if (Input.is_action_pressed(movementInputs["left"])):
		movementDirection.x -= 1
	if (Input.is_action_pressed(movementInputs["right"])):
		movementDirection.x += 1

		
func getAim():
	aimDirection = Vector2(0,0)
	if (Input.is_action_pressed(aimInputs["up"])):
		aimDirection.y -= 1
	if (Input.is_action_pressed(aimInputs["down"])):
		aimDirection.y += 1
	if (Input.is_action_pressed(aimInputs["left"])):
		aimDirection.x -= 1
	if (Input.is_action_pressed(aimInputs["right"])):
		aimDirection.x += 1
	if abs(aimDirection.x) + abs(aimDirection.y) > 0.2 and usingMouse == true:
		print ("switch to controller")
		mouseMonitor.activate(false)
		
func movement(pos, delta):
	if not dashing:
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
	else: 
		var motion = dashTarget - pos
		pos += motion * delta * dashSpeed
		if abs(pos.distance_to(dashTarget)) < 1 and dashTimer.get_time_left() == 0:
			dashTimer.start()
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
		if Input.is_action_pressed(actionInputs["shoot"]):
			pressCharge()
		elif chargeShot and not Input.is_action_pressed(actionInputs["shoot"]):
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
	ballPos.x += (cos(ballRotationAngle)*limits["playerOffset"])
	ballPos.y += (sin(ballRotationAngle)*limits["playerOffset"])
	if name == "p1" and usingMouse:
		shotAngle = (get_global_mouse_pos() - get_pos()).normalized()
	elif computerControlled:
		shotAngle = (ball.get_pos() - get_pos()).normalized()
		shotAngle.x = -abs(shotAngle.x)
	else: 
		shotAngle = aimDirection
	return ballPos


func goalActions():
	goalAnnounce.showMe()
	glow.set_emitting(true)

func goalActionsEnd():
	goalAnnounce.hide()
	glow.set_emitting(false)
	
func _on_dashTimer_timeout():
	dashing = false
	dashTarget = Vector2(0,0)