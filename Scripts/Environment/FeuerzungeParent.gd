extends Node3D

@export var timer : float
@export var startTimer: float

func _ready() -> void:
	$Timer.start(startTimer)

func on_timer_timeout() -> void:
	emittingEffect()
	$Timer.start(timer)



func emittingEffect():
	for effect in get_children():
		if (effect != $Timer):
			effect.emitting()
