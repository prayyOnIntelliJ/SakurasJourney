extends TextureButton

#----------------------PROCESS FUNCTION----------------------
func _process(delta: float) -> void:
	if (is_hovered()):
		$AnimationPlayer.play("Wobbel")
	else: 
		$AnimationPlayer.stop()
