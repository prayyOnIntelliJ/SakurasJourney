extends StaticBody3D


#----------------------VARIABLES----------------------
@export var maxHealth: float = 100.0
var currentBossTreeHP
var target
var spawnObject
@onready var difficultyModifiers := [1.0, 1.2, 1.4, 1.6]
var difficultyLevel: int


#----------------------SIGNALS----------------------
signal smallBossDied


#----------------------INITIALIZATION----------------------
# [ ? ] Sets the initial health of the boss tree to the maximum health value
func _ready() -> void:
	initializeStats()

#----------------------DAMAGE HANDLING----------------------
# [ ? ] Handles damage to the small boss tree and checks if it should die
func hitSmallTree(damage):
	currentBossTreeHP -= damage
	$hitSoundPlayer.play()

	if (currentBossTreeHP <= 0):
		# [ ? ] Emits a signal when the small boss tree dies and frees the object from the scene
		smallBossDied.emit()
		$DefenderParentSmallParent.playDeathOfChildren()
		$AnimationPlayer.play("death")
		


#----------------------TARGET HANDLING----------------------
# [ ? ] Sets the target for the small boss tree and passes it to the defender parent
func setupTarget(targettedObject):
	self.target = targettedObject
	$DefenderParentSmallParent.setupTarget(targettedObject)


#----------------------SPAWN OBJECT HANDLING----------------------
# [ ? ] Sets the spawn object for the small boss tree and passes it to the defender parent
func setSpawnObject(object):
	self.spawnObject = object
	$DefenderParentSmallParent.setSpawnObject(object)


#----------------------GETTERS----------------------
# [ ? ] Returns the maximum health of the small boss tree
func getMaxHealth():
	return maxHealth

func setDifficulty(difficulty):
	self.difficultyLevel = difficulty

func initializeStats():
	maxHealth *= difficultyModifiers[difficultyLevel]
	currentBossTreeHP = maxHealth
