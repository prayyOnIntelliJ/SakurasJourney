extends CSGBox3D

@export var cloudsToSpawn: int = 3
@export var cloud: PackedScene


#----------------------INITIALIZATION----------------------
# [ ? ] Starts the timer when the node enters the scene tree for the first time
func _ready() -> void:
	$"../Timer".start($"..".startTimer)


#----------------------CLOUD SPAWNING----------------------
# [ ? ] Spawns clouds at random positions within the defined area
func spawnClouds():
	while cloudsToSpawn >= 0:
		cloudsToSpawn -= 1
		
		var x: float = randf_range(size.x / 2, -size.x / 2)
		var y: float = 0
		var z: float = randf_range(size.z / 2, -size.z / 2)
		
		var spawnPos: Vector3 = Vector3(x, y, z)
		
		var newCloud = cloud.instantiate()
		newCloud.global_position = spawnPos
		add_child(newCloud)


#----------------------TIMER HANDLING----------------------
# [ ? ] Handles the timer timeout event to spawn clouds
func onTimerTimeout() -> void:
	spawnClouds()
