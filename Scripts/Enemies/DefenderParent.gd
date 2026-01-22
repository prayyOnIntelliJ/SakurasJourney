extends Node3D


#----------------------VARIABLES----------------------
var enemyDefenderScene = preload("res://Scenes/Enemies/Enemy_Defender.tscn")
var enemy
var target
var spawnObject
var spawnposition


#----------------------INITIALIZATION----------------------
# [ ? ] Initializes the enemy respawn by connecting the signals of its children
func _ready() -> void:
	connectSignalsOfChildren()


#----------------------SIGNAL HANDLING----------------------
# [ ? ] Connects the enemyDeath signal of each child to the onEnemyDeath function
func connectSignalsOfChildren():
	for child in get_children():
		if (child.has_signal("enemyDeath")):
			child.enemyDeath.connect(onEnemyDeath)


#----------------------ENEMY DEATH HANDLING----------------------
# [ ? ] Handles enemy death by storing its position and starting the respawn timer
func onEnemyDeath(enemyPosition):
	spawnposition = enemyPosition
	$respawnTimer.start()


#----------------------RESPAWN FUNCTION----------------------
# [ ? ] Respawns the enemy at the given position, sets the target and spawn object
func respawn(enemyPosition):
	enemy = enemyDefenderScene.instantiate()
	enemy.global_position = enemyPosition
	enemy.targettedObject = target
	enemy.setSpawnObject(spawnObject)
	enemy.enemyDeath.connect(onEnemyDeath)
	add_child(enemy)


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets the target for the enemy and establishes signal connections
func setupTarget(target):
	self.target = target
	connectSignalsOfChildren()


#----------------------PROPERTY FUNCTIONS----------------------
# [ ? ] Sets the object responsible for spawning projectiles etc.
func setSpawnObject(object):
	self.spawnObject = object


#----------------------RESPAWN TIMER----------------------
# [ ? ] Handles the timeout of the respawn timer and respawns the enemy
func onRespawnTimerTimeout() -> void:
	respawn(spawnposition)
