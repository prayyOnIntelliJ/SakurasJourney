extends CharacterBody3D
class_name Baseenemy


#----------------------SIGNALS----------------------
signal enemyDied


#----------------------ENUMS----------------------
enum EnemyVulnerability {
	RED_PROJECTILE,  # Vulnerable to red projectile
	BLUE_PROJECTILE  # Vulnerable to blue projectile
}


#----------------------NODE----------------------
@onready var animationPlayer = $Sprite3D/AnimationPlayer


#----------------------VARIABLES----------------------
# [ ? ] Vulnerability type of the enemy (either red or blue)
var enemyVulnerability : EnemyVulnerability

# [ ? ] Shaders for red and blue vulnerability
var redShader : ShaderMaterial = preload("res://Enemies/Shader/shader_enemy_fire.tres")
var blueShader : ShaderMaterial = preload("res://Enemies/Shader/shader_enemy_Spiritual.tres")

# [ ? ] Randomized properties for the enemy
var randomEnemyType
var randomEnemyColor

# [ ? ] The object responsible for spawning the enemy
var spawnObject

# [ ? ] Particle effect for enemy spawn
var spawnParticleEffect = preload("res://Projectiles/VFX/SpawnParticles.tscn")

# [ ? ] Textures for the gradient based on vulnerability
var blueGradient : GradientTexture1D = preload("res://Enemies/Shader/tex_gradient_enemy_spiritual.tres")
var redGradient : GradientTexture1D = preload("res://Enemies/Shader/tex_gradient_enemy_red.tres")
var gradient

# [ ? ] Charge soul object for when the enemy dies
var chargeSoul = preload("res://ChargeSoul.tscn")


#----------------------UPGRADESYSTEM----------------------
# [ ? ] Difficulty modifiers to scale the enemy's stats
@onready var difficultyModifiers := [1.0, 1.2, 1.4, 1.6]

# [ ? ] The current difficulty level of the game
var difficultyLevel: int


#----------------------MOVEMENT----------------------
@export var speed: float = 2.0
@export var acceleration: float = 10.0


#----------------------COMBAT----------------------
@export var maxHealth = 100.0
var currentHealth
var soulTarget

@export var enemyDamage: float = 10.0
var targettedObject
var canAttack = true


#----------------------INITIALIZATION----------------------
# [ ? ] Sets up the initial properties when the enemy is ready
func _ready() -> void:
	initializeStats()  # Initialize the stats based on difficulty
	enemyVulnerability = randi_range(0, 1)  # Randomly set the vulnerability type
	initializeEnemyProperties()  # Initialize the enemy properties


#----------------------GAME STATE HANDLERS----------------------
# [ ? ] Handles the physics and movement during the game loop
func _physics_process(delta: float) -> void:
	if (!canAttack):
		var direction = Vector3()

		$NavigationAgent3D.target_position = targettedObject.global_position  # Set target position

		direction = $NavigationAgent3D.get_next_path_position() - global_position
		direction = direction.normalized()

		velocity = velocity.lerp(direction * speed, acceleration * delta)  # Move toward target

		move_and_slide()  # Perform movement


#----------------------COMBAT SYSTEM----------------------
# [ ? ] Handles when the enemy is hit by damage (e.g., from the projectile)
func handleHit(damage: float):
	$Sprite3D/AnimationPlayer.stop()  # Stop the animation
	currentHealth -= damage  # Subtract health from the enemy
	$AudioStreamPlayer2D2.play(0.2)  # Play damage sound
	if (currentHealth <= 0):
		$Sprite3D/AnimationPlayer.play("death")  # Play death animation
		enemyDied.emit()  # Emit enemy death signal
		spawnChargeSoul()  # Spawn charge soul when the enemy dies
	else:
		$Sprite3D/AnimationPlayer.play("Hit")  # Play hit animation


# [ ? ] Handles when the enemy is hit by a shockwave (similar to handleHit)
func handleShockwaveHit(damage: float):
	$Sprite3D/AnimationPlayer.stop()  # Stop the animation
	currentHealth -= damage  # Subtract health
	$AudioStreamPlayer2D2.play(0.2)  # Play damage sound
	
	if (currentHealth <= 0):
		$Sprite3D/AnimationPlayer.play("death")  # Play death animation
		enemyDied.emit()  # Emit enemy death signal
	else: 
		$Sprite3D/AnimationPlayer.play("Hit")  # Play hit animation


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets up the target for the enemy to attack
func setupTarget(target: Node):
	self.targettedObject = target


# [ ? ] Sets up the soul target for the enemy (used for charge soul)
func setupSoulTarget(soulTarget):
	self.soulTarget = soulTarget


#----------------------PROPERTY FUNCTIONS----------------------
# [ ? ] Initializes the enemy's appearance and properties based on vulnerability
func initializeEnemyProperties():
	setEnemyColor()  # Set color based on vulnerability


# [ ? ] Allows external modification of the enemy's properties
func setEnemyPropertiesExternal(health: float, damage: float, customSpeed: float, customAcceleration: float):
	maxHealth = health
	currentHealth = health
	enemyDamage = damage
	speed = customSpeed
	acceleration = customAcceleration


# [ ? ] Sets the color and shader material based on the enemy's vulnerability
func setEnemyColor():
	if (enemyVulnerability == EnemyVulnerability.RED_PROJECTILE):
		$Sprite3D/SubViewport/Body.material = redShader  # Apply red shader
		gradient = redGradient  # Set gradient to red
	else:
		$Sprite3D/SubViewport/Body.material = blueShader  # Apply blue shader
		gradient = blueGradient  # Set gradient to blue


#----------------------UTILITY FUNCTIONS----------------------
# [ ? ] Initializes the enemy's stats based on the current difficulty level
func initializeStats():
	maxHealth *= difficultyModifiers[difficultyLevel]
	enemyDamage *= difficultyModifiers[difficultyLevel]
	speed *= difficultyModifiers[difficultyLevel]
	currentHealth = maxHealth


# [ ? ] Sets the difficulty level, modifying the enemy's stats accordingly
func setDifficulty(difficulty: int):
	difficultyLevel = difficulty


# [ ? ] Spawns the enemy, playing spawn animation and showing particle effects
func enemySpawn():
	var spawnParticle = spawnParticleEffect.instantiate()  # Create spawn particle
	spawnParticle.setColor(gradient)  # Set color gradient for the particle
	spawnParticle.global_position = global_position  # Set spawn position
	spawnObject.add_child(spawnParticle)  # Attach particle effect to the spawn object
	$Sprite3D/AnimationPlayer.play("Spawn")  # Play spawn animation


# [ ? ] Called when the animation finishes, disabling the ability to attack and setting walk state
func on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "Spawn"):
		canAttack = false
		setWalkingBehaviour()  # Set walking behavior after spawning


# [ ? ] Placeholder for setting the walk animation
func setWalkingBehaviour():
	pass


# [ ? ] Sets the spawn object and triggers the enemy spawn process
func setSpawnObject(object):
	spawnObject = object
	enemySpawn()  # Trigger enemy spawn


# [ ? ] Spawns the charge soul item when the enemy dies
func spawnChargeSoul():
	var soul = chargeSoul.instantiate()  # Create charge soul
	soul.global_position = global_position  # Set position of the soul
	soul.target = soulTarget  # Assign target for the soul
	spawnObject.add_child(soul)  # Attach the soul to the spawn object
