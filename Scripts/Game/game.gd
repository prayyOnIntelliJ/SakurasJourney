extends Node3D

# -------------------GAME-------------------
var isGameRunning: bool = false
var difficulty
var selectedArena: int
var completedArenas = [false, false, false, false]

signal pauseGame
signal retryGame

# -------------------NODES-------------------
@onready var playerScene = preload("res://Scenes/Player/player.tscn")
@onready var UI = $UI
@onready var player = $Player
@onready var levels = $Levels
@onready var objectsInGame = $ObjectsInGame
@onready var musicPlayer = $UI/Musicplayer

# -------------------UPGRADE SYSTEM-------------------
@export var currentSkillPoints := 3
@export var battleMusic : Array[AudioStreamWAV]

# -------------------LEVELS-------------------
var level1 = preload("res://Scenes/Arena/Arena_01.tscn")
var level2 = preload("res://Scenes/Arena/Arena_02.tscn")
var level3 = preload("res://Scenes/Arena/Arena_03.tscn")
var level4 = preload("res://Scenes/Arena/Arena_04.tscn")
var tutorialLevel = preload("res://Scenes/Arena/Tutorial/Tutorial.tscn")
var levelArray = [level1, level2, level3, level4]

# -------------------GAME STATE-------------------
# [ ? ] Initialize the game state, UI, music, and pausing
func _ready() -> void:
	setScreen($UI/TitleScreen)
	passObjectsOnReady()
	playTitleMusic()
	updateGamePausing()

# [ ? ] Update game status during each frame
func _process(delta: float) -> void:
	if (isGameRunning):
		updateTimer()
		checkInputs()

# [ ? ] Handle input actions
func checkInputs():
	if (Input.is_action_just_pressed("quit")):
		setScreen($UI/PauseScreen)
		pauseGame.emit()

# -------------------GAME STATE CHANGES-------------------
# [ ? ] Change to the win screen
func changeToWinScreen():
	setScreen($UI/WinScreen)
	player.visible = false
	
# [ ? ] Change to the lose screen
func changeToLooseScreen():
	setScreen($UI/FailScreen)
	player.visible = false

# -------------------LEVEL AND GAME OVER HANDLING-------------------
# [ ? ] Handle game win situation
func onLevelsGameWon() -> void:
	isGameRunning = false
	updateGameState()
	updateGamePausing()
	updateSkillPointsForDifficulty(difficulty, selectedArena)
	changeToWinScreen()
	clearGameObjects()

# [ ? ] Handle game over situation
func onLevelsGameOver() -> void:
	isGameRunning = false
	changeToLooseScreen()
	updateGameState()
	updateGamePausing()
	clearGameObjects()

# [ ? ] Update game status when the game is running or paused
func updateGameState():
	player.updateGameState(isGameRunning)
	UI.Hud.updateGameState(isGameRunning)

# -------------------TIMER AND UI UPDATES-------------------
# [ ? ] Update the timer displayed in the UI
func updateTimer():
	UI.Hud.updateGameLength(levels.getCurrentTime())

# -------------------START GAME HANDLING-------------------
# [ ? ] Start the game with selected difficulty and settings
func onStartGame(difficultyLevel) -> void:
	isGameRunning = true
	levels.clearLevel()
	$UI/Hud.setDashStackResetTime(player.getDashStackResetTime())
	$UI/Hud.setDashCounter(player.getMaxDashStacks())
	updateGamePausing()
	checkIfSpawnPointIsSet(selectedArena)
	difficulty = difficultyLevel
	passObjects()
	setScreen(UI.Hud)
	levels.setDifficulty(difficulty)
	levels.setActiveLevel(levelArray[selectedArena])
	updateGameState()
	UI.musicPlayer.stop()
	UI.musicPlayerBattleMusic.stream = battleMusic[$UI/ArenaSelectionScreen.getCurrentArenaIndex()]
	UI.musicPlayerBattleMusic.play()
	player.global_position = levels.getSpawnPoint()
