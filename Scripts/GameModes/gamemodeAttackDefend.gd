extends Node3D


#----------------------INITIALIZED VARIABLES----------------------
var player
var game
var bossTree
var sakuraTree
var arrowPointer

@export var bossMessage : String = "Hurry! Fight the evil Jubokko Tree!"
@export var sakuraMessage : String = "Quick! Defend the holy Sakura Tree!"

@export var messageDuration : float = 2.5

@export var attackMessageColor : Color
@export var defendMessageColor : Color

#----------------------SIGNALS----------------------
signal gameWon
signal gameOver
signal shieldStateChanged
signal flashTextMessage(message, displayTime, textColor)

#----------------------GAME LOGIC----------------------
# [ ? ] Checks the win or lose conditions each frame
func _process(delta: float) -> void:
	checkWinLooseConditions()


#----------------------CONDITIONS CHECK----------------------
# [ ? ] Checks the win/lose conditions based on the health of the boss tree, player, and sakura tree
func checkWinLooseConditions() -> void:
	if (bossTree.currentBossTreeHP <= 0):
		gameWon.emit()

	elif (player.currentPlayerHP <= 0 || sakuraTree.currentTreeHP <= 0):
		gameOver.emit()

func onAttackPhaseEnded():
	if (!bossTree.isInvincible):
		bossTree.isInvincible = true
		bossTree.spawnShield()
		shieldStateChanged.emit()
		arrowPointer.setNewTarget(sakuraTree)
		flashTextMessage.emit(sakuraMessage, messageDuration, defendMessageColor)
	
	else:
		bossTree.isInvincible = false
		bossTree.despawnShield()
		shieldStateChanged.emit()
		arrowPointer.setNewTarget(bossTree)
		flashTextMessage.emit(bossMessage, messageDuration, attackMessageColor)

#----------------------SETUP----------------------
# [ ? ] Sets up the player instance
func setupPlayer(playerInstance) -> void:
	player = playerInstance


# [ ? ] Sets up the boss tree instance
func setupBossTree(bossTreeInstance) -> void:
	bossTree = bossTreeInstance


# [ ? ] Sets up the sakura tree instance
func setupSakuraTree(sakuraTreeInstance) -> void:
	sakuraTree = sakuraTreeInstance

func setArrowPointer(pointer):
	self.arrowPointer = pointer
