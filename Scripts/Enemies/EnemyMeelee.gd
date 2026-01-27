extends EnemyBase

#----------------------VARIABLES----------------------
@export var attackRange: float = 3.0 # [ ? ] Maximum distance to initiate attack, should not be less than 2.9
@export var attackRate: float = 0.5 # [ ? ] Time between consecutive attacks in seconds
var target = null # [ ? ] The target to attack


#----------------------INITIALIZATION----------------------
# [ ? ] Call the parent class initialization
func _ready() -> void:
	super() 


#----------------------GAME LOGIC----------------------
# [ ? ] Call the parent class _physics_process to handle movement and other updates
# [ ? ] Check if the target is within attack range
func _physics_process(delta: float) -> void:
	super(delta) 
	checkForDistance(attackRange) 


#----------------------ATTACK LOGIC----------------------
# [ ? ] Handle attack logic
func attack():
	# [ ? ] If the enemy is allowed to attack and has a valid target
	if (canAttack):
		if (target != null): 
			# Apply damage to the target
			target.collideWithEnemy(enemyDamage) 
			canAttack = false # Set canAttack to false to prevent rapid consecutive attacks
			$Timer.start(attackRate) # Start a timer to control attack rate
	else: 
		canAttack = false # Ensure the enemy cannot attack again until the timer ends


#----------------------DISTANCE CHECK----------------------
# [ ? ] Check if the target is within the specified attack range
func checkForDistance(distance: float):
	if (global_position.distance_to(targettedObject.global_position) <= distance):
		velocity = Vector3.ZERO # Stop the movement of the enemy when within range


#----------------------COLLISION HANDLING----------------------
# [ ? ] Handle when the enemy's area collides with another body
func onArea3dBodyEntered(body: Node3D) -> void:
	if (body.has_method("collideWithEnemy") and animationPlayer.current_animation != "death"):
		# Set the target to the colliding body
		target = body 
		canAttack = true # Enable attacking
		animationPlayer.play("melee_attack") # Play melee attack animation


# [ ? ] Handle when the enemy's area stops colliding with another body
func onArea3dBodyExited(body: Node3D) -> void:
	if (body.has_method("collideWithEnemy") and animationPlayer.current_animation != "death"):
		# Remove the target when it exits the area
		target = null 
		canAttack = false # Disable attacking
		animationPlayer.play("melee_walk") # Play walking animation


#----------------------TIMER HANDLING----------------------
# [ ? ] Handle timer timeout to reset the attack cooldown
func on_timer_timeout() -> void:
	if (target != null && animationPlayer.current_animation != "death"):
		canAttack = true # Enable attacking again after the cooldown
		animationPlayer.play("melee_attack") # Play melee attack animation


#----------------------ANIMATION----------------------
# [ ? ] Set the animation when the enemy is walking
func setWalkingBehaviour():
	animationPlayer.play("melee_walk") # Play the walking animation
