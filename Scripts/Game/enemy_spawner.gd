extends Path3D

#----------------------PRELOAD SCENES----------------------
# [ ? ] Preload enemy scenes for different types of enemies
@onready var enemyBomberScene = preload("res://Enemies/Scenes/NewEnemies/Enemy_Bomber.tscn")
@onready var enemyMeleeScene = preload("res://Enemies/Scenes/NewEnemies/Enemy_Melee.tscn")
@onready var enemyShooterScene = preload("res://Enemies/Scenes/NewEnemies/Enemy_Shooter.tscn")
@onready var pathFollow = $enemySpawnerFollow
@onready var firstSpawnTimer = $firstSpawmTimer
@onready var spawnIntervalTimer = $spawnIntervalTimer
const minSpawnInterval = 1.0

#----------------------VARIABLES----------------------
# [ ? ] Define various variables for targets, spawn objects, and difficulty modifiers
var targetArray
var target
var soulTarget
var game
var difficulty
@export var difficultySpawnModifiers = [1.0, 1.5, 2.0, 2.5]
var enemy
var spawnObject
@export var spawnIsActivated : bool = true

#----------------------ENUMS----------------------
# [ ? ] Define enumerations for enemy types and targeted groups
enum enemySceneEnum {
	ENEMY_BOMBER,
	ENEMY_MELEE,
	ENEMY_SHOOTER
}

@export var enemyToSpawn: enemySceneEnum

enum targetEnum {
	PLAYER,
	TREE_IF_AVAILABLE
}

@export var targetedGroup: targetEnum

# [ ? ] Set the basic properties of the enemies (health, damage, speed, acceleration)
@export var localEnemyHealth : float = 10.0
@export var localEnemyDamage : float = 10.0
@export var localEnemySpeed : float = 1.0
@export var localEnemyAcceleration : float = 10.0

# [ ? ] Set the timing for the first spawn and the interval between enemy spawns
@export var firstSpawnTimeFrame : float = 1.0
@export var spawnInterval: float = 5.0 # in seconds
@export var enemiesOnFirstSpawn : int = 3
@export var enemiesPerSpawn: int = 10

signal onEnemySpawn
signal onEnemyDeath

#----------------------INITIALIZATION----------------------
# [ ? ] Ensure the path has points and set up timers for spawn intervals
func _ready() -> void:
	if (curve.point_count == 0):
		push_error("The Path3D needs to have points to spawn Enemies.")
	
	firstSpawnTimer.wait_time = firstSpawnTimeFrame
	spawnIntervalTimer.wait_time = spawnInterval
	firstSpawnTimer.start()

#----------------------TIMERS----------------------
# [ ? ] Adjust spawn interval based on difficulty
func setWaitTimePerDifficulty():
	if (spawnIntervalTimer != null):
		var newSpawnInterval = spawnInterval / difficultySpawnModifiers[difficulty]
		if (newSpawnInterval >= minSpawnInterval):
			spawnIntervalTimer.wait_time = newSpawnInterval
		else:
			spawnIntervalTimer.wait_time = minSpawnInterval
	else:
		$childControlTimer.start()

# [ ? ] First spawn after the timer expires
func on_first_spawm_timer_timeout() -> void:
	if (spawnIsActivated):
		spawn_enemies(enemiesOnFirstSpawn)
	spawnIntervalTimer.start()

# [ ? ] Spawn enemies at regular intervals after first spawn
func onSpawnTimerTimeout():
	if (spawnIsActivated):
		spawn_enemies(enemiesPerSpawn)

#----------------------ENEMY SPAWN LOGIC----------------------
# [ ? ] Spawn a number of enemies at once
func spawn_enemies(numberOfEnemies : int):
	for i in range(numberOfEnemies):
		spawnEnemy()
		await get_tree().process_frame

# [ ? ] Spawn a single enemy based on the selected type
func spawnEnemy():
	# [ ? ] Instantiate the correct enemy based on the selected type
	if (enemyToSpawn == enemySceneEnum.ENEMY_BOMBER):
		enemy = enemyBomberScene.instantiate()
	elif (enemyToSpawn == enemySceneEnum.ENEMY_MELEE):
		enemy = enemyMeleeScene.instantiate()
	elif (enemyToSpawn == enemySceneEnum.ENEMY_SHOOTER):
		enemy = enemyShooterScene.instantiate()
	
	# [ ? ] Set up the spawn object and enemy properties
	enemy.setSpawnObject(spawnObject)
	enemy.setEnemyPropertiesExternal(localEnemyHealth, localEnemyDamage, localEnemySpeed, localEnemyAcceleration)
	
	# [ ? ] Select the target based on the targeted group
	if (targetArray.size() > 0):
		if (targetedGroup == targetEnum.PLAYER):
			target = targetArray[0]
		elif (targetedGroup == targetEnum.TREE_IF_AVAILABLE):
			if (len(targetArray) > 1):
				push_error("Tree is selected but no tree exists in the arena.")
				target = targetArray[1]
			else:
				target = targetArray[0]
	
	# [ ? ] Final setup for the enemy's target and path
	enemy.setupTarget(target)
	enemy.setupSoulTarget(soulTarget)
	
	# [ ? ] Randomize path progress and set enemy's starting position
	pathFollow.set_progress_ratio(randf())
	enemy.global_position = pathFollow.global_position
	
	# [ ? ] Apply difficulty settings
	enemy.setDifficulty(difficulty)
	enemy.connect("enemyDied", sendEnemyDeath)
	onEnemySpawn.emit()
	spawnObject.add_child(enemy)

#----------------------SETTERS----------------------
# [ ? ] Set the target array
func setupTarget(targetArray):
	self.targetArray = targetArray

# [ ? ] Set the soul target for the enemies
func setupSoulTarget(soulTarget):
	self.soulTarget = soulTarget

# [ ? ] Set the difficulty level and adjust spawn timing accordingly
func setDifficulty(difficulty):
	self.difficulty = difficulty
	setWaitTimePerDifficulty()

# [ ? ] Set the spawn object for the projectiles etc.
func setSpawnObject(object):
	spawnObject = object

# [ ? ] Emit the enemy death signal when an enemy dies
func sendEnemyDeath():
	onEnemyDeath.emit()

# [ ? ] Timer handling for adjusting spawn difficulty
func on_child_control_timer_timeout() -> void:
	setWaitTimePerDifficulty()
