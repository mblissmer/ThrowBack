extends Area2D
var upperLimit = 0
var lowerLimit = 0
const initialDirection = Vector2(1,0)
var direction = Vector2(0,0)
const baseSpeed = 400
const maxSpeed = 1000
const chargedSpeed = 1500
var powered = false
var speed = baseSpeed
var caught = false
var ignored = ""
var effects

func _ready():
	effects = {
		trail = get_node("Particles2D"),
		glow = 	get_node("Charged"),
		light = get_node("Light2D")
	}
	set_process(true)

func _process(delta):
	if ignored != "":
		if get_overlapping_areas().size() == 0:
			ignored = ""
	
	# Get ball position
	if not caught:
		var pos = get_pos()
		var sp = speed
		if powered: sp = chargedSpeed 
		pos += direction * sp * delta
		
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
					effects.trail.set_emitting(false)
					result.catchingBall(self)
#					chargeChange(result.powered.isPowered)
					break
				if result.areaType == "goal":
					ignored = result.name
					caught = true
					get_parent().score(result.player, result.value, result.name, pos)
					queue_free()
					return
		set_pos(pos)
	
func setLimits(upper, lower):
	var offset = get_node("ballSprite").get_texture().get_size().x / 2
	upperLimit = upper + offset
	lowerLimit = lower - offset
	
func launch(dir, sp, player, charged):
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
	if charged:
		chargeChange(true)
	else:
		chargeChange(false)
		speed *= sp
		if speed > maxSpeed:
			speed = maxSpeed
		elif speed == 0:
			speed = baseSpeed
	ignored = player
	effects.trail.set_emitting(true)
	caught = false
	
func chargeChange(ischarged):
	powered = ischarged
	effects.glow.set_emitting(ischarged)
	effects.light.set_enabled(ischarged)