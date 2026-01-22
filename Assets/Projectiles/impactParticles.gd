extends Sprite3D

#----------------------READY FUNCTION----------------------
func _ready() -> void:
	$SubViewport/GPUParticles2D.emitting = true


#----------------------SET COLOR FUNCTION----------------------
func setColor(gradient):
	$SubViewport/GPUParticles2D.process_material.color_initial_ramp = gradient


#----------------------TIMER TIMEOUT FUNCTION----------------------
func on_timer_timeout() -> void:
	queue_free()
