extends Panel

const startTime = 100
var timer
var countingDown = true
var countdownText
var p1Score
var p2Score
var gameOver = false

func _ready():
	timer = startTime
	countdownText = get_node("countDown")
	set_process(true)

func _process(delta):
	if countingDown:
		if timer >= 0:
			var formatTime = "%02d" % timer
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
	var formatScore = "%02d" % p1Score
	get_node("p1Score").set_text(formatScore)

func p2Scores(amount):
	p2Score += amount
	var formatScore = "%02d" % p2Score
	get_node("p1Score").set_text(formatScore)
