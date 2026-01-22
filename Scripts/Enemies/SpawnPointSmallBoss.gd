extends Node3D

#----------------------VARIABLES----------------------
# [ ? ] Scene for the small boss object to be loaded
var smallBossScene = preload("res://Scenes/Boss/smallBossTree.tscn") 
# [ ? ] The small boss instance to be spawned
var smallBoss
# [ ? ] The target the small boss will follow or interact with
var target
# [ ? ] The object that will handle spawning mechanics
var spawnObject
# [ ? ] Signal emitted when the small boss dies
signal smallBossDied
var difficultyLevel


#----------------------SPAWN LOGIC----------------------
# [ ? ] Spawn a small boss at the current location
func spawnSmallBoss():
	smallBoss = smallBossScene.instantiate() 
	smallBoss.smallBossDied.connect(onSmallBossDeath)
	smallBoss.setupTarget(target)
	smallBoss.setSpawnObject(spawnObject)
	smallBoss.setDifficulty(difficultyLevel)
	add_child(smallBoss) 
	return smallBoss


#----------------------DEATH HANDLING----------------------
# [ ? ] Called when the small boss dies, emits the smallBossDied signal
func onSmallBossDeath():
	smallBossDied.emit()


#----------------------SETUP LOGIC----------------------
# [ ? ] Set the target for the small boss
func setupTarget(targettedObject):
	self.target = targettedObject

func setDifficulty(difficulty):
	self.difficultyLevel = difficulty

#----------------------SPAWN OBJECT SETUP----------------------
# [ ? ] Set the spawn object for the small boss
func setSpawnObject(object):
	self.spawnObject = object
