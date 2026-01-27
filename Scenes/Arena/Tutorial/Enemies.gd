extends Node3D


#----------------------VARIABLES----------------------
var enemyScene = preload("res://Scenes/Arena/Tutorial/enemy_tutorial.tscn")
var enemy
@onready var resetTimer = $resetEnemyTimer


#----------------------INITIALIZATION----------------------
# [ ? ] Connects the signals of all children to the parent
func _ready() -> void:
	connectSignalsOfChildren()


#----------------------SIGNAL HANDLING----------------------
# [ ? ] Loops through the children and connects their death signal to the parent
func connectSignalsOfChildren():
	for child in get_children():
		if (child.has_signal("enemyDeath")):
			# [ ? ] Connects the enemy death signal to the onEnemyDeath method
			child.enemyDeath.connect(onEnemyDeath)


#----------------------ENEMY DEATH HANDLING----------------------
# [ ? ] Handles the enemy's death, instantiates a new enemy, and sets its properties
func onEnemyDeath(oldEnemyPosition):
	enemy = enemyScene.instantiate()
	enemy.global_position = oldEnemyPosition
	enemy.enemyDeath.connect(onEnemyDeath)
	enemy.scale = Vector3(1.5, 1.5, 1.5)
	enemy.canRespawn = true
	add_child(enemy)
