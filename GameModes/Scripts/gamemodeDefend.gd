extends Node3D


#-------------------GAME TIME SETTINGS-------------------
@export var gameLength: float = 120.0
@export var sakuraRespawnTimeFrame: float = 30.0
@export var sakuraSpawnNotificationTime: float = 3.0
@export var sakuraSpawnNotifcationColor: Color
var isGameTimeOver: bool = false
var currentTime: float


#-------------------GAME INSTANCES-------------------
var player
var tree
var treeSpawnPoints
var currentTreeLocationIndex: int = 0
var game
var canTeleport = true


#-------------------SIGNALS-------------------
signal gameOver
signal gameWon
signal updateGameTimer(time)
signal passMaxGameTime(maxTime)
signal flashTextMessage(message, displayTime, textColor)


#-------------------READY FUNCTION-------------------
# [ ? ] Initializes game settings and starts timers for the game and Sakura respawn
func _ready() -> void:
	passMaxGameTime.emit(gameLength)
	currentTime = gameLength

	$gameTimer.start(gameLength)
	$sakuraRespawnTimer.wait_time = sakuraRespawnTimeFrame
	$sakuraRespawnTimer.start()


#-------------------PROCESS FUNCTION-------------------
# [ ? ] Checks win/lose conditions, updates the game timer, and checks tree respawn
func _process(delta: float) -> void:
	checkWinLooseConditions()
	updateGameTimer.emit($gameTimer.time_left)
	checkForTreeRespawn()


#-------------------WIN/LOSE CONDITIONS-------------------
# [ ? ] Checks if the player or tree has no health or if the game time is over
func checkWinLooseConditions():
	if (player.currentPlayerHP <= 0 or tree.currentTreeHP <= 0):
		gameOver.emit()

	if (isGameTimeOver):
		gameWon.emit()


#-------------------SETUP FUNCTIONS-------------------
# [ ? ] Sets up the player instance
func setupPlayer(playerInstance):
	player = playerInstance
	print("HP", player.currentPlayerHP)

# [ ? ] Sets up the tree instance
func setupTree(treeInstance):
	tree = treeInstance

# [ ? ] Sets up the spawn points for the tree and checks for null reference
func setupTreeSpawnPoints(spawnPointsInstance):
	treeSpawnPoints = spawnPointsInstance
	if (treeSpawnPoints == null):
		print("NULL REFERENCE EXCEPTION")
	else:
		print("spawn points transmitted successfully")


#-------------------TIMER FUNCTIONS-------------------
# [ ? ] Sets the flag when the game time is over
func onGameTimerTimeout() -> void:
	isGameTimeOver = true


# [ ? ] Handles tree respawn at different spawn points and notifies the player
func onSakuraRespawnTimerTimeout() -> void:
	currentTreeLocationIndex += 1
	if (currentTreeLocationIndex > (len(treeSpawnPoints) - 1)):
		currentTreeLocationIndex = 0
	var tween = get_tree().create_tween()
	tween.tween_property(tree, "global_position", treeSpawnPoints[currentTreeLocationIndex].global_position, 1)
	flashTextMessage.emit("Follow the holy Sakura tree!", sakuraSpawnNotificationTime, sakuraSpawnNotifcationColor)
	canTeleport = true


# [ ? ] Checks if the tree can teleport when the respawn timer is about to finish
func checkForTreeRespawn():
	if ($sakuraRespawnTimer.time_left <= 3 && canTeleport == true):
		canTeleport = false
		tree.teleport()
