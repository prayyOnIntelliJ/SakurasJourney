extends RigidBody3D

#-------------------PROJECTION SETTINGS-------------------
@export var projectileDamage: float = 5.0

#-------------------READY FUNCTION-------------------
func _ready() -> void:
	
	$AnimationPlayer.play("Idle")

#-------------------COLLISION DETECTION-------------------
func onProjectileBodyEntered(body: Node) -> void:
	if (body.has_method("collideWithEnemy")):
		body.collideWithEnemy(projectileDamage)
	
	queue_free()

#-------------------TIMER TIMEOUT HANDLER-------------------


#-------------------DESTROY PROJECTILE MANUALLY-------------------
func destroyProjectile():
	queue_free()


func on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
