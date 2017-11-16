extends Control

func _on_Resume_pressed():
	get_tree().set_pause(false)
	hide()


func _on_Exit_pressed():
	transition.fade_to("res://MainMenu.tscn")
