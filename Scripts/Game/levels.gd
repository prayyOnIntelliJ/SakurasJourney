extends Node3D

# -------------------GAME VARIABLES & SIGNALS-------------------
var target = []
var player
var tree
var currentTime
var gameLength
var difficulty
var game
var playerSpawnPoint
var badTreeMaxHealth
var sakuraTreeMaxHealth
var spawnObject

signal gameOver
signal gameWon
signal updateSakuraTreeHP(health)
signal updateBossTreeHP(health)
signal setMaxSakuraHealth(health)
signal setMaxBossHealth(health)
signal hideTimer
signal passMaxGameTime(maxTime)
signal flashTextMessage(message, displayTime, textColor)

# -------------------ARENA SPAWN POINTS-------------------
@export_group("SpawnPoints")
@export var spawnPointArena1: Vector3
@export var spawnPointArena2: Vector3
@export var spawnPointArena3: Vector3
@export var spawnPointArena4: Vector3
@export var spawnPointTutorial: Vector3

@onready var spawnPointDict = {
	0: spawnPointArena1,
	1: spawnPointArena2,
	2: spawnPointArena3,
	3: spawnPointArena4,
	4: spawnPointTutorial
}

# -------------------ARENA COMPLETION STATUS-------------------
var isArena1NormalCompleted: bool = false
var isArena1HardCompleted: bool = false
var isArena1VeryHardCompleted: bool = false
var isArena1HorrorCompleted: bool = false

var completedArena1Dict = {
	0: isArena1NormalCompleted,
	1: isArena1HardCompleted,
	2: isArena1VeryHardCompleted,
	3: isArena1HorrorCompleted
}

var isArena2NormalCompleted: bool = false
var isArena2HardCompleted: bool = false
var isArena2VeryHardCompleted: bool = false
var isArena2HorrorCompleted: bool = false

var completedArena2Dict = {
	0: isArena2NormalCompleted,
	1: isArena2HardCompleted,
	2: isArena2VeryHardCompleted,
	3: isArena2HorrorCompleted
}

var isArena3NormalCompleted: bool = false
var isArena3HardCompleted: bool = false
var isArena3VeryHardCompleted: bool = false
var isArena3HorrorCompleted: bool = false

var completedArena3Dict = {
	0: isArena3NormalCompleted,
	1: isArena3HardCompleted,
	2: isArena3VeryHardCompleted,
	3: isArena3HorrorCompleted
}

var isArena4NormalCompleted: bool = false
var isArena4HardCompleted: bool = false
var isArena4VeryHardCompleted: bool = false
var isArena4HorrorCompleted: bool = false

var completedArena4Dict = {
	0: isArena4NormalCompleted,
	1: isArena4HardCompleted,
	2: isArena4VeryHardCompleted,
	3: isArena4HorrorCompleted
}

var completedDict = {
	0: completedArena1Dict,
	1: completedArena2Dict,
	2: completedArena3Dict,
	3: completedArena4Dict
}

# -------------------LEVEL HANDLING-------------------
# [ ? ] Set the active level by instantiating and setting up the level scene.
func setActiveLevel(levelScene: PackedScene):
	var allNodes = get_children()
	var newLevel = levelScene.instantiate()
	
	# Clean up previous nodes and set up the new level
	for node in allNodes:
		node.queue_free()
	
	target.append(player)
	newLevel.setupTarget(target)
	newLevel.setDifficulty(difficulty)
	newLevel.setSpawnObject(spawnObject)
	newLevel.setupPlayer(player)
	
	# Check if new level has a Sakura tree and connect signals
	if (newLevel.has_method("getSakuraTree")):
		target.append(newLevel.getSakuraTree())
		newLevel.connect("updateSakuraTreeHP", onUpdateSakuraTreeHP)
		setMaxSakuraHealth.emit(newLevel.getSakuraTree().getMaxHealth())
		
	# Check if new level has a Boss tree and connect signals
	if (newLevel.has_method("getBossTree")):
		newLevel.connect("updateBossTreeHP", onUpdateBossTreeHP)
		newLevel.connect("setMaxBossTreeHP", onSetMaxBossTreeHP)

	# Check if timer should be hidden
	if (newLevel.has_method("hideTimer")):
		hideTimer.emit()
	
	# Connect signals for game over, game won, and timer updates
	newLevel.connect("gameOver", gameOverEmitted)
	newLevel.connect("gameWon", gameWonEmitted)
	newLevel.connect("updateGameTimer", updateGameTimer)
	newLevel.connect("passMaxGameTime", onPassMaxGameTime)
	newLevel.connect("flashTextMessage", onFlashMessage)
	
	add_child(newLevel)
	playerSpawnPoint = newLevel.getSpawnPoint()

