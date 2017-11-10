extends Control

var fadeOutMenu
var opacity = 1

func _ready():
	set_process(true)

func _process(delta):
	if fadeOutMenu:
		opacity -= delta * 4
		set_opacity(opacity)
		if opacity <= 0:
			hide()
			opacity = 1
			fadeOutMenu = false

func _on_Exit_pressed():
	get_tree().quit()

func _on_Settings_pressed():
	pass # replace with function body


func _on_2PGame_pressed():
	fadeOutMenu = true
	get_parent().createGame(2)


func _on_1PGame_pressed():
	fadeOutMenu = true
	get_parent().createGame(1)

