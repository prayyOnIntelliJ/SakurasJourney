extends Baseenemy

#----------------------VARIABLES----------------------
# [ ? ] Maximum range at which the enemy can shoot
@export var shootingRange: float = 10.0 
# [ ? ] Time interval between shots in seconds
@export var fireRate: float = 1 
# [ ? ] Speed at which the projectiles travel
@export var projectileSpeed: float = 10.0 
# [ ? ] Flag to indicate whether the enemy can shoot
var canShoot: bool = false 
# [ ? ] The projectile scene to be instantiated
var projectileScene = preload("res://Projectiles/Scene/EnemyProjectile.tscn") 


#----------------------INITIALIZATION----------------------
# [ ? ] Call the parent class initialization
func _ready() -> void:
	super()


#----------------------GAME LOGIC----------------------
# [ ? ] Call the parent class _physics_process to handle movement and other updates
# [ ? ] Check if the target is within shooting range
func _physics_process(delta: float) -> void:
	super(delta)
	checkForDistance(shootingRange)


#----------------------SHOOTING LOGIC----------------------
# [ ? ] Shoot a projectile if possible
func shoot():
	$Timer.start(fireRate) # Start the fire rate timer
	var projectile = projectileScene.instantiate() # Instantiate the projectile
	var direction # Calculate the direction towards the target
	spawnObject.add_child(projectile) # Add the projectile to the spawn object
	projectile.global_position = global_position # Set the initial position of the projectile
	direction = (targettedObject.global_position - projectile.global_position).normalized() # Get the direction towards the target
	projectile.linear_velocity = direction * projectileSpeed # Set the speed of the projectile
	projectile.look_at_from_position(global_position, targettedObject.global_position) # Make the projectile face the target
	projectile.rotation.y += 1.5708 # Adjust rotation if necessary


#----------------------DISTANCE CHECK----------------------
# [ ? ] Check if the enemy is within shooting range of the target
func checkForDistance(distance: float):
	if (global_position.distance_to(targettedObject.global_position) <= distance):
		velocity = Vector3.ZERO # Stop the movement when within shooting range
		if (canShoot == true):
			canShoot = false # Disable shooting for now
			animationPlayer.play("shooter_shoot") # Play the shooting animation


#----------------------ANIMATION----------------------
# [ ? ] Set the walking animation when the enemy is walking
func setWalkingBehaviour():
	animationPlayer.play("shooter_walk") # Play walking animation
	canShoot = true # Allow the enemy to shoot again


#----------------------TIMER HANDLING----------------------
# [ ? ] Reset the shooting ability when the fire rate timer finishes
func on_timer_timeout() -> void:
	canShoot = true # Allow shooting again after the cooldown
