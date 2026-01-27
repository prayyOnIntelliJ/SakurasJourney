extends Node
class_name ArenaBase

#----------------------SIGNALS----------------------
signal gameOver
signal gameWon
signal updateGameTimer(time)

#----------------------VARIABLES----------------------
var game
var player
var difficulty
var spawnObject
var enemySpawners
var defenders

@export var PLAYER_DEFAULT_POSITION: Vector3 = Vector3(0.0, 1.7, 0.0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initializeEnemySpawners()

#----------------------ENEMY SPAWNER INITIALIZATION----------------------
# [ ? ] Initializes the enemy spawners and sets their difficulty and spawn object
func initializeEnemySpawners():
	enemySpawners = $SpawnPaths.get_children()
	
	for spawner in enemySpawners:
		spawner.setDifficulty(difficulty)
		spawner.setSpawnObject(spawnObject)

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

#----------------------SETUP FUNCTIONS----------------------
func setupTarget(target):
	enemySpawners = $SpawnPaths
	for spawner in enemySpawners.get_children():
		spawner.setupTarget(target)

# [ ? ] Sets the game's difficulty level
func setDifficulty(difficulty: int):
	self.difficulty = difficulty

func setSpawnObject(object):
	# [ ? ] Sets the spawn object for the enemy spawners
	spawnObject = object
	
func setupPlayer(playerInstance):
	# [ ? ] Sets up the player instance and initializes related game features
	self.player = playerInstance
	for spawner in $SpawnPaths.get_children():
		spawner.setupSoulTarget(player)
