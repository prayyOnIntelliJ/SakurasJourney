extends ArenaBase


#----------------------SIGNALS----------------------
signal passMaxGameTime(maxTime)


#----------------------VARIABLES----------------------
var enemySpawner
var numEnemies : int = 0
@export var maxEnemyNumber = 200
@export var enemyRespawnThreshold = 50
var allSpawnersDeactivated = false

#----------------------INITIALIZATION----------------------
func _process(delta: float) -> void:
	# [ ? ] Checks if the number of enemies is within the threshold for respawn
	CheckEnemyNumber()

#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Enemy spawners are initialized
func initializeEnemySpawners():
	enemySpawner = $SpawnPaths.get_children()
	
	for spawner in enemySpawner:
		spawner.connect("onEnemySpawn", addEnemy)
		spawner.connect("onEnemyDeath", substractEnemy)
		spawner.setDifficulty(difficulty)
		spawner.setSpawnObject(spawnObject)
		
	print("Arena: ", spawnObject)
		
	print("Initialized")
		
func setupPlayer(playerInstance):
	# [ ? ] Sets up the player, assigns it to the survival gamemode, and configures enemy spawners
	super.setupPlayer(playerInstance)
	$gamemodeSurvival.setupPlayer(player)
	enemySpawner = $SpawnPaths.get_children()


#----------------------ENEMY MANAGEMENT----------------------
func addEnemy():
	# [ ? ] Increments the enemy count when a new enemy is spawned
	numEnemies += 1

func substractEnemy():
	# [ ? ] Decrements the enemy count when an enemy dies
	numEnemies -= 1


#----------------------ENEMY CHECKING----------------------
func CheckEnemyNumber():
	# [ ? ] Checks the current enemy count to manage the spawners based on thresholds
	if (numEnemies > maxEnemyNumber and !allSpawnersDeactivated):
		deactivateAllSpawner()
	if (numEnemies < enemyRespawnThreshold and allSpawnersDeactivated):
		activateAllSpawner()

func deactivateAllSpawner():
	# [ ? ] Deactivates all enemy spawners when there are too many enemies
	for i in len(enemySpawner):
		if (enemySpawner[i].spawnIsActivated):
			enemySpawner[i].spawnIsActivated = false
	allSpawnersDeactivated = true

func activateAllSpawner():
	# [ ? ] Activates all enemy spawners when the number of enemies is below the threshold
	for i in len(enemySpawner):
		if (!enemySpawner[i].spawnIsActivated):
			enemySpawner[i].spawnIsActivated = true
	allSpawnersDeactivated = false


#----------------------GAME STATE HANDLERS----------------------
func onGamemodeSurvivalGameOver() -> void:
	# [ ? ] Emits the game over signal when the game is over
	gameOver.emit()

func onGamemodeSurvivalGameWon() -> void:
	# [ ? ] Emits the game won signal when the game is won
	gameWon.emit()

func onGamemodeSurvivalUpdateGameTimer(time: Variant) -> void:
	# [ ? ] Emits the updated game timer signal
	updateGameTimer.emit(time)

func onGamemodeSurvivalPassMaxGameTime(maxTime: Variant) -> void:
	# [ ? ] Emits the max game time passed signal
	passMaxGameTime.emit(maxTime)


#----------------------UTILITY FUNCTIONS----------------------
func getSpawnPoint() -> Vector3:
	# [ ? ] Returns the spawn point position or the default position if not found
	return $PlayerSpawnPoint.global_position if $PlayerSpawnPoint && $PlayerSpawnPoint.global_position != Vector3.ZERO else PLAYER_DEFAULT_POSITION
