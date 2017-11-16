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
var postGame
var midMatch
var pause
var midMatchTimer
var preMatchTimer

func _ready():
	p1ScoreText = get_node("MidMatch/p1Score")
	p2ScoreText = get_node("MidMatch/p2Score")
	timeLabel = get_node("MidMatch/timeLabel")
	countdownText = get_node("MidMatch/timeDisplay")
	newGameCount = get_node("PreMatch/newGameCount")
	midMatch = get_node("MidMatch")
	postGame = get_node("PostGame")
	pause = get_node("Pause")
	midMatchTimer = get_node("MidMatch/Timer")
	preMatchTimer = get_node("PreMatch/Timer")
	updateScoreDisplay()
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and !pause.is_visible():
		pauseGame()
		
	if preMatchTimer.is_active():
		preMatch()
	elif midMatchTimer.is_active() or !gameOver:
		print("pong")
		activeMatch()

func pauseGame():
	pause.show()
	get_tree().set_pause(true)

func preMatch():
	if preMatchTimer.get_time_left() > 1:
		newGameCount.set_text(str(floor(preMatchTimer.get_time_left())))
	else:
		newGameCount.set_text("GO!")
		newGameCount.set_self_opacity(preMatchTimer.get_time_left())


func activeMatch():
	print("ping")
	if midMatchTimer.get_time_left() > 0:
		var formatTime = "%02d" % ceil(midMatchTimer.get_time_left())
		print (midMatchTimer.get_time_left())
		countdownText.set_text(formatTime)
	else:
		if p1Score == p2Score:
			countdownText.set_text("OT")
		else:
			gameOver = true
			endGame()

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
		postGame.setup(str(p1Score), str(p2Score), "WIN", "LOSE")
	else:
		postGame.setup(str(p1Score), str(p2Score), "LOSE", "WIN")
	postGame.show()
	midMatch.hide()


func newRound():
	preMatchTimer.start()
	newGameCount.set_self_opacity(1)
#	newRoundStart = true
	
#func zeroScores():
#	postGame.hide()
#	p1Score = 0
#	p2Score = 0
#	updateScoreDisplay()
#	midMatch.show()
	

func _on_PreMatchTimer_timeout():
	print("start mid match timer")
	midMatchTimer.start()
	print (midMatchTimer.is_active())
#	newRoundStart = false
#	countingDown = true
	get_tree().set_pause(false)
