extends Node3D


#----------------------SIGNALS----------------------
signal gameOver
signal gameWon
signal updateGameTimer(time)
signal updateSakuraTreeHP(health)
signal passMaxGameTime(maxTime)
signal flashTextMessage(message, displayTime, textColor)


#----------------------VARIABLES----------------------
var game
var enemySpawners
var difficulty
var spawnObject
var player

const PLAYER_DEFAULT_POSITION: Vector3 = Vector3(0.0, 1.7, 0.0)


#----------------------INITIALIZATION----------------------
func _ready() -> void:
	# [ ? ] Initializes enemy spawners and sets up tree spawn points
	initializeEnemySpawners()
	setupTreeSpawnPoints()


#----------------------SETUP FUNCTIONS----------------------
func setupTarget(target):
	# [ ? ] Sets up the target for all enemy spawners and assigns spawn objects
	enemySpawners = $SpawnPaths.get_children()
	for spawner in enemySpawners:
		spawner.setupTarget(target)
		spawner.setSpawnObject(spawnObject)


func initializeEnemySpawners():
	# [ ? ] Initializes the enemy spawners
	enemySpawners = $SpawnPaths.get_children()
	
	for spawner in enemySpawners:
		spawner.setDifficulty(difficulty)
		spawner.setSpawnObject(spawnObject)


func setDifficulty(difficulty: int):
	# [ ? ] Sets the difficulty level for the game
	self.difficulty = difficulty


func setupPlayer(playerInstance):
	# [ ? ] Sets up the player instance and initializes related game features
	self.player = playerInstance
	$gamemode_defend.setupPlayer(player)
	$gamemode_defend.setupTree(getSakuraTree())
	$ArrowPointer.initArrowPointer(player, getSakuraTree())
	for spawner in $SpawnPaths.get_children():
		spawner.setupSoulTarget(player)


func setupTreeSpawnPoints():
	# [ ? ] Sets up the spawn points for the Sakura tree
	var sakuraSpawnPoints = $SakuraSpawnPoints.get_children()
	if (sakuraSpawnPoints != null):
		$gamemode_defend.setupTreeSpawnPoints(sakuraSpawnPoints)


func setSpawnObject(object):
	# [ ? ] Sets the spawn object for enemies
	spawnObject = object


#----------------------GAME STATE HANDLERS----------------------
func onGamemodeDefendGameOver() -> void:
	# [ ? ] Emits the game over signal
	gameOver.emit()


func onGamemodeDefendGameWon() -> void:
	# [ ? ] Emits the game won signal
	gameWon.emit()


func onSakuraTreeUpdateSakuraTreeHealth(health: Variant) -> void:
	# [ ? ] Emits the updated health of the Sakura tree
	updateSakuraTreeHP.emit(health)


func onGamemodeDefendPassMaxGameTime(maxTime: Variant) -> void:
	# [ ? ] Emits the maximum game time reached signal
	passMaxGameTime.emit(maxTime)


func onGamemodeDefendUpdateGameTimer(time: Variant) -> void:
	# [ ? ] Emits the updated game timer
	updateGameTimer.emit(time)


func onFlashMessage(message, displayTime, textColor) -> void:
	# [ ? ] Emits a flash message to be displayed
	flashTextMessage.emit(message, displayTime, textColor)


#----------------------UTILITY FUNCTIONS----------------------
func getTargetType() -> int:
	# [ ? ] Returns the target type identifier (e.g., 1 for some type of target)
	return 1


func getSakuraTree():
	# [ ? ] Returns the Sakura tree node
	return $NavigationRegion3D/SakuraTreeGroup/SakuraTree


func getSpawnPoint() -> Vector3:
	# [ ? ] Returns the spawn point for the player, defaulting to PLAYER_DEFAULT_POSITION if no spawn point is set
	return $PlayerSpawnPoint.global_position if $PlayerSpawnPoint && $PlayerSpawnPoint.global_position != Vector3.ZERO else PLAYER_DEFAULT_POSITION
