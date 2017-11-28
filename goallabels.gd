extends Control

var labels
var labelCols
var flash = false
var timer
var player
var white = false

func _ready():
	labels = [
		get_node("RedLabels/Red1Top"),
		get_node("RedLabels/Red1Bot"),
		get_node("RedLabels/Red3"),
		get_node("BlueLabels/Blue1Top"),
		get_node("BlueLabels/Blue1Bot"),
		get_node("BlueLabels/Blue3")
	]
	labelCols = [variables.ColGoalYellow, variables.ColGoalYellow, variables.ColGoalRed]
	timer = get_node("Timer")

func flashing(shouldFlash):
	if shouldFlash:
		timer.start()
	else:
		timer.stop()
		white = false
		changeColor()

func _on_Timer_timeout():
	white = !white
	changeColor()


func changeColor():
	for i in range(labels.size()):
		if white:
			labels[i].set("custom_colors/font_color", Color(1,1,1))
		else:
			var j = i
			if j >= labelCols.size():
				j -= labelCols.size()
			labels[i].set("custom_colors/font_color", labelCols[j])