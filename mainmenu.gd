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

func _on_2PGame_pressed():
	variables.playerCount = 2
	startGame()

func _on_Controls_pressed():
	player.play("controls_swipe")
	get_node("SettingsPage/ControlLines").play("ControlLines")
	get_node("SettingsPage/Back").grab_focus()
	get_node("MainPage").hideParticles(true)

func _on_About_pressed():
	player.play("about_swipe")
	get_node("AboutPage/AbtBack").grab_focus()
	get_node("MainPage").hideParticles(true)


func _on_Exit_pressed():
	get_tree().quit()

func _on_ContBack_pressed():
	player.play_backwards("controls_swipe")
	get_node("MainPage/Settings").grab_focus()
	get_node("MainPage").hideParticles(false)

func _on_DifBack_pressed():
	player.play_backwards("oneplayer_swipe")
	get_node("MainPage/1PGame").grab_focus()
	get_node("MainPage").hideParticles(false)

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
	transition.fade_to("res://Game.tscn")

func _on_AbtBack_pressed():
	player.play_backwards("about_swipe")
	get_node("MainPage/About").grab_focus()
	get_node("MainPage").hideParticles(false)
