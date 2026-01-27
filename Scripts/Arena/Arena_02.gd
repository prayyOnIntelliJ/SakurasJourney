extends ArenaBase


#----------------------SIGNALS----------------------
signal updateSakuraTreeHP(health)
signal passMaxGameTime(maxTime)
signal flashTextMessage(message, displayTime, textColor)

#----------------------INITIALIZATION----------------------
func _ready() -> void:
	# [ ? ] Initializes enemy spawners and sets up tree spawn points
	setupTreeSpawnPoints()


#----------------------SETUP FUNCTIONS----------------------
func setupTarget(target):
	# [ ? ] Sets up the target for all enemy spawners and assigns spawn objects
	enemySpawners = $SpawnPaths.get_children()
	for spawner in enemySpawners:
		spawner.setupTarget(target)
		spawner.setSpawnObject(spawnObject)

func setupPlayer(playerInstance):
	# [ ? ] Sets up the player instance and initializes related game features
	super(playerInstance)
	$gamemode_defend.setupPlayer(player)
	$gamemode_defend.setupTree(getSakuraTree())
	$ArrowPointer.initArrowPointer(player, getSakuraTree())


func setupTreeSpawnPoints():
	# [ ? ] Sets up the spawn points for the Sakura tree
	var sakuraSpawnPoints = $SakuraSpawnPoints.get_children()
	if (sakuraSpawnPoints != null):
		$gamemode_defend.setupTreeSpawnPoints(sakuraSpawnPoints)

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
