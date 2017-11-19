extends Control

var p1FinalScore
var p2FinalScore
var p1WL
var p2WL
var buttons

func _ready():
	p1FinalScore = get_node("p1FinalScore")
	p2FinalScore = get_node("p2FinalScore")
	p1WL = get_node("p1WL")
	p2WL = get_node("p2WL")
	
func setup(p1score, p2score, p1state, p2state):
	p1FinalScore.set_text(p1score)
	p2FinalScore.set_text(p2score)
	p1WL.set_text(p1state)
	p2WL.set_text(p2state)

func _on_Rematch_pressed():
	sounds.beep()
	transition.fade_to("res://Game.tscn")

func _on_Exit_pressed():
	sounds.negativeBeep()
	transition.fade_to("res://MainMenu.tscn")
