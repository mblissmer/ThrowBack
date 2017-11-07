extends Area2D
var upperLimit = 0
var lowerLimit = 0
const initialDirection = Vector2(1,0)
var direction = initialDirection
const baseSpeed = 200
var speed = baseSpeed
var caught = false
var ignored = ""

func _ready():
	set_process(true)

func _process(delta):
	if ignored != "":
		if get_overlapping_areas().size() == 0:
			ignored = ""
	
	# Get ball position
	if not caught:
		var pos = get_pos()
		pos += direction*speed*delta
		
		# Change direction when touching upper or lower limits
		if ((pos.y < upperLimit and direction.y < 0) or (pos.y > lowerLimit and direction.y > 0)):
			direction.y = -direction.y
			
		if get_overlapping_areas().size() > 0:
			var results = get_overlapping_areas()
			for result in results:
				if result.name == ignored:
					continue
				if result.areaType == "player":
					caught = true
					result.caughtBall = true
					break
				if result.areaType == "goal":
					ignored = result.name
					caught = true
					result.score()
		
		set_pos(pos)
	
func setLimits(upper, lower):
	var offset = get_node("ballSprite").get_texture().get_size().x / 2
	upperLimit = upper + offset
	lowerLimit = lower - offset
	
func launch(dir, sp, player):
	if dir == Vector2(0,0):
		if player == "p2":
			direction = -initialDirection
		elif player == "p1":
			direction = initialDirection
		else:
			var mult = rand_range(-1,1)
			direction = initialDirection * sign(mult)
	else: 
		direction = dir
	speed = baseSpeed * sp
	ignored = player
	caught = false