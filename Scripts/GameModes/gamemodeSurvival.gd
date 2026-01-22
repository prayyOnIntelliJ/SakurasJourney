extends Node3D


#-------------------GAME SETTINGS-------------------
@export var gameLength: float = 120.0
var isGameTimerOver: bool = false
var currentTime: float
var player
var game


#-------------------SIGNALS-------------------
signal gameOver
signal gameWon
signal updateGameTimer(time)
signal passMaxGameTime(maxTime)


#-------------------READY FUNCTION-------------------
# [ ? ] Initializes the game by setting up the timer and emitting the max game time
func _ready() -> void:
	passMaxGameTime.emit(gameLength)

	currentTime = gameLength
	$gameTimer.start(gameLength)


#-------------------PROCESS FUNCTION-------------------
# [ ? ] Checks win/lose conditions and updates the game timer every frame
func _process(delta: float) -> void:
	checkWinLooseConditions()
	updateGameTimer.emit($gameTimer.time_left)


#-------------------WIN/LOSE CONDITIONS-------------------
# [ ? ] Checks the win/lose conditions based on player's health and timer
func checkWinLooseConditions():
	if (player.currentPlayerHP <= 0):
		gameOver.emit()

	if (isGameTimerOver):
		gameWon.emit()


#-------------------SETUP FUNCTIONS-------------------
# [ ? ] Sets the player instance for the game
func setupPlayer(playerInstance):
	player = playerInstance
	print("gamemode", player)


#-------------------TIMER HANDLING-------------------
# [ ? ] Handles the game timer timeout event and triggers the end of the game
func onGameTimerTimeout() -> void:
	isGameTimerOver = true
