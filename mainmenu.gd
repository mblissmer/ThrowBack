extends Control
var player

func _ready():
	get_node("MainPage/1PGame").grab_focus()
	player = get_node("AnimationPlayer")
	
func _on_1PGame_pressed():
	variables.playerCount = 1
	player.play("oneplayer_swipe")
	get_node("DifficultyPage/Easy").grab_focus()
	get_node("MainPage").hideParticles(true)
	sounds.beep()

func _on_2PGame_pressed():
	variables.playerCount = 2
	startGame()

func _on_Controls_pressed():
	player.play("MainToControls")
	get_node("ControlsPage/ControlLines").play("ControlLines")
	get_node("ControlsPage/ContBack").grab_focus()
	get_node("MainPage").hideParticles(true)
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

func _on_ContBack_pressed():
	player.play_backwards("MainToControls")
	get_node("MainPage/Controls").grab_focus()
	get_node("MainPage").hideParticles(false)
	sounds.beep()

func _on_DifBack_pressed():
	player.play_backwards("oneplayer_swipe")
	get_node("MainPage/Controls").grab_focus()
	get_node("MainPage").hideParticles(false)
	sounds.beep()

func _on_Easy_pressed():
	variables.difficulty = 0
	startGame()


func _on_Med_pressed():
	variables.difficulty = 1
	startGame()


func _on_Hard_pressed():
	variables.difficulty = 2
	startGame()

func startGame():
	sounds.beep()
	transition.fade_to("res://Game.tscn")