# -------------------LEVEL MANAGEMENT-------------------
# [ ? ] Clear the current level by freeing all child nodes
func clearLevel():
	var children = get_children()
	for child in children:
		child.queue_free()
	target.clear()

# [ ? ] Setup the player object in the game
func setupPlayer(player):
	self.player = player

# [ ? ] Emit the game over signal
func gameOverEmitted():
	gameOver.emit()

# [ ? ] Emit the game won signal
func gameWonEmitted():
	gameWon.emit()

# -------------------TIMER MANAGEMENT-------------------
# [ ? ] Update the game timer and set the current time
func updateGameTimer(time):
	setCurrentTime(time)

# [ ? ] Get the current game time
func getCurrentTime():
	return currentTime

# [ ? ] Set the current game time
func setCurrentTime(time):
	currentTime = time

# -------------------UI HANDLING-------------------
# [ ? ] Clear the level when UI requests it
func onUIClearLevel() -> void:
	clearLevel()

# -------------------DIFFICULTY HANDLING-------------------
# [ ? ] Set the game difficulty
func setDifficulty(difficulty):
	self.difficulty = difficulty

# -------------------HEALTH UPDATES-------------------
# [ ? ] Update the health of the Sakura tree
func onUpdateSakuraTreeHP(health):
	updateSakuraTreeHP.emit(health)

# [ ? ] Update the health of the Boss tree
func onUpdateBossTreeHP(health):
	updateBossTreeHP.emit(health)

func onSetMaxBossTreeHP(health):
	setMaxBossHealth.emit(health)

# -------------------TUTORIAL HANDLING-------------------
# [ ? ] Start the tutorial level by instantiating and adding it to the scene
func startTutorialLevel(LevelScene: PackedScene):
	var level = LevelScene.instantiate()
	var allNodes = get_children()
	
	for node in allNodes:
		node.queue_free()
		
	playerSpawnPoint = level.getSpawnPoint()
	add_child(level)

# -------------------SPAWN POINTS & GAME TIME-------------------
# [ ? ] Get the spawn point for the current level
func getSpawnPoint():
	return playerSpawnPoint

# [ ? ] Get the maximum health of the bad tree
func getBadTreeMaxHealth():
	return badTreeMaxHealth

# [ ? ] Get the maximum health of the Sakura tree
func getSakuraTreeMaxHealth():
	return sakuraTreeMaxHealth

# [ ? ] Handle passing the max game time event
func onPassMaxGameTime(maxTime):
	passMaxGameTime.emit(maxTime)
	
# [ ? ] Handle flashing a message on the screen
func onFlashMessage(message, displayTime, textColor):
	flashTextMessage.emit(message, displayTime, textColor)

# -------------------SCREEN TRANSITIONS-------------------
# [ ? ] Change to the arena selection screen after a win
func onWinScreenChangeToArenaSelectionScreen() -> void:
	clearLevel()

# [ ? ] Change to the title screen after a fail
func onFailScreenChangeToTitleScreen() -> void:
	clearLevel()

# -------------------OBJECT SETUP-------------------
# [ ? ] Set the spawn object for the level
func setSpawnObject(object):
	spawnObject = object