# -------------------TUTORIAL HANDLING-------------------
# [ ? ] Handle tutorial level start
func onArenaSelectionScreenStartTutorialLevel() -> void:
	passObjects()
	levels.startTutorialLevel(tutorialLevel)
	player.global_position = levels.getSpawnPoint()
	setScreen($UI/Hud)
	isGameRunning = true
	updateGamePausing()
	player.visible = true
	updateGameState()

# -------------------SETUP METHODS-------------------
# [ ? ] Set UI object reference
func setUIObject(object):
	object = UI

# [ ? ] Handle retry from the fail screen
func onFailScreenTryAgainEmitted() -> void:
	clearGameObjects()
	setScreen($UI/Hud)
	retryGame.emit()

# [ ? ] Pass necessary objects for the level setup
func passObjects():
	levels.setupPlayer(player)
	levels.setSpawnObject(objectsInGame)

# [ ? ] Update game pause state based on game running status
func updateGamePausing():
	if (isGameRunning):
		get_tree().paused = false
	else:
		get_tree().paused = true

# [ ? ] Play title music
func playTitleMusic():
	UI.musicPlayer.play()

# [ ? ] Set active screen in UI
func setScreen(screen):
	UI.setActiveScreen(screen)

# -------------------ARENA SELECTION AND DIFFICULTY HANDLING-------------------
# [ ? ] Set the selected arena index for arena setup
func onArenaSelectionScreenSetArenaIndex(index: Variant) -> void:
	selectedArena = index
	$UI/ArenaSettingsScreen.setSprites(index)

# [ ? ] Update skill points based on difficulty and arena progress
func updateSkillPointsForDifficulty(currentDifficulty: int, currentArena: int):
	var arenaDicts = [
		levels.completedArena1Dict,
		levels.completedArena2Dict,
		levels.completedArena3Dict,
		levels.completedArena4Dict,
	]

	if (!arenaDicts[currentArena][currentDifficulty]):
		arenaDicts[currentArena][currentDifficulty] = true
		currentSkillPoints += 1
		UI.winScreen.playSkillpointEarned()
	else:
		UI.winScreen.resetText()

	if (allLevelsCompleted(currentArena) && !completedArenas[currentArena]):
		completedArenas[currentArena] = true
		currentSkillPoints += 1
		UI.winScreen.allCleared = true
	else:
		UI.winScreen.allCleared = false

	UI.upgradeScreen.updateSkillPoints(currentSkillPoints)

# [ ? ] Check if all levels in the current arena are completed
func allLevelsCompleted(arenaIndex: int) -> bool:
	var arenaDicts = [
		levels.completedArena1Dict,
		levels.completedArena2Dict,
		levels.completedArena3Dict,
		levels.completedArena4Dict,
	]

	for key in arenaDicts[arenaIndex]:
		if (!arenaDicts[arenaIndex][key]):
			return false
	return true

# -------------------SPAWN POINT HANDLING-------------------
# [ ? ] Check if spawn point for the selected arena is set
func checkIfSpawnPointIsSet(arenaIndex: int):
	var spawnPoints = [
		levels.spawnPointArena1,
		levels.spawnPointArena2,
		levels.spawnPointArena3,
		levels.spawnPointArena4
	]
	if (spawnPoints[arenaIndex] == Vector3.ZERO):
		push_warning("Spawn point for arena ", arenaIndex, " is not set or at (0,0,0)!")


# -------------------OBJECT HANDLING-------------------
# [ ? ] Pass necessary objects on game initialization
func passObjectsOnReady():
	player.passObjects($MouseCursor, $UI/Hud, $ObjectsInGame)

	UI.setPlayer(player)
	UI.upgradeScreen.setGameObject(self)

# [ ? ] Clear all game objects from the scene
func clearGameObjects():
	for child in objectsInGame.get_children():
		child.queue_free()


# -------------------PAUSE HANDLING-------------------
# [ ? ] Handle change to main menu from pause screen
func onPauseScreenChangeToMainMenu() -> void:
	clearGameObjects()
