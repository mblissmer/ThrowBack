extends Control

func _ready():
	get_node("MainPage/1PGame").grab_focus()
	
func _on_1PGame_pressed():
	variables.playerCount = 1
	transition.fade_to("res://Game.tscn")
	sounds.beep()

func _on_2PGame_pressed():
	variables.playerCount = 2
	transition.fade_to("res://Game.tscn")
	sounds.beep()

func _on_Controls_pressed():
	get_node("AnimationPlayer").play("MainToControls")
	get_node("ControlsPage/Back").grab_focus()
	sounds.beep()

func _on_Exit_pressed():
	sounds.negativeBeep()
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t,"timeout")
	get_tree().quit()

func timeout():
	pass

func _on_Back_pressed():
	get_node("AnimationPlayer").play_backwards("MainToControls")
	get_node("MainPage/Controls").grab_focus()
	sounds.beep()
