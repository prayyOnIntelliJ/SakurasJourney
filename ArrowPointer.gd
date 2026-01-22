extends Node3D

@onready var arrowTransform = self.transform

var player
var target

var wasInitialized : bool = false

@export var y_offset : float = 8.0
@export var z_offset : float = -1.5


#----------------------PROCESSING----------------------
func _process(delta: float) -> void:
	# [ ? ] Updates the position of the arrow pointer relative to the player and target
	if (wasInitialized):
		self.position = Vector3(player.global_position.x, player.global_position.y + y_offset, player.global_position.z + z_offset)
		look_at(target.global_position, Vector3.UP)


#----------------------INITIALIZATION----------------------
func initArrowPointer(playerInstance, targetInstance):
	# [ ? ] Initializes the arrow pointer with player and target instances
	if (playerInstance != null):
		player = playerInstance

	if (targetInstance != null):
		target = targetInstance

	if (player != null and target != null):
		wasInitialized = true
	else: 
		wasInitialized = false


#----------------------TARGET SETTING----------------------
func setNewTarget(targetInstance):
	# [ ? ] Sets a new target for the arrow pointer
	self.target = targetInstance
	if (player != null and target != null):
		wasInitialized = true
	else: 
		wasInitialized = false
