extends ArenaBase


#----------------------SIGNALS----------------------
signal updateBossTreeHP(health)
signal flashTextMessage(message, displayTime, textColor)
signal setMaxBossTreeHP(health)

#----------------------INITIALIZATION----------------------
func _ready() -> void:
	initializeDefenders()


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets up the player and the related game mode and pointers
func setupPlayer(playerInstance):
	super(playerInstance)
	$gamemodeAttack.setupTree(getBossTree())
	$gamemodeAttack.setupPlayer(player)
	$ArrowPointer.initArrowPointer(player, getBossTree())
	$gamemodeAttack.setupArrowPointer($ArrowPointer)
	print("Arena 03", player)


# [ ? ] Sets up the enemy spawners and boss tree targets
func setupTarget(target):
	super(target)
	getBossTree().setupTarget(target[0])


# [ ? ] Sets the difficulty of the game and updates the boss tree difficulty
func setDifficulty(difficulty: int):
	$BossTree.setDifficulty(difficulty)


# [ ? ] Sets the spawn object for defenders and spawners
func setSpawnObject(object):
	super(object)
	$DefenderParent.setSpawnObject(object)
	getBossTree().setSpawnObject(object)
	for spawner in enemySpawners:
		spawner.setDifficulty(ArenaSettings.getDifficultyLevel())
		spawner.setSpawnObject(object)
	for defenderSpawner in $DefenderParent.get_children():
		if (defenderSpawner is EnemyBase):
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
