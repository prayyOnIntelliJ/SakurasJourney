extends Node
class_name CombatComponent

signal on_current_weapon_updated(new_type: weapon_types)

enum weapon_types { RED_WEAPON, BLUE_WEAPON }

var weapon_type : weapon_types

@export var fire_rate: float = 1
@export var projectile_speed: int = 25
@export var projectile_damage: int = 10
@export_group("References")
@export var animation_player: AnimationPlayer
@export var shoot_timer: Timer

var projectileScene_red = preload("res://Scenes/Projectiles/projectile_red.tscn")
var projectileScene_blue = preload("res://Scenes/Projectiles/projectile_blue.tscn")
var projectile


func toggle_shoot(shouldShoot: bool) -> void:
	if (shouldShoot):
		shoot()
	else:
		if (!shoot_timer.is_stopped()):
			shoot_timer.stop()
			shoot_timer.wait_time = fire_rate

func shoot():
	animation_player.play("Attack")
	setup_projectile()
	shoot_timer.start(fire_rate)


# [ ? ] Setup and spawn projectile
func setup_projectile():
	if(weapon_type == weapon_types.BLUE_WEAPON):
		projectile = projectileScene_blue.instantiate()
	elif(weapon_type == weapon_types.RED_WEAPON):
		projectile = projectileScene_red.instantiate()
	projectile.global_position = $Node3D.global_position + Vector3(0.2, 0, 0).rotated(Vector3(0, 1, 0), $Node3D.rotation.y + 1.5708)
	projectile.linear_velocity = Vector3(projectile_speed, 0, 0).rotated(Vector3(0,1,0), $Node3D.rotation.y + 1.5708)
	projectile.rotation = $Node3D.rotation
	projectile.weapon_type = weapon_type
	projectile.projectileDamage = projectile_damage
	projectile.setPlayer(self)
	projectile.setSpawnObject(spawnObject)
	spawnObject.add_child(projectile)


# [ ? ] Switch between weapon types
func switch_wapon():
	if (weapon_type == weapon_types.BLUE_WEAPON):
		weapon_type = weapon_types.RED_WEAPON
	elif (weapon_type == weapon_types.RED_WEAPON):
		weapon_type = weapon_types.BLUE_WEAPON
	on_current_weapon_updated.emit(weapon_type)


# [ ? ] Handles the fire rate timer timeout
func onFireRateTimerTimeout():
	shoot()
