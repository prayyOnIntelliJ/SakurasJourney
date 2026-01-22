extends Baseenemy


#----------------------INITIALIZATION----------------------
func _ready() -> void:
	# [ ? ] Initialize the parent class and setup the enemy properties
	super()


#----------------------GAME STATE HANDLERS----------------------
func onEnemyBodyEntered(body: Node3D) -> void:
	# [ ? ] Handle enemy collision with another body (likely another character or projectile)
	if (body.has_method("collideWithEnemy")):
		body.collideWithEnemy(enemyDamage)

		# [ ? ] Play attack animation based on enemy vulnerability
		if (enemyVulnerability == EnemyVulnerability.RED_PROJECTILE):
			animationPlayer.play("Attack_Red")
		else:
			animationPlayer.play("Attack_Blue")


#----------------------ANIMATION----------------------
func setWalkingBehaviour():
	# [ ? ] Play walking animation
	animationPlayer.play("Walk")
