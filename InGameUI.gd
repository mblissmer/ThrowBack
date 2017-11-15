extends CanvasLayer

const scoreLimit = 1
const startTime = 60
var timer = startTime
var countingDown = false
var countdownText
var newGameCount
var newGameTimer = 3
var p1Score = 0
var p2Score = 0
var gameOver = false
var newRoundStart = false
var p1ScoreText
var p2ScoreText
var timeLabel

func _ready():
	p1ScoreText = get_node("p1Score")
	p2ScoreText = get_node("p2Score")
	timeLabel = get_node("timeLabel")
	countdownText = get_node("timer")
	newGameCount = get_node("newGameCount")
	updateScoreDisplay()
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if newRoundStart:
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
			newRoundStart = false
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
	p1ScoreText.set_text(formatScore)
	var formatScore = "%02d" % p2Score
	p2ScoreText.set_text(formatScore)
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
		p1ScoreText.set_text("WINNER")
		p2ScoreText.hide()
	else:
		p2ScoreText.set_text("WINNER")
		p1ScoreText.hide()
	timeLabel.hide()
	countdownText.hide()

func newRound():
	newRoundStart = true
	
func zeroScores():
	p1Score = 0
	p2Score = 0
	timer = startTime
	updateScoreDisplay()
	