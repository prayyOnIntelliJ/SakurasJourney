extends Node3D

var newPosition : Vector3


#----------------------INITIALIZATION----------------------
# [ ? ] Starts the timer and begins emitting particles
func _ready() -> void:
	$Timer.start(1)
	$GPUParticles3D.emitting = true
	pass


#----------------------INDICATION FUNCTION----------------------
# [ ? ] Moves the object to the new position with a tween and frees it after the animation
func indicate():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", newPosition, 3)
	await tween.finished
	queue_free()


#----------------------TIMER FUNCTION----------------------
# [ ? ] Called when the timer reaches its timeout, triggers the indication function
func onTimerTimeout() -> void:
	indicate()
