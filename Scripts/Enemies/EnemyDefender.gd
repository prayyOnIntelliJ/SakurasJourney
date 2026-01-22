extends Baseenemy

signal enemyDeath(enemyPosition)

#----------------------VARIABLES----------------------
@export var shootingRange: float = 5.0
@export var fireRate: float = 0.5
@export var projectileSpeed: float = 10.0
var projectileScene: PackedScene = preload("res://Scenes/Projectiles/EnemyProjectile.tscn")
var canShoot: bool = true
var hasTarget: bool = false


#----------------------INITIALIZATION----------------------
# [ ? ] Initialize the parent class and setup the properties
func _ready() -> void:
	super()


#----------------------GAME LOGIC----------------------
# [ ? ] Check if the target is within shooting distance
func _physics_process(delta: float) -> void:
	checkForDistance(shootingRange)


#----------------------SHOOTING LOGIC----------------------
# [ ? ] Check if target is within shooting range, if so, start shooting animation
func checkForDistance(distance: float):
	if (targettedObject != null and global_position.distance_to(targettedObject.global_position) <= distance):
		if (canShoot):
			canShoot = false
			animationPlayer.play("defender_shoot")


# [ ? ] Instantiate the projectile and set its direction and speed
func shoot():
	$fireRateTimer.start(fireRate)
	var projectile = projectileScene.instantiate()
	var direction
	spawnObject.add_child(projectile)
	projectile.global_position = global_position
	direction = (targettedObject.global_position - projectile.global_position).normalized()
	projectile.linear_velocity = direction * projectileSpeed
	projectile.look_at_from_position(global_position, targettedObject.global_position)
	projectile.rotation.y += 1.5708


#----------------------COLLISION HANDLING----------------------
# [ ? ] Function exists to still enable the collision with this enemy
func handleShockwaveHit(damage):
	pass

# [ ? ] Handles the dash collisions, incase you dash through this enemy, nothing happens
func deactivateDashCollision():
	pass

# [ ? ] Handle damage taken by the enemy, trigger death if health reaches zero
func handleHit(damage):
	super(damage)
	if (currentHealth <= 0):
		enemyDeath.emit(position)


#----------------------ANIMATION----------------------
# [ ? ] Set the walking behavior animation for the enemy
func setWalkingBehaviour():
	animationPlayer.play("defender_idle")


# [ ? ] Set spawn object for projectiles and related effects
func setSpawnObject(object):
	spawnObject = object


# [ ? ] Trigger when the animation finishes and reset shoot ability
func onAnimationPlayerAnimationFinished(anim_name: StringName) -> void:
	if (anim_name == "Spawn"):
		canShoot = true


# [ ? ] Reset shooting ability after a delay
func on_timer_timeout() -> void:
	canShoot = true


func playDeath():
	animationPlayer.play("death")
