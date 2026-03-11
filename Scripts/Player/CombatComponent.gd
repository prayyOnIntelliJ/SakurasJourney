extends Node
class_name CombatComponent

signal on_current_weapon_updated(new_type: weapon_types)

enum weapon_types { RED_WEAPON, BLUE_WEAPON }

var weapon_type : weapon_types

@export var fire_rate: float = 0.5
@export var projectile_speed: int = 25
@export var projectile_damage: int = 10
@export_group("References")
@export var animation_player: AnimationPlayer
@export var shoot_timer: Timer
@export var projectile_red_scene: PackedScene
@export var projectile_blue_scene: PackedScene
var spawnObject: Node
var player_ref
var should_shoot: bool = false

func _ready() -> void:
	spawnObject = ArenaSettings.getSpawnObject()

func toggle_shoot(shouldShoot: bool) -> void:
	if (shouldShoot):
		should_shoot = true
		if (shoot_timer.is_stopped()):
			shoot()
	else:
		if (!shoot_timer.is_stopped()):
			should_shoot = false

func shoot():
	if (should_shoot):
		animation_player.play("Attack")
		setup_projectile()
		shoot_timer.start(fire_rate)
	else:
		shoot_timer.stop()
		shoot_timer.wait_time = fire_rate


# [ ? ] Setup and spawn projectile
func setup_projectile():
	var projectile
	
	if(weapon_type == weapon_types.BLUE_WEAPON):
		projectile = projectile_blue_scene.instantiate()
	elif(weapon_type == weapon_types.RED_WEAPON):
		projectile = projectile_red_scene.instantiate()
		
	projectile.global_position = $"../Node3D".global_position + Vector3(0.2, 0, 0).rotated(Vector3(0, 1, 0), $"../Node3D".rotation.y + 1.5708)
	projectile.linear_velocity = Vector3(projectile_speed, 0, 0).rotated(Vector3(0,1,0), $"../Node3D".rotation.y + 1.5708)
	projectile.rotation = $"../Node3D".rotation
	projectile.weapon_type = weapon_type
	projectile.projectileDamage = projectile_damage
	projectile.setPlayer(player_ref)
	projectile.setSpawnObject(spawnObject)
	spawnObject.add_child(projectile)


# [ ? ] Switch between weapon types
func switch_weapon():
	weapon_type = 1 - weapon_type
	on_current_weapon_updated.emit(weapon_type)


# [ ? ] Handles the fire rate timer timeout
func onFireRateTimerTimeout():
	shoot()

func set_player_ref(player_ref: CharacterBody3D) -> void:
	self.player_ref = player_ref
