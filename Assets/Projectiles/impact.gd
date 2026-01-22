extends Node3D

#----------------------VARIABLE DECLARATION----------------------
@onready var emitrotation

#----------------------READY FUNCTION----------------------
func _ready() -> void:
	rotation = emitrotation
	$AnimationPlayer.play("impact")
	$AudioStreamPlayer2D.play(0.2)
