extends Node

var playerCount = 0
var difficulty = 0
const aiSpeeds = [2,5,8]
const aiReturnSpeeds = [1.5,1,0.5]
const joyDZ = 0.3
var gameMode = 0
var gameModes = [
	{
		scoreLimit = 7,
		timeLimit = 90,
		ballCount = 1,
		pauseEnabled = true,
		moveWBall = false
	},
	{
		scoreLimit = 15,
		timeLimit = 100,
		ballCount = 5,
		pauseEnabled = false,
		moveWBall = true
	}
]
var activeGameMode = {
	scoreLimit = 0,
	timeLimit = 0,
	ballCount = 0,
	pauseEnabled = true,
	moveWBall = false
}

const colors = {
	playerRed = Color(1, 0, 0.506),
	playerBlue = Color(0.259, 0.776, 1),
	ballPurple = Color(0.561, 0.165, 0.639),
	pink = Color(0.988, 0.408, 0.992),
	lightPink = Color(0.965, 0.835, 1),
	goalYellow = Color(0.957, 0.722, 0.047),
	goalRed = Color(0.957, 0.133, 0.353)
}

var player = {
	speed = 300,
	dashDist = 400,
	dashSpeed = 10,
	autoReturn = false,
	poweredUpReturn = true,
	moveWithBall = false
}

var game = {
	scoreLimit = 7,
	timeLimit = 90,
	ballCount = 1,
	canPause = true
}
