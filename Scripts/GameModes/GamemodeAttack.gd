extends Node3D

#-------------------INITIALIZED VARIABLES-------------------
var player
var game
var tree

#-------------------SIGNALS-------------------
signal gameWon
signal gameOver


#-------------------GAME LOGIC-------------------
# [ ? ] Checks the game state every frame to see if win/lose conditions are met
func _process(delta: float) -> void:
	checkWinLooseConditions()


#-------------------CONDITIONS CHECK-------------------
# [ ? ] Checks if the game should end due to win or loss conditions
func checkWinLooseConditions() -> void:
	if (tree.currentBossTreeHP <= 0):
		# [ ? ] The boss tree's health is 0 or less, the player wins
		gameWon.emit()
	elif (player.currentPlayerHP <= 0):
		# [ ? ] The player's health is 0 or less, the game is over
		gameOver.emit()


#-------------------SETUP-------------------
# [ ? ] Sets up the player instance
func setupPlayer(playerInstance) -> void:
	player = playerInstance


# [ ? ] Sets up the tree instance
func setupTree(treeInstance) -> void:
	tree = treeInstance


# [ ? ] Sets up the arrow pointer for the tree
func setupArrowPointer(arrowPointer):
	tree.setArrowPointer(arrowPointer)
