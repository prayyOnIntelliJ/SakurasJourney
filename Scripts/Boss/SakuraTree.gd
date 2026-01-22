extends StaticBody3D


#----------------------SIGNALS----------------------
signal updateSakuraTreeHealth(health)


#----------------------TREE HEALTH----------------------
@export var maxTreeHP: float = 100.0
var currentTreeHP


#----------------------INITIALIZATION----------------------
func _ready() -> void:
	resetTreeHealth()


#----------------------HEALTH RESET----------------------
# [ ? ] Resets the tree's health to the maximum value
func resetTreeHealth():
	currentTreeHP = maxTreeHP


#----------------------DAMAGE HANDLING----------------------
# [ ? ] Handles damage taken by the tree and plays the hit effects
func takeDamage(damage: float):
	currentTreeHP -= damage
	updateSakuraTreeHealth.emit(currentTreeHP)
	playHitEffects()


# [ ? ] Plays the sound and animation when the tree is hit
func playHitEffects():
	$hitSoundPlayer.play()
	$hitAnimationPlayer.play("hit")


# [ ? ] Handles collision with an enemy, applying damage to the tree
func collideWithEnemy(damage):
	takeDamage(damage)


#----------------------GETTERS----------------------
# [ ? ] Returns the maximum health of the tree
func getMaxHealth() -> float:
	return maxTreeHP


#----------------------TELEPORTATION----------------------
# [ ? ] Plays the teleportation animation for the tree
func teleport():
	$AnimationPlayer.play("Teleport")
