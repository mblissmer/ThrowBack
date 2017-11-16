extends Control

var p1FinalScore
var p2FinalScore
var p1WL
var p2WL
var p1Buttons
var p2Buttons
var p2WantsRematch
var p1WantsRematch

func _ready():
	p1FinalScore = get_node("p1FinalScore")
	p2FinalScore = get_node("p2FinalScore")
	p1WL = get_node("p1WL")
	p2WL = get_node("p2WL")
	p1Buttons = get_node("p1Buttons")
	p2Buttons = get_node("p2Buttons")
	
func setup(p1score, p2score, p1state, p2state):
	p1FinalScore.set_text(p1score)
	p2FinalScore.set_text(p2score)
	p1WL.set_text(p1state)
	p2WL.set_text(p2state)
	if variables.playerCount == 1:
		p2Buttons.hide()
		p1Buttons.set_pos(Vector2(320,540))
	else: 
		p2Buttons.show()
		p1Buttons.set_pos(Vector2(0,540))


func _on_P1_Rematch_pressed():
	p1WantsRematch = true
	if variables.playerCount == 1:
		transition.fade_to("res://Game.tscn")
	elif p2WantsRematch != null:
		if p2WantsRematch:
			transition.fade_to("res://Game.tscn")
		else:
			transition.fade_to("res://MainMenu.tscn")


func _on_P1_Exit_pressed():
	p1WantsRematch = false
	if variables.playerCount == 1 or p2WantsRematch != null:
		transition.fade_to("res://MainMenu.tscn")

func _on_P2_Rematch_pressed():
	p2WantsRematch = true
	if p1WantsRematch != null:
		if p1WantsRematch == true:
			transition.fade_to("res://Game.tscn")
		else: 
			transition.fade_to("res://MainMenu.tscn")


func _on_P2_Exit_pressed():
	p2WantsRematch = false
	if p1WantsRematch != null:
		transition.fade_to("res://MainMenu.tscn")
