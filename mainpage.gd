extends Control

const upperLimit = 300
const lowerLimit = 900
const aimYClamp = 0.6
const playerSpeed = 15
var playerSizeOffset
var playerWithBall
var redPlayer
var bluePlayer
var ball

func _ready():
	redPlayer = {
		object = get_node("redPlayer"),
		input = Vector2(0,0),
		canMove = false,
		canShoot = false,
		hasBall = false,
		dirMult = 1
	}
	bluePlayer = {
		object = get_node("bluePlayer"),
		input = Vector2(0,0),
		canMove = false,
		canShoot = false,
		hasBall = false,
		dirMult = -1
	}
	ball = {
		object = get_node("ball"),
		isCaught = false,
		speed = 800,
		turnSpeed = 10,
		direction = Vector2(0,0),
		initialDirection = Vector2(-1,0),
		relativeCaughtPos = 0,
		turnDirection = 0,
		aimTangent = 0,
		oldAimTangent = 0,
		rotationAngle = 0
	}
#	playerSizeOffset = get_node("redPlayer/Sprite").get_texture().get_size().x / 1.75
	print(get_node("redPlayer/Sprite").get_texture().get_size().x / 1.75)
	playerSizeOffset = 20
	ballLaunch(ball.direction)
	set_process(true)

func _process(delta):
	if not ball.isCaught:
		var ballPos = ball.object.get_pos()
		ballPos += ball.direction * ball.speed * delta
		if ((ballPos.y < upperLimit and ball.direction.y < 0) or (ballPos.y > lowerLimit and ball.direction.y > 0)):
			ball.direction.y = -ball.direction.y
		ball.object.set_pos(ballPos)
		if sign(ball.direction.x) == 1 and !bluePlayer.canMove:
			redPlayer.canMove = false
			bluePlayer.canMove = true
		elif sign(ball.direction.x) == -1 and !redPlayer.canMove:
			redPlayer.canMove = true
			bluePlayer.canMove = false
	
	var p1pos = redPlayer.object.get_pos()
	var p2pos = bluePlayer.object.get_pos()
	if redPlayer.canMove:
		p1pos = computerMovement(p1pos,delta)
		redPlayer.input = Vector2(rand_range(-1,1),rand_range(-1,1))
		redPlayer.object.set_pos(p1pos)
	if bluePlayer.canMove:
		p2pos = computerMovement(p2pos,delta)
		bluePlayer.input = Vector2(rand_range(-1,1),rand_range(-1,1))
		bluePlayer.object.set_pos(p2pos)
	if playerWithBall != null:
		shooting(delta)

func computerMovement(pos,delta):
	var targetY = ball.object.get_pos().y
	var targetPos = Vector2(pos.x,targetY)
	var motion = targetPos - pos
	pos += motion * delta * playerSpeed
	return pos
#	
#func ballReturn(ballPos,delta):
#	pass

func ballLaunch(dir):
	if dir == Vector2(0,0):
#		if player == "p2":
#			ballDirection = -ballInitialDirection
#		elif player == "p1":
#			ballDirection = ballInitialDirection
#		else:
			var mult = rand_range(-1,1)
			ball.direction = ball.initialDirection * sign(mult)
	else:
		ball.direction = dir
	ball.isCaught = false

func _on_redPlayer_area_enter( area ):
	redPlayer.canMove = false
	ball.relativeCaughtPos = ball.object.get_pos() - redPlayer.object.get_pos()
	playerWithBall = redPlayer
	catchBall()
	
func _on_bluePlayer_area_enter( area ):
	bluePlayer.canMove = false
	ball.relativeCaughtPos = ball.object.get_pos() - bluePlayer.object.get_pos()

	playerWithBall = bluePlayer
	catchBall()

func catchBall():
	ball.isCaught = true
	ball.turnDirection = sign(ball.relativeCaughtPos.y * 0.001) * playerWithBall.dirMult
	ball.aimTangent = ball.relativeCaughtPos.tangent().normalized() * -ball.turnDirection
	ball.oldAimTangent = sign(ball.aimTangent.x)
	ball.rotationAngle = atan2(ball.relativeCaughtPos.y, ball.relativeCaughtPos.x)
	playerWithBall.hasBall = true

func shooting(delta):
	var ballPos = ball.object.get_pos()
	ball.aimTangent = (ballPos-playerWithBall.object.get_pos()).tangent().normalized() * -ball.turnDirection
	ball.rotationAngle += delta * ball.turnDirection * ball.turnSpeed
	ballPos.x += (cos(ball.rotationAngle)*playerSizeOffset)
	ballPos.y += (sin(ball.rotationAngle)*playerSizeOffset)
	ball.object.set_pos(ballPos)
#	if sign(aimTangent.x) != oldAimTangent:
#		oldAimTangent = sign(aimTangent.x)
#		if -sign(ball.get_pos().x - player.get_pos().x) == playerThatHasBall:
#			poweredAim = getAndCleanAim()
#			poweredShotEnabled = true
#	if poweredShotEnabled:
#		var aimDiffX = abs(poweredAimTangent.x-poweredAim.x)
#		var aimDiffY = abs(poweredAimTangent.y-poweredAim.y)
#		if  aimDiffX < 0.1 and aimDiffY < 0.1:
#			ball.launch(poweredAim, 0, name, powered)
#			canMoveTimer.start()
#			poweredAim = Vector2(0,0)
#			poweredShotEnabled = false
#			mustReturnTimer.stop()
#			hasBall = false
#
#func getAndCleanAim():
#	var aim = movementDirection
#	if aim == Vector2(0,0):
#		aim = Vector2(playerDirMultiplier,0)
#	if abs(aim.y) > yAimClamp:
#		if sign(aim.x) == 0: aim.x +=0.001
#		aim.x += (abs(aim.y) - yAimClamp) * sign(aim.x)
#	aim.y = clamp(aim.y, -yAimClamp, yAimClamp)
#	aim.x = abs(aim.x) * playerDirMultiplier
#	aim *= 50
#	aim = aim.normalized()
#	return aim