extends Node3D

#----------------------VARIABLE DECLARATION----------------------
@onready var weaponType
@onready var animation = $AnimationPlayer.get_animation("emit")
@export var shockwave_damage: float = 100
var shockwaveRange
var shockwaveModifier
var spawnObject
var shockwaveDashScene = preload("res://Scenes/Projectiles/shockwave_dash.tscn")

#----------------------READY FUNCTION----------------------
func _ready() -> void:
	setShockwaveRange(shockwaveRange)
	$AudioStreamPlayer2D.play(0.3)
	$AnimationPlayer.play("emit")

#----------------------COLLISION HANDLING----------------------
func onShockwaveBodyEntered(body: Node3D) -> void:
	if (body.has_method("handleShockwaveHit")):
		body.handleShockwaveHit(shockwave_damage)
		var shockwave = shockwaveDashScene.instantiate()
		shockwave.global_position = body.global_position
		shockwave.shockwaveDamage = shockwave_damage
		shockwave.shockwaveRange = Vector3(5, 5, 5)
		spawnObject.add_child(shockwave)
	elif (body.has_method("destroyProjectile")):
		body.destroyProjectile()

#----------------------SHOCKWAVE RANGE SETUP----------------------
func setShockwaveRange(range):
	var trackIDArea3D = animation.find_track("..:scale", Animation.TYPE_VALUE)
	var keyCountArea3D = animation.track_get_key_count(trackIDArea3D)
	var lastKeyArea3D = keyCountArea3D - 1
				
	animation.track_set_key_value(trackIDArea3D, lastKeyArea3D, range)

#----------------------SETUP FUNCTION----------------------
func setSpawnObject(object):
	spawnObject = object
