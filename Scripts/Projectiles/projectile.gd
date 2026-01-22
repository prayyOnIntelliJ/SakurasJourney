extends RigidBody3D

#----------------------VARIABLE DECLARATION----------------------
@export var projectileDamage: float
@export var gradient : GradientTexture1D
@export var cameraShakeOnCollision: float = 20.0
const QUEUE_FREE_TIME : float = 2.0

var weaponType
var spawnObject
var player
var shootParticle = preload("res://Assets/Projectiles/ShootParticles.tscn")
var impactParticle = preload("res://Assets/Projectiles/ImpactParticles.tscn")

#----------------------READY FUNCTION----------------------
func _ready() -> void:
	$AnimationPlayer.play("Spawn")
	player.connect("gameEnd", onGameEnd)

#----------------------COLLISION HANDLING----------------------
func onProjectileCollision(body: Node) -> void:
	spawnImpactParticle()
	
	if (body.has_method("handleHit") && body.enemyVulnerability == weaponType):
		body.handleHit(projectileDamage)
		linear_velocity = Vector3.ZERO
		deactivateFunctionality()
		player.shakeCamera(cameraShakeOnCollision)
		

	elif (body.has_method("hitBadTree")):
		body.hitBadTree(projectileDamage)
		linear_velocity = Vector3.ZERO
		deactivateFunctionality()
	
	elif (body.has_method("hitSmallTree")):
		body.hitSmallTree(projectileDamage)
		linear_velocity = Vector3.ZERO
		deactivateFunctionality()
	
	elif (body.has_method("handleTutorialHit")):
		body.handleTutorialHit(projectileDamage)
		linear_velocity = Vector3.ZERO
		deactivateFunctionality()
		player.addShockwaveCharge()
	else:
		queue_free()


#----------------------AUDIO STREAM HANDLING----------------------
func onAudioPlayerFinished() -> void:
	queue_free()

#----------------------FUNCTIONALITY DEACTIVATION----------------------
func deactivateFunctionality():
	visible = false
	collision_layer = 0
	collision_mask = 0

#----------------------SCREEN EXIT HANDLING----------------------
func OnVisibleOnScreenNotifier3DScreenExited() -> void:
	queue_free()

#----------------------PARTICLE SPAWN FUNCTIONS----------------------
func spawnParticle():
	var particle = shootParticle.instantiate()
	particle.setColor(gradient)
	particle.global_position = global_position + Vector3(0.5, 0, 0).rotated(Vector3(0, 1, 0), rotation.y + 1.5708)
	spawnObject.add_child(particle)

func spawnImpactParticle():
	var particle = impactParticle.instantiate()
	particle.setColor(gradient)
	particle.global_position = global_position + Vector3(0, 0, 0).rotated(Vector3(0, 1, 0), rotation.y + 1.5708)
	spawnObject.add_child(particle)

#----------------------GAME END HANDLING----------------------
func onGameEnd():
	queue_free()

#----------------------SETUP FUNCTIONS----------------------
func setPlayer(playerInstance):
	player = playerInstance

func setSpawnObject(object):
	spawnObject = object
