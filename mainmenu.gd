extends Control

func _ready():
#	var monSize = OS.get_screen_size()
#	var originalSize = Vector2(1280,1024)
#	if monSize.x < originalSize.x or monSize.y < originalSize.y:
#		OS.set_window_size(Vector2(960,768))
#		OS.set_window_position(Vector2(10,10))
	get_node("MainPage/1PGame").grab_focus()

func _on_Exit_pressed():
	get_tree().quit()

func _on_2PGame_pressed():
	variables.playerCount = 2
	transition.fade_to("res://Game.tscn")


func _on_1PGame_pressed():
	variables.playerCount = 1
	transition.fade_to("res://Game.tscn")



func _on_Controls_pressed():
	get_node("AnimationPlayer").play("MainToControls")
	get_node("ControlsPage/Back").grab_focus()

func _on_Back_pressed():
	get_node("AnimationPlayer").play_backwards("MainToControls")
	get_node("MainPage/Controls").grab_focus()

func _on_1PGame_focus_enter():
	print ("1 player game")


func _on_1PGame_mouse_enter():
	_on_1PGame_focus_enter()
