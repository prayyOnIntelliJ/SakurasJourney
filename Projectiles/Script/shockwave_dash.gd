extends Node3D

#----------------------VARIABLE DECLARATION----------------------
@onready var weaponType
@onready var animation = $AnimationPlayer.get_animation("emit")
var shockwaveDamage
var shockwaveRange
var shockwaveModifier

#----------------------READY FUNCTION----------------------
func _ready() -> void:
	setShockwaveRange(shockwaveRange)
	$AudioStreamPlayer2D.play(0.3)
	$AnimationPlayer.play("emit")

#----------------------COLLISION HANDLING----------------------
func onShockwaveBodyEntered(body: Node3D) -> void:
	if (body.has_method("emitHit")):
		body.emitShockwaveHit(shockwaveDamage)
	elif (body.has_method("destroyProjectile")):
		body.destroyProjectile()

#----------------------SHOCKWAVE RANGE SETUP----------------------
func setShockwaveRange(range):
	var trackIDArea3D = animation.find_track("..:scale", Animation.TYPE_VALUE)
	var keyCountArea3D = animation.track_get_key_count(trackIDArea3D)
	var lastKeyArea3D = keyCountArea3D - 1
	animation.track_set_key_value(trackIDArea3D, lastKeyArea3D, range)


func setSpawnObject(object):
	pass
