extends Node3D


#----------------------INITIALIZATION----------------------
# [ ? ] Starts the emission of flames, smoke, and particles
func _ready() -> void:
	$Flames.emitting = true
	$Smoke.emitting = true
	$Particles.emitting = true
