extends Control

const startTime = 99
var timer = startTime
var countingDown = false
var countdownText
var newGameCount
var newGameTimer = 3
var p1Score = 0
var p2Score = 0
var gameOver = false
var newMatchStart = false

func _ready():
	countdownText = get_node("timer")
	newGameCount = get_node("newGameCount")
	updateScoreDisplay()
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if newMatchStart:
		newGameTimer -= delta
		if newGameTimer >= 0:
			newGameCount.set_self_opacity(1)
			newGameCount.set_text(str(ceil(newGameTimer)))
		else:
			newGameCount.set_text("GO!")
			newGameCount.set_self_opacity(1+newGameTimer)
			if newGameCount.get_self_opacity() <= 0:
				newMatchStart = false
				countingDown = true
				newGameTimer = 3
				get_tree().set_pause(false)
		
	if countingDown:
		if timer >= 0:
			var formatTime = "%02d" % ceil(timer)
			countdownText.set_text(formatTime)
			timer -= delta
		elif !gameOver:
			gameOver = true
			print ("OMG GAME OVER")
			#send endgame trigger

func resetTimer():
	timer = startTime

func p1Scores(amount):
	p1Score += amount
	updateScoreDisplay()


func p2Scores(amount):
	p2Score += amount
	updateScoreDisplay()
	
func updateScoreDisplay():
	var formatScore = "%02d" % p1Score
	get_node("p1Score").set_text(formatScore)
	var formatScore = "%02d" % p2Score
	get_node("p2Score").set_text(formatScore)

func newMatch():
	newMatchStart = true