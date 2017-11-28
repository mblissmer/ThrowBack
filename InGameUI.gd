extends CanvasLayer

const scoreLimit = 7
var countdownText
var newGameCount
var p1Score = 0
var p2Score = 0
var gameOver = false
var p1ScoreText
var p2ScoreText
var postGame
var midMatch
var pause
var canPause = false
var midMatchTimer
var preMatchTimer
var goalAnnounces
var goalColor
var goalAColTimer
var goalATimer

func _ready():
	p1ScoreText = get_node("MidMatch/p1Score")
	p2ScoreText = get_node("MidMatch/p2Score")
	countdownText = get_node("MidMatch/timeDisplay")
	newGameCount = get_node("PreMatch/newGameCount")
	midMatch = get_node("MidMatch")
	postGame = get_node("PostGame")
	pause = get_node("Pause")
	midMatchTimer = get_node("MidMatch/Timer")
	preMatchTimer = get_node("PreMatch/Timer")
	goalAnnounces = [get_node("MidMatch/goalAnnounceL"),get_node("MidMatch/goalAnnounceR")]
	goalAColTimer = get_node("MidMatch/goalAColTimer")
	goalATimer = get_node("MidMatch/goalATimer")
	updateScoreDisplay()
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and !pause.is_visible() and canPause:
		pauseGame()
	if preMatchTimer.get_time_left() != 0:
		preMatch()
	elif midMatchTimer.get_time_left() !=0 or !gameOver:
		activeMatch()

func pauseGame():
	pause.show()
	pause.focus()
	get_tree().set_pause(true)

func preMatch():
	if preMatchTimer.get_time_left()-1 > 0:
		newGameCount.set_text(str(ceil(preMatchTimer.get_time_left()-1)))
	else:
		newGameCount.set_text("GO!")
		newGameCount.set_self_opacity(preMatchTimer.get_time_left())


func activeMatch():
	if midMatchTimer.get_time_left() > 0:
		var formatTime = "%02d" % ceil(midMatchTimer.get_time_left())
		countdownText.set_text(formatTime)
	else:
		if p1Score == p2Score:
			countdownText.set_text("OT")
		else:
			gameOver = true
			endGame()

func p1Scores(amount):
	p1Score += amount
	startGoalAnnounce(variables.ColPlayerRed)
	return updateScoreDisplay()


func p2Scores(amount):
	p2Score += amount
	startGoalAnnounce(variables.ColPlayerBlue)
	return updateScoreDisplay()
	
func updateScoreDisplay():
	canPause = false
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
	if p1Score > p2Score:
		postGame.setup(str(p1Score), str(p2Score), "WIN", "LOSE")
	else:
		postGame.setup(str(p1Score), str(p2Score), "LOSE", "WIN")
	postGame.show()
	midMatch.hide()
	get_node("PostGame/Buttons/Rematch").grab_focus()

func newRound():
	get_node("GoalLabels/AnimationPlayer").play("goal_labels")
	preMatchTimer.start()
	newGameCount.set_text("")
	newGameCount.set_self_opacity(1)

func _on_PreMatchTimer_timeout():
	newGameCount.set_self_opacity(preMatchTimer.get_time_left())
	midMatchTimer.start()
	get_tree().set_pause(false)
	canPause = true

func startGoalAnnounce(col):
	goalColor = col
	goalAColTimer.start()
	goalATimer.start()
	for g in goalAnnounces:
		g.show()

func _on_goalAColTimer_timeout():
	for g in goalAnnounces:
		if g.get("custom_colors/font_color") == Color(1,1,1,1):
			g.set("custom_colors/font_color", goalColor)
		else:
			g.set("custom_colors/font_color", Color(1,1,1,1))

func _on_goalATimer_timeout():
	goalAColTimer.stop()
	for g in goalAnnounces:
		g.set("custom_colors/font_color", Color(1,1,1,1))
		g.hide()
