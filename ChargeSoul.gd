extends CharacterBody3D


#----------------------VARIABLES----------------------
var target
var speed: float = 20.0
var direction


#----------------------PROCESSING----------------------
# [ ? ] Checks if the target is valid and moves the character towards it, then makes it look at the target
func _process(delta: float) -> void:
	if (target != null):
		direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		look_at_from_position(global_position, target.global_position)
	else:
		# [ ! ] There is no target set for the soul, error occurred, freeing the object
		push_error("There is no target for the soul.")
		queue_free()
	
	move_and_slide()


#----------------------COLLISION HANDLING----------------------
# [ ? ] Handles the collision when the soul enters a body with the "addShockwaveCharge" method
func onChargeSoulBodyEntered(body: Node3D) -> void:
	if (body.has_method("addShockwaveCharge")):
		body.addShockwaveCharge()
		queue_free()
