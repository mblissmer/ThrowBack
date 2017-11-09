extends Control

const scoreLimit = 5
const startTime = 15
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
		CDTimer(delta)
		
	if countingDown:
		matchTimer(delta)


func CDTimer(delta):
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

func matchTimer(delta):
	if timer >= 0 and gameOver == false:
		var formatTime = "%02d" % ceil(timer)
		countdownText.set_text(formatTime)
		timer -= delta
	else:
		if p1Score == p2Score:
			countdownText.set_text("OT")
		else:
			gameOver = true
			endGame()

func resetTimer():
	timer = startTime

func p1Scores(amount):
	p1Score += amount
	return updateScoreDisplay()


func p2Scores(amount):
	p2Score += amount
	return updateScoreDisplay()
	
func updateScoreDisplay():
	var formatScore = "%02d" % p1Score
	get_node("p1Score").set_text(formatScore)
	var formatScore = "%02d" % p2Score
	get_node("p2Score").set_text(formatScore)
	if p1Score >= scoreLimit:
		endGame()
		return "p1"
	elif p2Score >= scoreLimit:
		endGame()
		return "p2"
	return ""
	
func endGame():
	countingDown = false
	if p1Score > p2Score:
		print("P1 Wins!")
	else:
		print("P2 Wins!")

func newMatch():
	newMatchStart = true