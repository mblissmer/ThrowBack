extends Control

var resolutionDropdown
var gameModeDropdown
var gameModeOptions

func _ready():
	resolutionDropdown = get_node("System/Resolution/Button")
	gameModeDropdown = get_node("Gameplay/Mode/Button")
	gameModeOptions = {
		scoreLimit = get_node("Gameplay/ScoreLimit/HSlider"),
		scoreLimitV = get_node("Gameplay/ScoreLimit/HSlider/Value"),
		timeLimit = get_node("Gameplay/TimeLimit/HSlider"),
		timeLimitV = get_node("Gameplay/TimeLimit/HSlider/Value"),
		ballCount = get_node("Gameplay/BallCount/HSlider"),
		ballCountV = get_node("Gameplay/BallCount/HSlider/Value"),
		pauseEnabled = get_node("Gameplay/PauseEnabled/CheckBox"),
		moveWBall = get_node("Gameplay/MoveWithBall/CheckBox")
	}
	setResolutionOptions()
	setGameModes()
	
func setResolutionOptions():
	resolutionDropdown.add_item("1920x1080")
	resolutionDropdown.add_item("1600x900")
	resolutionDropdown.add_item("1280x720")
	resolutionDropdown.add_item("1024x576")
	resolutionDropdown.select(viewportcontrol.resNum)

func setGameModes():
	gameModeDropdown.add_item("Classic")
	gameModeDropdown.add_item("Rainbow")
	gameModeDropdown.add_item("Custom")
	gameModeDropdown.select(variables.gameMode)
	_on_Mode_Button_item_selected(variables.gameMode)
	variables.activeGameMode.clear()
	var k = variables.gameModes[variables.gameMode].keys()
	var v = variables.gameModes[variables.gameMode].values()
	for i in range(variables.gameModes[variables.gameMode].size()):
		variables.activeGameMode[k[i]] = v[i]
	

	
func _on_Mode_Button_item_selected( ID ):
	if ID < variables.gameModes.size():
		variables.gameMode = ID
		gameModeOptions.scoreLimit.set_value(variables.gameModes[ID].scoreLimit)
		gameModeOptions.timeLimit.set_value(variables.gameModes[ID].timeLimit)
		gameModeOptions.ballCount.set_value(variables.gameModes[ID].ballCount)
		gameModeOptions.pauseEnabled.set_toggle_mode(variables.gameModes[ID].pauseEnabled)
		gameModeOptions.moveWBall.set_toggle_mode(variables.gameModes[ID].moveWBall)


func _on_ScoreSlider_value_changed( value ):
	gameModeOptions.scoreLimitV.set_text(str(value))
	variables.activeGameMode.scoreLimit = value
	if value != variables.gameModes[variables.gameMode].scoreLimit:
		gameModeDropdown.select(2)


func _on_TimeSlider_value_changed( value ):
	gameModeOptions.timeLimitV.set_text(str(value))
	variables.activeGameMode.timeLimit = value
	if value != variables.gameModes[variables.gameMode].timeLimit:
		gameModeDropdown.select(2)


func _on_BallSlider_value_changed( value ):
	gameModeOptions.ballCountV.set_text(str(value))
	variables.activeGameMode.ballCount = value
	if value != variables.gameModes[variables.gameMode].ballCount:
		gameModeDropdown.select(2)


func _on_PauseCheckBox_toggled( pressed ):
	variables.activeGameMode.pauseEnabled = pressed
	if pressed != variables.gameModes[variables.gameMode].pauseEnabled:
		gameModeDropdown.select(2)


func _on_MoveWithBallCheckBox_toggled( pressed ):
	variables.activeGameMode.scoreLimit = pressed
	if pressed != variables.gameModes[variables.gameMode].moveWBall:
		gameModeDropdown.select(2)
