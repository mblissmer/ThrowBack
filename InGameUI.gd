extends Control

const startTime = 100
var timer
var countingDown = true
var countdownText
var p1Score = 0
var p2Score = 0
var gameOver = false

func _ready():
	timer = startTime
	countdownText = get_node("countDown")
	updateScoreDisplay()
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
	updateScoreDisplay()


func p2Scores(amount):
	p2Score += amount
	updateScoreDisplay()
	
func updateScoreDisplay():
	var formatScore = "%02d" % p1Score
	get_node("p1Score").set_text(formatScore)
	var formatScore = "%02d" % p2Score
	get_node("p2Score").set_text(formatScore)
