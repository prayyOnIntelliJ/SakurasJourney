extends Node3D


#----------------------SIGNALS----------------------
signal gameOver
signal gameWon
signal updateBossTreeHP(health)
signal flashTextMessage(message, displayTime, textColor)
signal setMaxBossTreeHP(health)


#----------------------VARIABLES----------------------
var player
var enemySpawners
var defenders
var difficulty
var spawnObject

const PLAYER_DEFAULT_POSITION: Vector3 = Vector3(0.0, 1.7, 0.0)


#----------------------INITIALIZATION----------------------
func _ready() -> void:
	initializeDefenders()
	initializeEnemySpawners()


#----------------------DEFENDER INITIALIZATION----------------------
# [ ? ] Initializes the defenders and sets their target to the player
func initializeDefenders():
	defenders = $DefenderParent.get_children()
	$DefenderParent.setupTarget(player)
	
	if (defenders.is_empty()):
		push_error("No defenders found under DefenderParent")
		return
	
	for defender in defenders:
		if (defender.has_method("setupTarget")):
			defender.setupTarget(player)
		else:
			push_error("Warning: No method 'setupTarget' found in ", defender.name)


#----------------------ENEMY SPAWNER INITIALIZATION----------------------
# [ ? ] Initializes the enemy spawners and sets their difficulty and spawn object
func initializeEnemySpawners():
	enemySpawners = $SpawnPaths.get_children()
	
	for spawner in enemySpawners:
		spawner.setDifficulty(difficulty)
		spawner.setSpawnObject(spawnObject)


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets up the player and the related game mode and pointers
func setupPlayer(playerInstance):
	self.player = playerInstance
	$gamemodeAttack.setupTree(getBossTree())
	$gamemodeAttack.setupPlayer(player)
	$ArrowPointer.initArrowPointer(player, getBossTree())
	$gamemodeAttack.setupArrowPointer($ArrowPointer)
	print("Arena 03", player)
	for spawner in $SpawnPaths.get_children():
		spawner.setupSoulTarget(player)


# [ ? ] Sets up the enemy spawners and boss tree targets
func setupTarget(target):
	enemySpawners = $SpawnPaths.get_children()
	for spawner in enemySpawners:
		spawner.setupTarget(target)
	getBossTree().setupTarget(target[0])


# [ ? ] Sets the difficulty of the game and updates the boss tree difficulty
func setDifficulty(difficulty: int):
	self.difficulty = difficulty
	$BossTree.setDifficulty(difficulty)


# [ ? ] Sets the spawn object for defenders and spawners
func setSpawnObject(object):
	spawnObject = object
	$DefenderParent.setSpawnObject(object)
	getBossTree().setSpawnObject(object)
	for spawner in enemySpawners:
		spawner.setDifficulty(difficulty)
		spawner.setSpawnObject(object)
	for defenderSpawner in $DefenderParent.get_children():
		if (defenderSpawner is Baseenemy):
			defenderSpawner.setSpawnObject(object)


#----------------------GAME STATE HANDLERS----------------------
# [ ? ] Emits the game over signal when the game is over
func onGamemodeAttackGameOver() -> void:
	gameOver.emit()


# [ ? ] Emits the game won signal when the player wins the game
func onGamemodeAttackGameWon() -> void:
	gameWon.emit()


# [ ? ] Updates the boss tree health
func onBossTreeUpdateBossTreeHP(health: Variant) -> void:
	updateBossTreeHP.emit(health)


#----------------------UTILITY FUNCTIONS----------------------
# [ ? ] Returns the boss tree node
func getBossTree():
	return $BossTree


# [ ? ] Returns the player's spawn point or a default position if none is set
func getSpawnPoint() -> Vector3:
	return $PlayerSpawnPoint.global_position if $PlayerSpawnPoint && $PlayerSpawnPoint.global_position != Vector3.ZERO else PLAYER_DEFAULT_POSITION


# [ ? ] Placeholder function for hiding the timer (currently does nothing)
func hideTimer():
	pass


# [ ? ] Emits a text message to flash on the screen
func onBossTreeFlashTextMessage(message: Variant, displayTime: Variant, textColor: Variant) -> void:
	flashTextMessage.emit(message, displayTime, textColor)


# [ ? ] Sets the max health for the boss tree
func onBossTreeSetMaxBossTreeHP(health: Variant) -> void:
	setMaxBossTreeHP.emit(health)
