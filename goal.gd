extends Area2D

var value
var name = ""
var player = ""
var areaType = "goal"
var root

func _ready():
	root = get_node("/root/Game")
	print (get_path())
	
func setup(val,p,n):
	value = val
	player = p
	name = n
	
func score():
	root.score(player, value)