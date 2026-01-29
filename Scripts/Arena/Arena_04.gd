extends ArenaBase


#----------------------SIGNALS----------------------
signal updateSakuraTreeHP(health)
signal updateBossTreeHP(health)
signal passMaxGameTime(maxTime)
signal attackPhaseEnded
signal flashTextMessage(message, displayTime, textColor)
signal setMaxBossTreeHP(health)


#----------------------VARIABLES----------------------
@export var attackPhaseTimeFrame : float = 20.0
@export var attackSpawnerIndices = []
@export var defendSpawnerIndices = []


#----------------------INITIALIZATION----------------------
# [ ? ] Initializes the defenders and enemy spawners, and starts the attack phase timer
func _ready() -> void:
	initializeDefenders()
	$AttackPhaseTimer.wait_time = attackPhaseTimeFrame
	$AttackPhaseTimer.start()

#----------------------GAME STATE HANDLERS----------------------
# [ ? ] Emits the gameOver signal when the game is over
func onGamemodeAttackDefendGameOver() -> void:
	gameOver.emit()

# [ ? ] Emits the gameWon signal when the game is won
func onGamemodeAttackDefendGameWon() -> void:
	gameWon.emit()

# [ ? ] Emits the updateSakuraTreeHP signal when the Sakura Tree's health is updated
func onSakuraTreeUpdateSakuraTreeHealth(health: Variant) -> void:
	updateSakuraTreeHP.emit(health)

# [ ? ] Emits the updateBossTreeHP signal when the Boss Tree's health is updated
func onBossTreeUpdateBossTreeHP(health: Variant) -> void:
	updateBossTreeHP.emit(health)

# [ ? ] Emits the attackPhaseEnded signal when the attack phase timer runs out
func on_attack_phase_timer_timeout() -> void:
	attackPhaseEnded.emit()


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets up the player and relevant game objects like the Boss Tree and Sakura Tree
func setupPlayer(playerInstance):
	super(playerInstance)
	$gamemodeAttackDefend.setupPlayer(player)
	$gamemodeAttackDefend.setupBossTree(getBossTree())
	$gamemodeAttackDefend.setupSakuraTree(getSakuraTree())
	$gamemodeAttackDefend.setArrowPointer($ArrowPointer)
	$gamemodeAttackDefend.arrowPointer.initArrowPointer(player, getBossTree())

# [ ? ] Sets the spawn object for various game components like defenders and spawners
func setSpawnObject(object):
	super(object)
	$DefenderParent.setSpawnObject(object)
	getBossTree().setSpawnObject(object)
	for spawner in enemySpawners.get_children():
		spawner.setDifficulty(ArenaSettings.getDifficultyLevel())
		spawner.setSpawnObject(object)
	for defenderSpawner in $DefenderParent.get_children():
		if defenderSpawner is EnemyBase:
			defenderSpawner.setSpawnObject(object)


#----------------------UTILITY FUNCTIONS----------------------
# [ ? ] Returns the Sakura Tree node
func getSakuraTree():
	return $NavigationRegion3D/SakuraTreeArea/SakuraTree

# [ ? ] Returns the Boss Tree node
func getBossTree():
	return $BossTree

# [ ? ] Returns the spawn point of the player, or the default position if not set
func getSpawnPoint() -> Vector3:
	return $PlayerSpawnPoint.global_position if $PlayerSpawnPoint && $PlayerSpawnPoint.global_position != Vector3.ZERO else PLAYER_DEFAULT_POSITION

# [ ? ] Activates or deactivates enemy spawners depending on whether the Boss Tree is invincible
func activateSpawners():
	var isInvincible = $gamemodeAttackDefend.bossTree.isInvincible
	if (isInvincible):
		for i in len(defendSpawnerIndices):
			var index = defendSpawnerIndices[i]
			if (index >= 0 and index < len(enemySpawners)):
				enemySpawners[index].spawnIsActivated = true
				
		for i in len(attackSpawnerIndices):
			var index = attackSpawnerIndices[i]
			if (index >= 0 and index < len(enemySpawners)):
				enemySpawners[index].spawnIsActivated = false
	else:
		for i in len(defendSpawnerIndices):
			var index = defendSpawnerIndices[i]
			if (index >= 0 and index < len(enemySpawners)):
				enemySpawners[index].spawnIsActivated = false
				
		for i in len(attackSpawnerIndices):
			var index = attackSpawnerIndices[i]
			if (index >= 0 and index < len(enemySpawners)):
				enemySpawners[index].spawnIsActivated = true

# [ ? ] Sends a flash text message to the player
func sendFlashTextMessage(message, displayTime, textColor):
	flashTextMessage.emit(message, displayTime, textColor)


# [ ? ] Handles the mission goal timer timeout by sending a flash message
func on_mission_goal_timer_timeout() -> void:
	var messageText = $gamemodeAttackDefend.bossMessage
	var displayTimer = $gamemodeAttackDefend.messageDuration
	var color = $gamemodeAttackDefend.attackMessageColor
	
	var canSendMessage : bool
	
	if (messageText != null && displayTimer != null):
		canSendMessage = true
		
	if (color != null):
		flashTextMessage.emit(messageText, displayTimer, color)
	else:
		color = Color(1, 1, 1, 1)
		flashTextMessage.emit(messageText, displayTimer, color)


# [ ? ] Emits the setMaxBossTreeHP signal to update the max health of the Boss Tree
func onBossTreeSetMaxBossTreeHP(health: Variant) -> void:
	setMaxBossTreeHP.emit(health)
