extends StaticBody3D


#----------------------SIGNALS----------------------
signal updateBossTreeHP(health)
signal flashTextMessage(message, displayTime, textColor)
signal setMaxBossTreeHP(health)


#----------------------BOSS HEALTH----------------------
@export var maxHealth: float = 100.0
@export var canBeInvincible: bool = false
@export var sakuraSpawnNotificationTime: float = 3.0
@export var sakuraSpawnNotifcationColor: Color
@onready var difficultyModifiers := [1.0, 1.2, 1.4, 1.6]

var isInvincible: bool = false
var areChildrenSet: bool = false
var currentBossTreeHP
var spawnObject
var target
var bossTree25HP
var bossTree50HP
var bossTree75HP
var percentageIndex: int = 0
var percentageArray: Array
var canHaveStats: bool

var smallBossTreeScene = preload("res://Scenes/Boss/smallBossTree.tscn")
var smallBossTree
var spawnPointArray: Array
var indicatorScene = preload("res://Scenes/Boss/BossIndicator.tscn")
var arrowPointer


#----------------------INITIALIZATION----------------------
# [ ? ] Called when the node enters the scene tree
func _ready() -> void:
	checkForInvincibility()


# [ ? ] Initializes boss stats based on difficulty and sets max health
func initializeStats():
	if (canHaveStats):
		maxHealth *= difficultyModifiers[ArenaSettings.getDifficultyLevel()]
	else:
		maxHealth *= difficultyModifiers[0]
	currentBossTreeHP = maxHealth
	setMaxBossTreeHP.emit(maxHealth)


# [ ? ] Checks if boss should be invincible and children are set, else logs an error
func checkForInvincibility():
	if (canBeInvincible):
		if (checkIfChildrenAreSet() == true):
			canHaveStats = true
			initializeStats()
			calculateBossHPPercentageAndAssign()
		else:
			push_error("No children are set for the boss tree")
			canBeInvincible = false
	else:
		canHaveStats = false
		initializeStats()


#----------------------DAMAGE HANDLING----------------------
# [ ? ] Handles damage logic for the boss, including invincibility check
func hitBadTree(damage):
	if (canBeInvincible):
		if (!isInvincible):
			currentBossTreeHP -= damage
			updateBossTreeHP.emit(currentBossTreeHP)
			$hitSoundPlayer.play()
			checkForPercentagesReached()
		else:
			$invincibleHitSoundPlayer.play()
	else:
		currentBossTreeHP -= damage
		updateBossTreeHP.emit(currentBossTreeHP)
		$hitSoundPlayer.play()


#----------------------SMALL BOSS EVENT----------------------
# [ ? ] Checks if certain health percentage is reached to spawn a smaller boss and shield
func checkForPercentagesReached():
	if (currentBossTreeHP <= percentageArray[percentageIndex] && percentageIndex < len(percentageArray) - 1):
		var spawnPoint = getRandomSpawnPoint()
		var smallBossInstance = spawnPoint.spawnSmallBoss()
		if (arrowPointer != null):
			arrowPointer.setNewTarget(smallBossInstance)
		var indicator = indicatorScene.instantiate()
		indicator.newPosition = spawnPoint.global_position
		add_child(indicator)
		spawnShield()
		flashTextMessage.emit("Destroy the seedling to break the shield", sakuraSpawnNotificationTime, sakuraSpawnNotifcationColor)


#----------------------SPAWN HANDLING----------------------
# [ ? ] Sets the spawn points for small bosses
func setSpawnPoints():
	for child in get_children():
		if (child.has_method("spawnSmallBoss")):
			spawnPointArray.append(child)
			child.setupTarget(target)
			child.setSpawnObject(spawnObject)


# [ ? ] Assigns the spawn object to each spawn point
func setupSpawnObject():
	for child in get_children():
		if (child.has_method("spawnSmallBoss")):
			child.setSpawnObject(spawnObject)


# [ ? ] Returns a random spawn point for small bosses
func getRandomSpawnPoint():
	var randomNumber = randi_range(0, len(spawnPointArray) - 1)
	spawnPointArray[randomNumber].smallBossDied.connect(onSmallBossDied)
	return spawnPointArray[randomNumber]


# [ ? ] Handles small boss death event and updates next spawn percentage
func onSmallBossDied():
	if (arrowPointer != null):
		arrowPointer.setNewTarget(self)
	if (percentageIndex < len(percentageArray) - 1):
		percentageIndex += 1
	despawnShield()


# [ ? ] Calculates the HP percentages for small boss events
func calculateBossHPPercentageAndAssign():
	bossTree75HP = maxHealth * 0.75
	bossTree50HP = maxHealth * 0.5
	bossTree25HP = maxHealth * 0.25
	percentageArray.append(bossTree75HP)
	percentageArray.append(bossTree50HP)
	percentageArray.append(bossTree25HP)
	percentageArray.append(0) # Bug prevention


#----------------------GETTERS----------------------
# [ ? ] Returns the boss's maximum health
func getMaxHealth():
	return maxHealth


#----------------------SETUP / HELPERS----------------------
# [ ? ] Checks if spawn points for small bosses are set
func checkIfChildrenAreSet():
	areChildrenSet = false
	for child in get_children():
		if (child.has_method("spawnSmallBoss")):
			return true
			break


# [ ? ] Sets the target for spawned small bosses
func setupTarget(target):
	self.target = target
	setSpawnPoints()


# [ ? ] Sets the object to spawn from spawn points
func setSpawnObject(object):
	self.spawnObject = object
	setupSpawnObject()


# [ ? ] Assigns an arrow pointer to track the target
func setArrowPointer(arrowPointer):
	self.arrowPointer = arrowPointer


#----------------------SHIELD CONTROL----------------------
# [ ? ] Plays shield spawn animation
func spawnShield():
	$shieldAnimationPlayer.play("spawnShield")


# [ ? ] Plays shield despawn animation
func despawnShield():
	$shieldAnimationPlayer.play("despawnShield")
