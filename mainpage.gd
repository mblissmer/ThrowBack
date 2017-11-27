extends Control

const upperLimit = 300
const lowerLimit = 1000
var leftLimit
var rightLimit
const yAimClamp = 0.6
const playerSpeedDiv = 1200
var redPlayer
var bluePlayer
var ball
var newXDir = 1

func _ready():
	redPlayer = {
		object = get_node("redPlayer"),
		canMove = false,
		trail = get_node("redPlayer/Trail")
	}
	bluePlayer = {
		object = get_node("bluePlayer"),
		canMove = false,
		trail = get_node("bluePlayer/Trail")
	}
	ball = {
		object = get_node("ball"),
		speed = 400,
		direction = Vector2(0,0),
		trail = get_node("ball/Particles2D")
	}
	newXDir = sign(rand_range(-1,1))
	returnBall()
	set_process(true)
	var playerOffset = get_node("redPlayer/Sprite").get_texture().get_size().x / 2
	var ballOffset = get_node("ball/ballSprite").get_texture().get_size().x / 2
	leftLimit = redPlayer.object.get_pos().x + playerOffset + ballOffset
	rightLimit = bluePlayer.object.get_pos().x - playerOffset - ballOffset

func _process(delta):
	var ballPos = ball.object.get_pos()
	ballPos += ball.direction * ball.speed * delta
	if ((ballPos.y < upperLimit and ball.direction.y < 0) or (ballPos.y > lowerLimit and ball.direction.y > 0)):
		ball.direction.y = -ball.direction.y
	ball.object.set_pos(ballPos)
	
	if ((ballPos.x < leftLimit and newXDir == -1) or (ballPos.x > rightLimit and newXDir == 1)):
		newXDir *= -1
		returnBall()
		
	if sign(ball.direction.x) == 1 and !bluePlayer.canMove:
		redPlayer.canMove = false
		bluePlayer.canMove = true
	elif sign(ball.direction.x) == -1 and !redPlayer.canMove:
		redPlayer.canMove = true
		bluePlayer.canMove = false
	
	if redPlayer.canMove:
		var p1pos = redPlayer.object.get_pos()
		p1pos = computerMovement(p1pos,delta)
		redPlayer.input = Vector2(rand_range(-1,1),rand_range(-1,1))
		redPlayer.object.set_pos(p1pos)
	if bluePlayer.canMove:
		var p2pos = bluePlayer.object.get_pos()
		p2pos = computerMovement(p2pos,delta)
		bluePlayer.input = Vector2(rand_range(-1,1),rand_range(-1,1))
		bluePlayer.object.set_pos(p2pos)

func computerMovement(pos,delta):
	var ballPos = ball.object.get_pos()
	var playerSpeed = playerSpeedDiv / abs(ballPos.x - pos.x)
	var targetPos = Vector2(pos.x,ballPos.y)
	var motion = targetPos - pos
	pos += motion * delta * playerSpeed
	return pos



#
func returnBall():
	var aim = Vector2(rand_range(-1,1),rand_range(-1,1))
	if aim == Vector2(0,0):
		aim = Vector2(newXDir,0)
	aim.x = abs(aim.x) * newXDir
	aim *= 50
	aim = aim.normalized()
	if abs(aim.y) > yAimClamp:
		if sign(aim.x) == 0: aim.x +=0.001
		aim.x += (abs(aim.y) - yAimClamp) * sign(aim.x)
	aim.y = clamp(aim.y, -yAimClamp, yAimClamp)
	ball.direction = aim
	
func hideParticles(hidethem):
	if hidethem:
		redPlayer.trail.hide()
		bluePlayer.trail.hide()
		ball.trail.hide()
	else:
		redPlayer.trail.show()
		bluePlayer.trail.show()
		ball.trail.show()

		

func _on_AnimationPlayer_finished():
	if redPlayer.trail.is_visible():
		redPlayer.trail.set_emitting(true)
		bluePlayer.trail.set_emitting(true)
		ball.trail.set_emitting(true)
	else:
		redPlayer.trail.set_emitting(false)
		bluePlayer.trail.set_emitting(false)
		ball.trail.set_emitting(false)