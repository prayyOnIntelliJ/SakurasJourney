extends CharacterBody3D


#----------------------SIGNALS----------------------
signal enemyDeath(enemyPosition)


#----------------------ENUMS----------------------
enum EnemyVulnerability {
	RED_PROJECTILE,
	BLUE_PROJECTILE
}


#----------------------VARIABLES----------------------
var enemyVulnerability : EnemyVulnerability
@export var canRespawn: bool = false
@export var respawnTime: float = 1.0
@export var tutorialType : int

var randomEnemyType
var randomEnemyColor

@onready var difficultyModifiers := [1.0, 1.3, 1.6, 2.0]
var difficultyLevel: int

#----------------------MOVEMENT AND COMBAT VARIABLES----------------------
@export var speed: float = 2.0
@export var acceleration: float = 10.0
@export var maxHealth = 100.0
var currentHealth
@export var damage: float = 10.0

var player


#----------------------INITIALIZATION----------------------
# [ ? ] Initializes the enemy stats and properties based on the tutorial type and difficulty
func _ready() -> void:
	initializeStats()
	enemyVulnerability = EnemyVulnerability.values()[tutorialType]
	
	currentHealth = maxHealth
	
	initializeProperties()
	$Sprite3D/AnimationPlayer.play("Walk")


#----------------------COMBAT SYSTEM----------------------
func handleTutorialHit(damage: float):
	currentHealth -= damage
	
	if (currentHealth <= 0):
		die()
	else:
		$Sprite3D/AnimationPlayer.play("Hit")


func handleShockwaveHit(damage: float):
	currentHealth -= damage
	
	if (currentHealth <= 0):
		die()
	else:
		$Sprite3D/AnimationPlayer.play("Hit")


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets the target for the enemy (usually the player)
func setTarget(target: Node):
	player = target


#----------------------PROPERTY FUNCTIONS----------------------
# [ ? ] Initializes the enemy's properties based on vulnerability
func initializeProperties():
	if (enemyVulnerability == EnemyVulnerability.RED_PROJECTILE):
		$Sprite3D.modulate = Color.RED
	else:
		$Sprite3D.modulate = Color.AQUA


#----------------------UTILITY FUNCTIONS----------------------
# [ ? ] Initializes the stats (health, damage, speed) based on the current difficulty level
func initializeStats():
	maxHealth *= difficultyModifiers[difficultyLevel]
	damage *= difficultyModifiers[difficultyLevel]
	speed *= difficultyModifiers[difficultyLevel]


# [ ? ] Sets the difficulty level, which adjusts the enemy's stats accordingly
func setDifficulty(level: int):
	difficultyLevel = level


#----------------------DEATH AND RESPAWN HANDLING----------------------
# [ ? ] Handles the death of the enemy, plays the death animation, and handles respawn if enabled
func die():
	if (canRespawn):
		$respawnTimer.start(respawnTime)
		$Sprite3D/AnimationPlayer.play("deathWithRespawn")
	else:
		$Sprite3D/AnimationPlayer.play("death")
		$AudioStreamPlayer2D.play(0.2)


# [ ? ] Handles the respawn timer timeout, emitting death signal and freeing the object from the scene
func onRespawnTimerTimeout() -> void:
	enemyDeath.emit(global_position)
	queue_free()
