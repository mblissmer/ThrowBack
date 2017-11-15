extends Control

func _ready():
	var monSize = OS.get_screen_size()
	var originalSize = Vector2(1280,1024)
	if monSize.x < originalSize.x or monSize.y < originalSize.y:
		OS.set_window_size(Vector2(960,768))
		OS.set_window_position(Vector2(10,10))

func _on_Exit_pressed():
	get_tree().quit()

func _on_Settings_pressed():
	pass # replace with function body


func _on_2PGame_pressed():
	variables.playerCount = 2
	transition.fade_to("res://Game.tscn")
#	get_parent().createGame(2)


func _on_1PGame_pressed():
	variables.playerCount = 1
	transition.fade_to("res://Game.tscn")
#	get_parent().createGame(1)

